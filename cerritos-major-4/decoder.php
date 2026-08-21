<?php
// decoder.php - Restricted Admin Tool
require_once __DIR__ . '/vendor/autoload.php';
require_once __DIR__ . '/app_bootstrap.php';

header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

// This tool must have explicit credentials configured by the server. It has no
// default password and therefore remains unavailable until configured.
$adminUser = configured_value('DECODER_ADMIN_USERNAME', 'decoder_admin_username');
$adminPassword = configured_value('DECODER_ADMIN_PASSWORD', 'decoder_admin_password');
if ($adminUser === '' || $adminPassword === '' ||
    !isset($_SERVER['PHP_AUTH_USER'], $_SERVER['PHP_AUTH_PW']) ||
    !hash_equals($adminUser, (string) $_SERVER['PHP_AUTH_USER']) ||
    !hash_equals($adminPassword, (string) $_SERVER['PHP_AUTH_PW'])) {
    header('WWW-Authenticate: Basic realm="Restricted"');
    http_response_code(401);
    exit('Authentication required.');
}

function decryptData($base64Data) {
$hexKey = configured_value('PII_ENCRYPTION_KEY', 'pii_encryption_key');
    if (!$hexKey) {
        return "[Error: Key Missing]";
    }

    $key = hex2bin($hexKey);
    $decoded = base64_decode($base64Data);

    // Extract IV (12 bytes), Tag (16 bytes), and Ciphertext
    $iv = substr($decoded, 0, 12);
    $tag = substr($decoded, 12, 16);
    $cipherText = substr($decoded, 28);

    $plainText = openssl_decrypt(
        $cipherText,
        'aes-256-gcm',
        $key,
        OPENSSL_RAW_DATA,
        $iv,
        $tag
    );

    return $plainText !== false ? $plainText : "[Decryption Failed]";
}

// Fetch encrypted rows from Google Sheets. Prefer a server environment secret;
// the PHP credential file is a temporary local-development fallback only.
$jsonKeyRaw = getenv('GOOGLE_SERVICE_ACCOUNT_JSON') ?: ($_ENV['GOOGLE_SERVICE_ACCOUNT_JSON'] ?? '');
$jsonKey = $jsonKeyRaw ? json_decode($jsonKeyRaw, true, 512, JSON_THROW_ON_ERROR) : null;
if (!$jsonKey) {
    $credentialsFile = getenv('GOOGLE_CREDENTIALS_FILE') ?: (__DIR__ . '/google_credentials.php');
    if (!is_file($credentialsFile)) {
        http_response_code(500);
        exit('Google service-account credentials are not configured.');
    }
    $jsonKey = require $credentialsFile;
}

$client = new Google\Client();
$client->setHttpClient(new GuzzleHttp\Client(['verify' => true]));
$client->setAuthConfig($jsonKey);
$client->addScope(Google\Service\Sheets::SPREADSHEETS);

$service = new Google\Service\Sheets($client);
$spreadsheetId = configured_value('GOOGLE_SPREADSHEET_ID', 'google_spreadsheet_id');
if ($spreadsheetId === '') {
    http_response_code(500);
    exit('GOOGLE_SPREADSHEET_ID is not configured.');
}
$response = $service->spreadsheets_values->get($spreadsheetId, 'Sheet1!A:L');
$rows = $response->getValues() ?? [];

echo "<h2>Decrypted Applicant Submissions</h2>";
echo "<table border='1' cellpadding='8' cellspacing='0'>";
echo "<tr><th>Timestamp</th><th>First Name</th><th>Last Name</th><th>Email</th><th>Pathway</th><th>Careers</th><th>Major & Credential</th><th>RIASEC</th></tr>";

foreach ($rows as $index => $row) {
    // Skip header row if present
    if ($index === 0 && strtolower($row[0]) === 'timestamp') {
        continue;
    }

    $timestamp = htmlspecialchars($row[0] ?? '');
    $firstName = htmlspecialchars(decryptData($row[1] ?? ''), ENT_QUOTES, 'UTF-8');
    $lastName  = htmlspecialchars(decryptData($row[2] ?? ''), ENT_QUOTES, 'UTF-8');
    $email     = htmlspecialchars(decryptData($row[3] ?? ''), ENT_QUOTES, 'UTF-8');
    $pathway   = htmlspecialchars(decryptData($row[4] ?? ''), ENT_QUOTES, 'UTF-8');
    $careers   = htmlspecialchars(implode(', ', array_filter([
        decryptData($row[6] ?? ''), decryptData($row[7] ?? ''), decryptData($row[8] ?? '')
    ])), ENT_QUOTES, 'UTF-8');
    $major     = htmlspecialchars(trim(decryptData($row[9] ?? '') . ' — ' . decryptData($row[10] ?? '')), ENT_QUOTES, 'UTF-8');
    $riasec    = htmlspecialchars(decryptData($row[11] ?? ''), ENT_QUOTES, 'UTF-8');

    echo "<tr>
            <td>{$timestamp}</td>
            <td>{$firstName}</td>
            <td>{$lastName}</td>
            <td>{$email}</td>
            <td>{$pathway}</td>
            <td>{$careers}</td>
            <td>{$major}</td>
            <td>{$riasec}</td>
          </tr>";
}
echo "</table>";
