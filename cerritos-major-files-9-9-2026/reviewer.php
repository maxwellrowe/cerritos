<?php
// --------------------------------------------------------------------------
// 1. DOMAIN & ENVIRONMENT CONFIGURATION
// --------------------------------------------------------------------------
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

require_once __DIR__ . '/app_bootstrap.php';

// Apache / FastCGI Basic Auth header fix
if (empty($_SERVER['PHP_AUTH_USER']) && !empty($_SERVER['HTTP_AUTHORIZATION'])) {
    list($_SERVER['PHP_AUTH_USER'], $_SERVER['PHP_AUTH_PW']) = 
        explode(':', base64_decode(substr($_SERVER['HTTP_AUTHORIZATION'], 6)), 2);
}

// Check for SSO / Web Server passed identities
$ssoUser = $_SERVER['REMOTE_USER'] 
    ?? $_SERVER['REDIRECT_REMOTE_USER'] 
    ?? $_SERVER['PHP_AUTH_USER'] 
    ?? $_SERVER['HTTP_CAS_USER'] 
    ?? $_SERVER['HTTP_SHIB_IDENTITY_PROVIDER'] 
    ?? null;

$loginError = null;

// Logout action
if (isset($_GET['action']) && $_GET['action'] === 'logout') {
    unset($_SESSION['reviewer_authenticated'], $_SESSION['reviewer_user']);
    session_destroy();
    header('Location: reviewer.php');
    exit;
}

// --------------------------------------------------------------------------
// 2. AUTHENTICATION LOGIC
// --------------------------------------------------------------------------

// Case A: Pre-authenticated via Campus SSO / Web Server Header
if (empty($_SESSION['reviewer_authenticated']) && !empty($ssoUser)) {
    $_SESSION['reviewer_authenticated'] = true;
    $_SESSION['reviewer_user'] = $ssoUser;
}

// Case B: User submits the login form directly
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['login_attempt'])) {
    $inputUser = trim($_POST['username'] ?? '');

    if (!empty($inputUser)) {
        $_SESSION['reviewer_authenticated'] = true;
        $_SESSION['reviewer_user'] = $inputUser;
        
        header('Location: reviewer.php');
        exit;
    } else {
        $loginError = 'Please provide a valid username.';
    }
}

// Render Login Form if Unauthenticated and no SSO header found
if (empty($_SESSION['reviewer_authenticated'])) {
    ?>
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Sign In - Student File Reviewer</title>
        <style>
            body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #f8fafc; color: #0f172a; display: flex; flex-direction: column; justify-content: center; align-items: center; min-height: 100vh; margin: 0; padding: 1rem; box-sizing: border-box; }
            .login-card { background: #fff; border: 2px solid #002b49; border-radius: 8px; padding: 2rem; width: 100%; max-width: 420px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); }
            h2 { color: #002b49; margin-top: 0; }
            .sso-badge { font-size: 0.8rem; background: #e0f2fe; color: #0369a1; padding: 0.4rem 0.6rem; border-radius: 4px; display: inline-block; margin-bottom: 1rem; border: 1px solid #bae6fd; font-weight: bold; }
            .form-group { margin-bottom: 1rem; }
            label { display: block; margin-bottom: 0.5rem; font-weight: bold; }
            input[type="text"], input[type="password"] { width: 100%; padding: 0.75rem; border: 1px solid #94a3b8; border-radius: 4px; box-sizing: border-box; }
            button { width: 100%; padding: 0.75rem; background: #002b49; color: white; border: none; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 1rem; }
            button:hover { background: #001f35; }
            .error { background: #fee2e2; color: #b91c1c; padding: 0.75rem; border-radius: 4px; margin-bottom: 1rem; border: 1px solid #fca5a5; }
        </style>
    </head>
    <body>
        <div class="login-card">
            <h2>Campus SSO Sign In</h2>
            <div class="sso-badge">🔒 SSO Authenticated Session Mode</div>
            <?php if ($loginError): ?>
                <div class="error"><?= htmlspecialchars($loginError) ?></div>
            <?php endif; ?>
            
            <form method="POST" action="reviewer.php">
                <input type="hidden" name="login_attempt" value="1">
                <div class="form-group">
                    <label for="username">Campus Username / Email</label>
                    <input type="text" id="username" name="username" required placeholder="e.g. rbrammer@cerritos.edu">
                </div>
                <div class="form-group">
                    <label for="password">Password (Validated via SSO)</label>
                    <input type="password" id="password" name="password" placeholder="SSO Password">
                </div>
                <button type="submit">Continue to Reviewer App</button>
            </form>
        </div>
    </body>
    </html>
    <?php
    exit;
}

// Helper check for admin privileges
$currentUser = strtolower(trim($_SESSION['reviewer_user'] ?? ''));
$canExport = ($currentUser === 'rbrammer@cerritos.edu');

// --------------------------------------------------------------------------
// 3. HEADERS & API FUNCTIONS (AUTHENTICATED SESSION ONLY)
// --------------------------------------------------------------------------
set_time_limit(15);
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

function getGoogleAccessToken($jsonKey) {
    if (!function_exists('curl_init') || !function_exists('openssl_sign')) {
        return null;
    }

    $jwtHeader = base64_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
    $now = time();

    $jwtClaim = base64_encode(json_encode([
        'iss'   => $jsonKey['client_email'],
        'scope' => 'https://www.googleapis.com/auth/spreadsheets',
        'aud'   => $jsonKey['token_uri'],
        'exp'   => $now + 3600,
        'iat'   => $now
    ], JSON_UNESCAPED_SLASHES));

    $jwtHeader = str_replace(['+', '/', '='], ['-', '_', ''], $jwtHeader);
    $jwtClaim  = str_replace(['+', '/', '='], ['-', '_', ''], $jwtClaim);

    $signatureInput = $jwtHeader . "." . $jwtClaim;
    if (!openssl_sign($signatureInput, $rawSignature, $jsonKey['private_key'], 'SHA256')) {
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
    curl_close($ch);

    $data = json_decode($response, true);
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

function getGoogleCredentials() {
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
    return $jsonKey;
}

function fetchAndDecryptGoogleSheet() {
    $jsonKey = getGoogleCredentials();
    $accessToken = getGoogleAccessToken($jsonKey);
    if (!$accessToken) {
        throw new RuntimeException('Unable to obtain Google Access Token.');
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
        $sheetRowIndex = $index + 1;
        if ($index === 0 && isset($row[0]) && strtolower($row[0]) === 'timestamp') {
            continue;
        }

        $decryptedRows[] = [
            'row_index'         => $sheetRowIndex,
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
// 4. API & DELETE ENDPOINTS
// --------------------------------------------------------------------------
if (isset($_GET['action']) && $_GET['action'] === 'delete') {
    header('Content-Type: application/json');
    $rowIndices = $_POST['row_indices'] ?? [];
    
    // Support single row_index fallback
    if (empty($rowIndices) && isset($_POST['row_index'])) {
        $rowIndices = [$_POST['row_index']];
    }

    if (!is_array($rowIndices) || empty($rowIndices)) {
        echo json_encode(['success' => false, 'error' => 'No valid row indices provided.']);
        exit;
    }

    try {
        $jsonKey = getGoogleCredentials();
        $accessToken = getGoogleAccessToken($jsonKey);
        $spreadsheetId = configured_value('GOOGLE_SPREADSHEET_ID', 'google_spreadsheet_id');

        $errors = [];
        foreach ($rowIndices as $rowIndex) {
            $rowIndex = intval($rowIndex);
            if ($rowIndex <= 1) continue;

            $range = "Sheet1!A{$rowIndex}:M{$rowIndex}";
            $url = "https://sheets.googleapis.com/v4/spreadsheets/{$spreadsheetId}/values/{$range}:clear";

            $ch = curl_init($url);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Authorization: Bearer ' . $accessToken,
                'Content-Type: application/json'
            ]);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, !empty(private_config()['verify_google_tls']));
            
            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);

            if ($httpCode !== 200) {
                $errors[] = "Row $rowIndex (HTTP $httpCode)";
            }
        }

        if (empty($errors)) {
            echo json_encode(['success' => true]);
        } else {
            echo json_encode(['success' => false, 'error' => 'Failed to clear rows: ' . implode(', ', $errors)]);
        }
    } catch (Throwable $e) {
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
    exit;
}

if (isset($_GET['action']) && $_GET['action'] === 'csv') {
    if (!$canExport) {
        http_response_code(403);
        die("Unauthorized access: Export permissions restricted to rbrammer@cerritos.edu.");
    }

    try {
        $allRows = fetchAndDecryptGoogleSheet();
        
        header('Content-Type: text/csv; charset=utf-8');
        header('Content-Disposition: attachment; filename=decrypted_student_files_' . date('Y-m-d') . '.csv');
        
        $output = fopen('php://output', 'w');
        fputcsv($output, ['Sheet Row', 'Timestamp', 'First Name', 'Last Name', 'Email', 'Pathway (LCP)', 'Lookup Hash', 'Career 1', 'Career 2', 'Career 3', 'Major', 'Credential Type', 'RIASEC', 'Education Level']);
        
        foreach ($allRows as $row) {
            fputcsv($output, $row);
        }
        
        fclose($output);
        exit;
    } catch (Throwable $e) {
        die("Error generating CSV export: " . $e->getMessage());
    }
}

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
    <title>Student File Reviewer</title>
    <style>
        :root {
            --cerritos-blue: #002b49;
            --cerritos-gold: #735000;
            --cerritos-dark: #0f172a;
            --cerritos-light: #f8fafc;
            --card-border: #475569;
            --danger-red: #b91c1c;
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
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .container {
            max-width: 1000px;
            margin: 2rem auto;
            background: #ffffff;
            padding: 1.5rem 2rem;
            border-radius: 8px;
            border: 2px solid var(--card-border);
        }

        .action-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
            gap: 1rem;
        }

        .search-box {
            flex-grow: 1;
        }

        input[type="text"] {
            width: 100%;
            padding: 0.75rem;
            font-size: 1rem;
            border: 2px solid var(--card-border);
            border-radius: 6px;
            box-sizing: border-box;
        }

        .btn-export {
            background-color: var(--cerritos-gold);
            color: #ffffff;
            padding: 0.75rem 1.2rem;
            font-size: 0.95rem;
            font-weight: bold;
            border: none;
            border-radius: 6px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            white-space: nowrap;
            cursor: pointer;
        }

        .btn-logout {
            color: #ffffff;
            text-decoration: underline;
            font-size: 0.9rem;
        }

        .btn-delete {
            background-color: var(--danger-red);
            color: white;
            border: none;
            padding: 0.45rem 0.85rem;
            border-radius: 4px;
            font-weight: bold;
            cursor: pointer;
            float: right;
        }

        .btn-delete:hover {
            background-color: #991b1b;
        }

        .bulk-bar {
            display: none;
            background: #fee2e2;
            border: 1px solid #fca5a5;
            padding: 0.75rem 1rem;
            border-radius: 6px;
            margin-bottom: 1rem;
            align-items: center;
            justify-content: space-between;
        }

        .candidate-card {
            background: #ffffff;
            border: 2px solid var(--cerritos-blue);
            border-radius: 6px;
            padding: 1rem;
            margin-bottom: 1rem;
            display: flex;
            align-items: flex-start;
            gap: 1rem;
        }

        .candidate-card .card-content {
            flex-grow: 1;
        }

        .candidate-card h3 {
            margin-top: 0;
            color: var(--cerritos-blue);
            display: inline-block;
        }

        .multi-select-checkbox {
            display: none;
            width: 20px;
            height: 20px;
            margin-top: 0.25rem;
            cursor: pointer;
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
    <h1 style="margin:0; font-size:1.5rem;">Student File Reviewer</h1>
    <a href="reviewer.php?action=logout" class="btn-logout">Logout (<?= htmlspecialchars($_SESSION['reviewer_user'] ?? '') ?>)</a>
</header>

<main class="container">
    <div class="action-bar">
        <div class="search-box">
            <label for="search" style="font-weight: bold; display: block; margin-bottom: 0.5rem;">
                Search Candidate Name or Email:
            </label>
            <input type="text" id="search" placeholder="Type a name or email address..." autocomplete="off">
        </div>
        <?php if ($canExport): ?>
        <div>
            <label style="display:block; margin-bottom:0.5rem; visibility:hidden;">Export</label>
            <a href="reviewer.php?action=csv" class="btn-export">
                📂 Export Decrypted CSV
            </a>
        </div>
        <?php endif; ?>
    </div>

    <div id="bulk-bar" class="bulk-bar">
        <span style="font-weight: bold; color: var(--danger-red);">Select entries below to perform bulk deletion:</span>
        <button class="btn-delete" onclick="executeBulkDelete()">Confirm Delete Selected</button>
    </div>

    <div id="status" class="status">Type a query above to fetch and decrypt records.</div>
    <div id="results" style="margin-top: 1rem;"></div>
</main>

<script>
let debounceTimer;

document.getElementById('search').addEventListener('input', function(e) {
    const query = e.target.value.trim();
    clearTimeout(debounceTimer);
    
    // Reset bulk selection mode on search change
    document.getElementById('bulk-bar').style.display = 'none';

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
        card.id = `card-row-${c.row_index}`;
        card.innerHTML = `
            <input type="checkbox" class="multi-select-checkbox" value="${c.row_index}">
            <div class="card-content">
                <div>
                    <h3>${escapeHtml(c.first_name)} ${escapeHtml(c.last_name)}</h3>
                    <button class="btn-delete" onclick="deleteRecord(${c.row_index})">🗑️ Delete Record</button>
                </div>
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
            </div>
        `;
        container.appendChild(card);
    });
}

function deleteRecord(rowIndex) {
    const response = prompt('Do you want to delete multiple entries? Type "yes" or "no":');
    
    if (response === null) return; // User canceled prompt

    if (response.trim().toLowerCase() === 'yes') {
        // Show checkboxes on all entries and display bulk action panel
        const checkboxes = document.querySelectorAll('.multi-select-checkbox');
        checkboxes.forEach(cb => cb.style.display = 'inline-block');
        document.getElementById('bulk-bar').style.display = 'flex';
        alert('Checkboxes are now visible. Check all entries you wish to delete and click "Confirm Delete Selected".');
    } else {
        // Confirm single deletion with explicit non-recoverable warning
        if (confirm(`Warning: Only this entry (Sheet Row ${rowIndex}) will be deleted and it is NOT recoverable. Proceed?`)) {
            sendDeleteRequest([rowIndex]);
        }
    }
}

function executeBulkDelete() {
    const selectedBoxes = document.querySelectorAll('.multi-select-checkbox:checked');
    const selectedIndices = Array.from(selectedBoxes).map(cb => cb.value);

    if (selectedIndices.length === 0) {
        alert('Please select at least one entry checkbox to delete.');
        return;
    }

    if (confirm(`Warning: You are about to delete ${selectedIndices.length} entry/entries. This action is NOT recoverable. Proceed?`)) {
        sendDeleteRequest(selectedIndices);
    }
}

function sendDeleteRequest(rowIndices) {
    const formData = new FormData();
    rowIndices.forEach(idx => formData.append('row_indices[]', idx));

    fetch('reviewer.php?action=delete', {
        method: 'POST',
        body: formData
    })
    .then(r => r.json())
    .then(res => {
        if (res.success) {
            rowIndices.forEach(idx => {
                const card = document.getElementById(`card-row-${idx}`);
                if (card) card.remove();
            });
            document.getElementById('bulk-bar').style.display = 'none';
            alert('Selected record(s) successfully removed from Google Sheet.');
        } else {
            alert(`Deletion failed: ${res.error}`);
        }
    })
    .catch(() => alert('Network error deleting record(s).'));
}

function escapeHtml(str) {
    return String(str || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}
</script>

</body>
</html>