<?php
set_time_limit(15);
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

require_once __DIR__ . '/app_bootstrap.php';

// --------------------------------------------------------------------------
// GOOGLE AUTHENTICATION & DECRYPTION HELPERS (FROM SUMMARY.PHP)
// --------------------------------------------------------------------------

function getGoogleAccessToken($jsonKey) {
    if (!function_exists('curl_init')) {
        $GLOBALS['google_submission_diagnostic'] = 'PHP cURL extension is not enabled.';
        error_log('Google token error: ' . $GLOBALS['google_submission_diagnostic']);
        return null;
    }
    if (!function_exists('openssl_sign')) {
        $GLOBALS['google_submission_diagnostic'] = 'PHP OpenSSL extension is not enabled.';
        error_log('Google token error: ' . $GLOBALS['google_submission_diagnostic']);
        return null;
    }
    $jwtHeader = base64_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
    $now = time();
    $jwtClaim = base64_encode(json_encode([
        'iss' => $jsonKey['client_email'],
        'scope' => 'https://www.googleapis.com/auth/spreadsheets',
        'aud' => $jsonKey['token_uri'],
        'exp' => $now + 3600,
        'iat' => $now
    ]));

    $jwtHeader = str_replace(['+', '/', '='], ['-', '_', ''], $jwtHeader);
    $jwtClaim  = str_replace(['+', '/', '='], ['-', '_', ''], $jwtClaim);

    $signatureInput = $jwtHeader . "." . $jwtClaim;
    if (!openssl_sign($signatureInput, $rawSignature, $jsonKey['private_key'], 'SHA256')) {
        $GLOBALS['google_submission_diagnostic'] = 'OpenSSL could not sign the Google service-account JWT.';
        return null;
    }
    $jwtSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($rawSignature));
    $jwt = $signatureInput . "." . $jwtSignature;

    $ch = curl_init($jsonKey['token_uri']);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, !empty(private_config()['verify_google_tls']));
    curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
        'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion'  => $jwt
    ]));

    $response = curl_exec($ch);
    $curlError = curl_error($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($response === false) {
        $GLOBALS['google_submission_diagnostic'] = 'Google token request failed: ' . $curlError;
        error_log('Google token error: cURL request failed: ' . $curlError);
        return null;
    }

    $data = json_decode($response, true);
    if (!is_array($data) || empty($data['access_token'])) {
        $googleError = is_array($data) ? ($data['error_description'] ?? $data['error'] ?? 'Unknown Google error') : 'Invalid JSON response';
        $GLOBALS['google_submission_diagnostic'] = "Google token request failed (HTTP {$httpCode}): {$googleError}";
        error_log("Google token error (HTTP {$httpCode}): {$googleError}");
    }
    return $data['access_token'] ?? null;
}

function decryptData($cipherTextBase64) {
    if (empty($cipherTextBase64)) {
        return '';
    }
    $hexKey = configured_value('PII_ENCRYPTION_KEY', 'pii_encryption_key');
    if (!is_string($hexKey) || !preg_match('/^[a-fA-F0-9]{64}$/', $hexKey)) {
        return "[Invalid Key]";
    }

    $key = hex2bin($hexKey);
    $data = base64_decode($cipherTextBase64);
    if ($data === false || strlen($data) < 28) { 
        return $cipherTextBase64; 
    }

    $iv = substr($data, 0, 12);
    $tag = substr($data, 12, 16);
    $cipherText = substr($data, 28);

    $plainText = openssl_decrypt(
        $cipherText,
        'aes-256-gcm',
        $key,
        OPENSSL_RAW_DATA,
        $iv,
        $tag
    );

    return ($plainText === false) ? "[Decryption Failed]" : $plainText;
}

function fetchAndDecryptGoogleSheet() {
    $jsonKeyRaw = getenv('GOOGLE_SERVICE_ACCOUNT_JSON') ?: ($_ENV['GOOGLE_SERVICE_ACCOUNT_JSON'] ?? '');
    $jsonKey = $jsonKeyRaw ? json_decode($jsonKeyRaw, true, 512, JSON_THROW_ON_ERROR) : null;
    if (!$jsonKey) {
        $credentialsFile = getenv('GOOGLE_CREDENTIALS_FILE') ?: (__DIR__ . '/google_credentials.php');
        if (is_file($credentialsFile)) {
            $jsonKey = require $credentialsFile;
        }
    }

    if (!is_array($jsonKey) || !isset($jsonKey['client_email'])) {
        throw new RuntimeException('Google credentials not properly configured.');
    }

    $accessToken = getGoogleAccessToken($jsonKey);
    if (!$accessToken) {
        throw new RuntimeException('Unable to obtain Google Access Token: ' . ($GLOBALS['google_submission_diagnostic'] ?? 'Unknown error'));
    }

    $spreadsheetId = configured_value('GOOGLE_SPREADSHEET_ID', 'google_spreadsheet_id');
    $url = "https://sheets.googleapis.com/v4/spreadsheets/{$spreadsheetId}/values/Sheet1!A:M";

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Authorization: Bearer ' . $accessToken]);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, !empty(private_config()['verify_google_tls']));
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($httpCode !== 200 || !$response) {
        throw new RuntimeException("Failed to fetch Google Sheet data (HTTP $httpCode).");
    }

    $data = json_decode($response, true);
    $rows = $data['values'] ?? [];

    $decryptedRows = [];
    foreach ($rows as $index => $row) {
        if ($index === 0 && isset($row[0]) && strtolower($row[0]) === 'timestamp') {
            continue;
        }

        $decryptedRows[] = [
            'timestamp'         => $row[0] ?? '',
            'first_name'        => decryptData($row[1] ?? ''),
            'last_name'         => decryptData($row[2] ?? ''),
            'email'             => decryptData($row[3] ?? ''),
            'lcp'               => decryptData($row[4] ?? ''),
            'lookup_hash'       => $row[5] ?? '',
            'career_1'          => decryptData($row[6] ?? ''),
            'career_2'          => decryptData($row[7] ?? ''),
            'career_3'          => decryptData($row[8] ?? ''),
            'major'             => decryptData($row[9] ?? ''),
            'credential_type'   => decryptData($row[10] ?? ''),
            'riasec'            => decryptData($row[11] ?? ''),
            'education_level'   => decryptData($row[12] ?? '')
        ];
    }

    return $decryptedRows;
}

// --------------------------------------------------------------------------
// AJAX SEARCH ENDPOINT
// --------------------------------------------------------------------------
if (isset($_GET['action']) && $_GET['action'] === 'search') {
    header('Content-Type: application/json');
    $searchTerm = trim($_GET['q'] ?? '');

    try {
        $allRows = fetchAndDecryptGoogleSheet();
        $matches = [];

        if ($searchTerm !== '') {
            $term = strtolower($searchTerm);
            foreach ($allRows as $row) {
                $fullName = strtolower($row['first_name'] . ' ' . $row['last_name']);
                $email = strtolower($row['email']);

                if (strpos($fullName, $term) !== false || strpos($email, $term) !== false) {
                    $matches[] = $row;
                }
            }
        }

        echo json_encode(['success' => true, 'data' => $matches]);
    } catch (Throwable $e) {
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Candidate File Reviewer</title>
    <style>
        :root {
            --cerritos-blue: #002b49;
            --cerritos-gold: #735000;
            --cerritos-dark: #0f172a;
            --cerritos-light: #f8fafc;
            --card-border: #475569;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background-color: var(--cerritos-light);
            color: var(--cerritos-dark);
            margin: 0;
            padding: 0;
        }

        header {
            background-color: var(--cerritos-blue);
            color: #ffffff;
            padding: 1rem 1.5rem;
            border-bottom: 5px solid var(--cerritos-gold);
        }

        .container {
            max-width: 1000px;
            margin: 2rem auto;
            background: #ffffff;
            padding: 1.5rem 2rem;
            border-radius: 8px;
            border: 2px solid var(--card-border);
        }

        .search-box {
            margin-bottom: 1.5rem;
        }

        input[type="text"] {
            width: 100%;
            padding: 0.75rem;
            font-size: 1rem;
            border: 2px solid var(--card-border);
            border-radius: 6px;
            box-sizing: border-box;
        }

        .candidate-card {
            background: #ffffff;
            border: 2px solid var(--cerritos-blue);
            border-radius: 6px;
            padding: 1rem;
            margin-bottom: 1rem;
        }

        .candidate-card h3 {
            margin-top: 0;
            color: var(--cerritos-blue);
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 0.5rem 1rem;
        }

        .info-item {
            font-size: 0.9rem;
        }

        .info-label {
            font-weight: bold;
            color: var(--cerritos-gold);
        }

        .status {
            font-style: italic;
            color: #666;
        }
    </style>
</head>
<body>

<header>
    <h1 style="margin:0;">Student File Reviewer</h1>
</header>

<main class="container">
    <div class="search-box">
        <label for="search" style="font-weight: bold; display: block; margin-bottom: 0.5rem;">
            Search Candidate Name or Email:
        </label>
        <input type="text" id="search" placeholder="Type a name or email address..." autocomplete="off">
    </div>

    <div id="status" class="status">Type a query above to fetch and decrypt records.</div>
    <div id="results" style="margin-top: 1rem;"></div>
</main>

<script>
let debounceTimer;

document.getElementById('search').addEventListener('input', function(e) {
    const query = e.target.value.trim();
    clearTimeout(debounceTimer);

    if (query.length === 0) {
        document.getElementById('results').innerHTML = '';
        document.getElementById('status').textContent = 'Type a query above to fetch and decrypt records.';
        return;
    }

    document.getElementById('status').textContent = 'Decrypting and searching records...';

    debounceTimer = setTimeout(() => {
        fetch(`reviewer.php?action=search&q=${encodeURIComponent(query)}`)
            .then(response => response.json())
            .then(res => {
                if (!res.success) {
                    document.getElementById('status').textContent = `Error: ${res.error}`;
                    return;
                }

                document.getElementById('status').textContent = `Found ${res.data.length} match(es).`;
                renderResults(res.data);
            })
            .catch(err => {
                document.getElementById('status').textContent = 'An error occurred while fetching data.';
            });
    }, 300);
});

function renderResults(candidates) {
    const container = document.getElementById('results');
    container.innerHTML = '';

    candidates.forEach(c => {
        const card = document.createElement('div');
        card.className = 'candidate-card';
        card.innerHTML = `
            <h3>${escapeHtml(c.first_name)} ${escapeHtml(c.last_name)}</h3>
            <div class="info-grid">
                <div class="info-item"><span class="info-label">Email:</span> ${escapeHtml(c.email)}</div>
                <div class="info-item"><span class="info-label">Timestamp:</span> ${escapeHtml(c.timestamp)}</div>
                <div class="info-item"><span class="info-label">Pathway (LCP):</span> ${escapeHtml(c.lcp)}</div>
                <div class="info-item"><span class="info-label">RIASEC:</span> ${escapeHtml(c.riasec)}</div>
                <div class="info-item"><span class="info-label">Major:</span> ${escapeHtml(c.major)}</div>
                <div class="info-item"><span class="info-label">Credential:</span> ${escapeHtml(c.credential_type)}</div>
                <div class="info-item"><span class="info-label">Goal:</span> ${escapeHtml(c.education_level)}</div>
                <div class="info-item"><span class="info-label">Careers:</span> ${escapeHtml([c.career_1, c.career_2, c.career_3].filter(Boolean).join(', '))}</div>
            </div>
        `;
        container.appendChild(card);
    });
}

function escapeHtml(str) {
    return String(str || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}
</script>

</body>
</html>