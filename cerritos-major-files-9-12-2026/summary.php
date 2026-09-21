<?php

set_time_limit(5); // Kills the script after 5 seconds instead of hanging forever
// Prevent browser caching
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

require_once __DIR__ . '/app_bootstrap.php';

// Ensure applicant data exists in session; if not, redirect to home
if (!isset($_SESSION['applicant'])) {
    header('Location: index.php');
    exit;
}

// --------------------------------------------------------------------------
// CRYPTOGRAPHIC & LOOKUP HELPERS (WITH PRODUCTION/LOCAL FALLBACKS)
// --------------------------------------------------------------------------

function getEmailLookupKey($email) {
    if (empty($email)) {
        return '';
    }
    $secretKey = configured_value('LOOKUP_SECRET_KEY', 'lookup_secret_key');
    if (!is_string($secretKey) || $secretKey === '') {
        throw new RuntimeException('LOOKUP_SECRET_KEY is not configured.');
    }

    $normalizedEmail = strtolower(trim($email));
    return hash_hmac('sha256', $normalizedEmail, $secretKey);
}

function encryptData($plainText) {
    if (empty($plainText)) {
        return '';
    }
    $hexKey = configured_value('PII_ENCRYPTION_KEY', 'pii_encryption_key');
    if (!is_string($hexKey) || !preg_match('/^[a-fA-F0-9]{64}$/', $hexKey)) {
        throw new RuntimeException('PII_ENCRYPTION_KEY must be a 64-character hexadecimal key.');
    }

    $key = hex2bin($hexKey);
    $iv = openssl_random_pseudo_bytes(12);
    $tag = '';

    $cipherText = openssl_encrypt(
        $plainText,
        'aes-256-gcm',
        $key,
        OPENSSL_RAW_DATA,
        $iv,
        $tag
    );

    if ($cipherText === false) {
        return "[Encryption Failed]";
    }

    return base64_encode($iv . $tag . $cipherText);
}

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

// --------------------------------------------------------------------------
// 1. ACTION: FINISH & DESTROY SESSION
// --------------------------------------------------------------------------
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'finish_complete') {
    require_valid_csrf();
    $_SESSION['submit_requested'] = true;
}

// --------------------------------------------------------------------------
// 2. POST TO GOOGLE SHEETS ONLY AFTER THE USER EXPLICITLY FINISHES
// --------------------------------------------------------------------------
if (!empty($_SESSION['submit_requested']) && empty($_SESSION['sheets_saved'])) {

    $applicant = $_SESSION['applicant'] ?? [];

    // Safely extract string titles for selected careers
    $raw_selected = $_SESSION['selected_careers'] ?? $applicant['selected_careers'] ?? [];
    if (is_string($raw_selected)) {
        $decoded = json_decode($raw_selected, true);
        $raw_selected = is_array($decoded) ? $decoded : (!empty($raw_selected) ? [$raw_selected] : []);
    }

    $selected_careers = [];
    if (is_array($raw_selected)) {
        foreach ($raw_selected as $sc) {
            if (is_array($sc) && !empty($sc['title'])) {
                $selected_careers[] = trim($sc['title']);
            } elseif (is_string($sc) && !empty($sc)) {
                $selected_careers[] = trim($sc);
            }
        }
    }

    $first_name = $applicant['first_name'] ?? $applicant['name'] ?? '';
    $last_name  = $applicant['last_name'] ?? '';
    $email      = $applicant['email'] ?? '';
    $lcp        = $applicant['lcp'] ?? $applicant['pathway_used'] ?? '';
    
    $selected_major           = $_SESSION['selected_major'] ?? $applicant['selected_major'] ?? '';
    $selected_credential_type = $_SESSION['selected_credential_type'] ?? $applicant['selected_credential_type'] ?? '';
    $education_level          = $_SESSION['education_level'] ?? $applicant['education_level'] ?? '';

    $riasec_codes = $applicant['top_three_codes'] ?? $applicant['riasec'] ?? $applicant['riasec_code'] ?? '';
    if (is_array($riasec_codes)) {
        $riasec_display = implode('-', $riasec_codes);
    } elseif (is_string($riasec_codes)) {
        $decoded_r = json_decode($riasec_codes, true);
        $riasec_display = is_array($decoded_r) ? implode('-', $decoded_r) : $riasec_codes;
    } else {
        $riasec_display = '';
    }

    $c1 = $selected_careers[0] ?? '';
    $c2 = $selected_careers[1] ?? '';
    $c3 = $selected_careers[2] ?? '';

    // Columns A through M mapping
    $rowValues = [
        date('Y-m-d H:i:s'),
        encryptData($first_name),
        encryptData($last_name),
        encryptData($email),
        encryptData($lcp),
        getEmailLookupKey($email),
        encryptData($c1),
        encryptData($c2),
        encryptData($c3),
        encryptData($selected_major),
        encryptData($selected_credential_type),
        encryptData($riasec_display),
        encryptData($education_level)
    ];

    try {
        $jsonKeyRaw = getenv('GOOGLE_SERVICE_ACCOUNT_JSON') ?: ($_ENV['GOOGLE_SERVICE_ACCOUNT_JSON'] ?? '');
        $jsonKey = $jsonKeyRaw ? json_decode($jsonKeyRaw, true, 512, JSON_THROW_ON_ERROR) : null;
        if (!$jsonKey) {
            $credentialsFile = getenv('GOOGLE_CREDENTIALS_FILE') ?: (__DIR__ . '/google_credentials.php');
            if (!is_file($credentialsFile)) {
                throw new RuntimeException('Google service-account credentials are not configured.');
            }
            $jsonKey = require $credentialsFile;
        }
        if (is_array($jsonKey) && isset($jsonKey['client_email'])) {
            $accessToken = getGoogleAccessToken($jsonKey);
            if ($accessToken) {
                $spreadsheetId = configured_value('GOOGLE_SPREADSHEET_ID', 'google_spreadsheet_id');
                if ($spreadsheetId === '') {
                    throw new RuntimeException('GOOGLE_SPREADSHEET_ID is not configured.');
                }
                $url = "https://sheets.googleapis.com/v4/spreadsheets/{$spreadsheetId}/values/Sheet1!A:M:append?valueInputOption=RAW";

                $maxRetries = 3;
                $attempt = 0;
                $httpCode = 0;
                $response = false;
                $curlError = '';

                while ($attempt < $maxRetries) {
                    $attempt++;

                    $ch = curl_init($url);
                    curl_setopt($ch, CURLOPT_HTTPHEADER, [
                        'Authorization: Bearer ' . $accessToken,
                        'Content-Type: application/json'
                    ]);
                    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                    curl_setopt($ch, CURLOPT_POST, true);
                    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, !empty(private_config()['verify_google_tls']));
                    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
                        'values' => [$rowValues]
                    ]));
                    
                    $response = curl_exec($ch);
                    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
                    $curlError = curl_error($ch);
                    curl_close($ch);

                    if ($httpCode === 200) {
                        break;
                    }

                    if (in_array($httpCode, [500, 502, 503, 504], true) && $attempt < $maxRetries) {
                        usleep($attempt * 500000);
                    } else {
                        break;
                    }
                }

                if ($httpCode === 200) {
                    $_SESSION['sheets_saved'] = true;
                } else {
                    $GLOBALS['google_submission_diagnostic'] = "Google Sheets write failed (HTTP {$httpCode}): " . ($response === false ? $curlError : $response);
                    error_log("Google Sheets API Error ($httpCode): " . ($response === false ? $curlError : $response));
                    $submission_error = 'Your submission could not be saved. Please try again or contact the program administrator.';
                }
            } else {
                if (empty($GLOBALS['google_submission_diagnostic'])) {
                    $GLOBALS['google_submission_diagnostic'] = 'Google did not return an access token.';
                }
                $submission_error = 'Your submission could not be authorized. Please contact the program administrator.';
            }
        } else {
            throw new RuntimeException('Invalid Google service-account credentials.');
        }
    } catch (Throwable $e) {
        $GLOBALS['google_submission_diagnostic'] = $e->getMessage();
        error_log('Google Sheets submission error: ' . $e->getMessage());
        $submission_error = 'Your submission could not be saved. Please try again or contact the program administrator.';
    }
}

if (!empty($_SESSION['submit_requested']) && !empty($_SESSION['sheets_saved'])) {
    $_SESSION = [];
    if (ini_get('session.use_cookies')) {
        $params = session_get_cookie_params();
        setcookie(session_name(), '', time() - 42000, $params['path'], $params['domain'], $params['secure'], $params['httponly']);
    }
    session_destroy();
    header('Location: thank_you.php');
    exit;
}

// --------------------------------------------------------------------------
// PREPARE VIEW DATA FOR RENDER
// --------------------------------------------------------------------------
$applicant = $_SESSION['applicant'] ?? [];
$email = $applicant['email'] ?? '';

$raw_selected = $_SESSION['selected_careers'] ?? $applicant['selected_careers'] ?? [];
if (is_string($raw_selected)) {
    $decoded = json_decode($raw_selected, true);
    $raw_selected = is_array($decoded) ? $decoded : (!empty($raw_selected) ? [$raw_selected] : []);
}

$selected_careers = [];
if (is_array($raw_selected)) {
    foreach ($raw_selected as $sc) {
        if (is_array($sc) && !empty($sc['title'])) {
            $selected_careers[] = trim($sc['title']);
        } elseif (is_string($sc) && !empty($sc)) {
            $selected_careers[] = trim($sc);
        }
    }
}

$selected_major = $_SESSION['selected_major'] ?? $applicant['selected_major'] ?? 'Not Selected';
$selected_credential_type = $_SESSION['selected_credential_type'] ?? $applicant['selected_credential_type'] ?? 'Not Specified';
$education_level_display = $_SESSION['education_level'] ?? $applicant['education_level'] ?? 'Not Specified';
$major_details = $_SESSION['selected_major_details'] ?? $applicant['selected_major_details'] ?? [];

if (empty($major_details['description']) && file_exists('degrees.json')) {
    $json_content = file_get_contents('degrees.json');
    $degrees_data = json_decode($json_content, true) ?: [];
    if (isset($degrees_data['degrees'])) {
        $degrees_data = $degrees_data['degrees'];
    }
    foreach ($degrees_data as $d) {
        if (trim($d['program_name'] ?? '') === trim($selected_major)) {
            $major_details['description'] = $d['description'] ?? '';
            $major_details['category'] = $d['credential_category'] ?? '';
            $major_details['is_adt'] = (bool)preg_match('/(AA-T|AS-T|Transfer)/i', $selected_credential_type);
            break;
        }
    }
}

$first_name = $applicant['first_name'] ?? $applicant['name'] ?? 'Applicant';
$last_name  = $applicant['last_name'] ?? '';
$full_name  = trim("$first_name $last_name");
$lcp        = $applicant['lcp'] ?? $applicant['pathway_used'] ?? 'N/A';

$riasec_codes = $applicant['top_three_codes'] ?? $applicant['riasec'] ?? $applicant['riasec_code'] ?? 'N/A';
if (is_array($riasec_codes)) {
    $riasec_display = implode('-', $riasec_codes);
} elseif (is_string($riasec_codes)) {
    $decoded_r = json_decode($riasec_codes, true);
    $riasec_display = is_array($decoded_r) ? implode('-', $decoded_r) : $riasec_codes;
} else {
    $riasec_display = 'N/A';
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cerritos College - Summary & Confirmation</title>
    <style>
        :root {
            /* WCAG AAA/AA High Contrast Palette */
            --cerritos-blue: #002b49;
            --cerritos-gold: #735000;
            --cerritos-dark: #0f172a;
            --cerritos-light: #f8fafc;
            --card-border: #475569;
            --text-muted: #334155;
            --focus-outline: #005fcc;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background-color: var(--cerritos-light);
            color: var(--cerritos-dark);
            margin: 0;
            padding: 0;
            font-size: 15px;
            line-height: 1.5;
        }

        header {
            background-color: var(--cerritos-blue);
            color: #ffffff;
            padding: 1rem 1.5rem;
            border-bottom: 5px solid var(--cerritos-gold);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        header h1 {
            font-size: 1.35rem;
            margin: 0;
            font-weight: 700;
        }

        .step-indicator {
            font-size: 0.85rem;
            background: rgba(255,255,255,0.2);
            padding: 0.4rem 0.8rem;
            border-radius: 12px;
            font-weight: 700;
            color: #ffffff;
        }

        .container {
            max-width: 850px;
            margin: 2rem auto;
            background: #ffffff;
            padding: 1.75rem 2rem;
            border-radius: 8px;
            border: 2px solid var(--card-border);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        }

        .header-box {
            margin-bottom: 1.25rem;
            border-bottom: 3px solid var(--cerritos-gold);
            padding-bottom: 0.5rem;
        }

        h2 {
            color: var(--cerritos-blue);
            margin: 0 0 0.25rem 0;
            font-size: 1.5rem;
        }

        .subtext {
            color: var(--text-muted);
            margin: 0;
            font-size: 0.95rem;
        }

        .summary-card {
            background-color: #ffffff;
            border: 2px solid var(--card-border);
            border-radius: 8px;
            padding: 1.1rem 1.3rem;
            margin-bottom: 1.25rem;
        }

        .summary-card h3 {
            margin-top: 0;
            margin-bottom: 0.85rem;
            color: var(--cerritos-blue);
            font-size: 1.1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 0.85rem 1.5rem;
        }

        .info-item {
            display: flex;
            flex-direction: column;
            gap: 0.2rem;
        }

        .info-label {
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-weight: 800;
            color: var(--text-muted);
        }

        .info-value {
            font-size: 0.95rem;
            color: var(--cerritos-dark);
            font-weight: 600;
        }

        .career-chips {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
        }

        .career-chip {
            background: #f0f7ff;
            color: var(--cerritos-blue);
            border: 2px solid var(--cerritos-blue);
            font-weight: 800;
            padding: 0.4rem 0.75rem;
            border-radius: 6px;
            font-size: 0.9rem;
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
        }

        .career-chip svg {
            width: 14px;
            height: 14px;
            fill: currentColor;
        }

        .major-highlight {
            background: #ffffff;
            padding: 0.2rem 0;
        }

        .badge-container {
            margin-top: 0.75rem;
            margin-bottom: 0.75rem;
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
        }

        /* High Contrast AAA/AA Compliant Badges with SVGs */
        .badge {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            background: #f1f5f9;
            color: #0f172a;
            padding: 0.35rem 0.65rem;
            border-radius: 4px;
            font-size: 0.8rem;
            font-weight: 800;
            border: 1px solid #475569;
        }

        .badge svg {
            width: 14px;
            height: 14px;
            fill: currentColor;
            flex-shrink: 0;
        }

        .badge-transfer { background: #002b49; color: #ffffff; border-color: #001d32; }
        .badge-type { background: #dcfce7; color: #14532d; border-color: #16a34a; }
        .badge-cat { background: #e0f2fe; color: #0c4a6e; border-color: #0284c7; }
        .badge-req { background: #fff3d1; color: #5c4100; border-color: var(--cerritos-gold); }

        .description-text {
            margin-top: 0.75rem;
            font-size: 0.9rem;
            color: var(--text-muted);
            line-height: 1.5;
            background: #f8fafc;
            padding: 0.85rem 1rem;
            border-radius: 6px;
            border: 1px solid #cbd5e1;
            border-top: 3px solid var(--cerritos-blue);
        }

        .button-group {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-top: 2px solid #cbd5e1;
            padding-top: 1.25rem;
            margin-top: 1.5rem;
        }

        .btn {
            background-color: var(--cerritos-blue);
            color: #ffffff;
            border: 2px solid var(--cerritos-blue);
            padding: 0.75rem 1.5rem;
            font-size: 1rem;
            font-weight: 800;
            border-radius: 6px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: background-color 0.2s ease;
        }

        .btn:hover {
            background-color: #001d32;
            border-color: #001d32;
        }

        .btn-secondary {
            background-color: #f1f5f9;
            color: var(--cerritos-blue);
            border: 2px solid var(--cerritos-blue);
        }

        .btn-secondary:hover {
            background-color: var(--cerritos-blue);
            color: #ffffff;
        }

        .btn:focus,
        a:focus {
            outline: 3px solid var(--focus-outline) !important;
            outline-offset: 3px !important;
        }

        .error-banner {
            background: #fef2f2;
            color: #991b1b;
            padding: 0.75rem 1rem;
            border: 2px solid #991b1b;
            border-radius: 6px;
            margin: 0 1rem;
            font-size: 0.9rem;
            font-weight: 700;
        }

        /* PRINT STYLES */
        @media print {
            @page {
                size: letter;
                margin: 0.4in;
            }
            body {
                background: #ffffff !important;
                color: #000000 !important;
            }
            header, .button-group, .step-indicator {
                display: none !important;
            }
            .container {
                max-width: 100% !important;
                margin: 0 !important;
                padding: 0 !important;
                border: none !important;
                box-shadow: none !important;
            }
            .summary-card {
                border: 1px solid #000000 !important;
                padding: 0.5rem 0.75rem !important;
                margin-bottom: 0.5rem !important;
            }
        }
    </style>
</head>
<body>

<header role="banner">
    <h1>Cerritos College Career Exploration</h1>
    <span class="step-indicator">Summary &amp; Review</span>
</header>

<main class="container" id="main-content">
    <div class="header-box">
        <h2>Review Your Selections</h2>
        <p class="subtext">Please review your information and chosen pathways before submitting.</p>
    </div>
    
    <section class="summary-card" aria-labelledby="applicant-heading">
        <h3 id="applicant-heading">Applicant Details</h3>
        <div class="info-grid">
            <div class="info-item">
                <span class="info-label">Full Name</span>
                <span class="info-value"><?php echo htmlspecialchars($full_name); ?></span>
            </div>
            <div class="info-item">
                <span class="info-label">Email Address</span>
                <span class="info-value"><?php echo htmlspecialchars($email); ?></span>
            </div>
            <div class="info-item">
                <span class="info-label">Learning Career Pathway</span>
                <span class="info-value"><?php echo htmlspecialchars($lcp); ?></span>
            </div>
            <div class="info-item">
                <span class="info-label">RIASEC Assessment Code</span>
                <span class="info-value"><?php echo htmlspecialchars($riasec_display); ?></span>
            </div>
            <div class="info-item">
                <span class="info-label">Educational Goal</span>
                <span class="info-value"><?php echo htmlspecialchars($education_level_display); ?></span>
            </div>
        </div>
    </section>

    <section class="summary-card" aria-labelledby="careers-heading">
        <h3 id="careers-heading">Selected Career(s)</h3>
        <?php if (!empty($selected_careers)): ?>
            <div class="career-chips">
                <?php foreach ($selected_careers as $career): ?>
                    <span class="career-chip">
                        <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M20 6h-4V4c0-1.11-.89-2-2-2h-4c-1.11 0-2 .89-2 2v2H4c-1.11 0-1.99.89-1.99 2L2 19c0 1.11.89 2 2 2h16c1.11 0 2-.89 2-2V8c0-1.11-.89-2-2-2zm-6 0h-4V4h4v2z"/></svg>
                        <?php echo htmlspecialchars($career); ?>
                    </span>
                <?php endforeach; ?>
            </div>
        <?php else: ?>
            <p style="color: var(--text-muted); margin: 0; font-style: italic; font-size: 0.9rem;">No specific careers selected.</p>
        <?php endif; ?>
    </section>

    <section class="summary-card" aria-labelledby="major-heading">
        <h3 id="major-heading">Selected Academic Major</h3>
        <div class="major-highlight">
            <div class="info-grid">
                <div class="info-item">
                    <span class="info-label">Program / Major</span>
                    <span class="info-value" style="font-size: 1rem; color: var(--cerritos-blue); font-weight: 800;"><?php echo htmlspecialchars($selected_major); ?></span>
                </div>
                <div class="info-item">
                    <span class="info-label">Credential Type</span>
                    <span class="info-value"><?php echo htmlspecialchars($selected_credential_type); ?></span>
                </div>
            </div>

            <!-- Badges -->
            <div class="badge-container">
                <?php if (!empty($major_details['is_adt'])): ?>
                    <span class="badge badge-transfer">
                        <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M12 3L1 9l11 6 9-4.91V17h2V9L12 3zm0 13.5l-7-3.82v3.82c0 2.21 3.13 4 7 4s7-1.79 7-4v-3.82l-7 3.82z"/></svg>
                        Guaranteed Transfer (ADT)
                    </span>
                <?php endif; ?>
                <?php if (!empty($selected_credential_type) && $selected_credential_type !== 'Not Specified'): ?>
                    <span class="badge badge-type">
                        <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-5 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/></svg>
                        Credential: <?php echo htmlspecialchars($selected_credential_type); ?>
                    </span>
                <?php endif; ?>
                <?php if (!empty($major_details['category'])): ?>
                    <span class="badge badge-cat">
                        <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M10 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2h-8l-2-2z"/></svg>
                        Category: <?php echo htmlspecialchars($major_details['category']); ?>
                    </span>
                <?php endif; ?>
                <?php if (!empty($major_details['degree_required'])): ?>
                    <span class="badge badge-req">
                        <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M18 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zM6 4h5v8l-2.5-1.5L6 12V4z"/></svg>
                        Degree Required: <?php echo htmlspecialchars($major_details['degree_required']); ?>
                    </span>
                <?php endif; ?>
            </div>

            <!-- Program Description -->
            <?php if (!empty($major_details['description'])): ?>
                <div class="description-text">
                    <strong style="color: var(--cerritos-blue);">Program Description:</strong><br>
                    <?php echo htmlspecialchars($major_details['description']); ?>
                </div>
            <?php endif; ?>
        </div>
    </section>

    <nav class="button-group" aria-label="Form Navigation">
        <a href="majors.php" class="btn btn-secondary"><span aria-hidden="true">&larr;</span> Back to Majors</a>
        
        <?php if (!empty($submission_error)): ?>
            <div class="error-banner" role="alert">
                <?php echo htmlspecialchars($submission_error); ?>
            </div>
            <?php if (!empty(private_config()['debug_submission_errors']) && !empty($GLOBALS['google_submission_diagnostic'])): ?>
                <pre style="color: #7f1d1d; white-space: pre-wrap; max-width: 42rem; font-size: 0.75rem;"><?php echo htmlspecialchars($GLOBALS['google_submission_diagnostic']); ?></pre>
            <?php endif; ?>
        <?php endif; ?>

        <form method="POST" action="" style="margin: 0;">
            <input type="hidden" name="action" value="finish_complete">
            <?php echo csrf_field(); ?>
            <button type="submit" class="btn">Finish &amp; Submit</button>
        </form>
    </nav>
</main>

</body>
</html>