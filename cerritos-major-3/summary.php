<?php
// Prevent browser caching
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Pragma: no-cache");

// Display errors for debugging during development
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

session_start();

// Load the Google API Client Library installed via Composer
require_once __DIR__ . '/vendor/autoload.php';

use Google\Client;
use Google\Service\Sheets;
use Google\Service\Sheets\ValueRange;

// Handle reset/return action to clear session
if (isset($_GET['action']) && $_GET['action'] === 'reset') {
    $_SESSION = array();
    if (ini_get("session.use_cookies")) {
        $params = session_get_cookie_params();
        setcookie(session_name(), '', time() - 42000,
            $params["path"], $params["domain"],
            $params["secure"], $params["httponly"]
        );
    }
    session_destroy();
    header('Location: index.php');
    exit;
}

// Ensure applicant data exists
if (!isset($_SESSION['applicant'])) {
    header('Location: index.php');
    exit;
}

$applicant = $_SESSION['applicant'];

// 1. Extract Selected Pathway / LCP
$selected_pathway = $applicant['lcp'] ?? $_SESSION['lcp'] ?? $applicant['selected_pathway'] ?? $_SESSION['selected_pathway'] ?? 'Not specified';
$pathwayString = is_array($selected_pathway) ? implode(', ', $selected_pathway) : $selected_pathway;

// 2. Extract and format RIASEC Code / Profile
$rawRiasec = $applicant['riasec_scores'] 
    ?? $_SESSION['riasec_scores'] 
    ?? $applicant['riasec_code'] 
    ?? $_SESSION['riasec_code'] 
    ?? $applicant['riasec'] 
    ?? $_SESSION['riasec'] 
    ?? '';

if (is_array($rawRiasec)) {
    // Filter out empty entries if any
    $filteredRiasec = array_filter($rawRiasec);
    
    // Check if it's an associative array with scores (e.g., ['Social' => 15, 'Enterprising' => 15])
    if (!empty($filteredRiasec) && array_keys($filteredRiasec) !== range(0, count($filteredRiasec) - 1)) {
        $formattedPairs = [];
        foreach ($filteredRiasec as $key => $val) {
            $formattedPairs[] = "$key: $val";
        }
        $riasecString = implode(', ', $formattedPairs);
    } elseif (!empty($filteredRiasec)) {
        // Indexed array (e.g., ['Social', 'Enterprising', 'Investigative'])
        $riasecString = implode(', ', $filteredRiasec);
    } else {
        $riasecString = 'N/A';
    }
} else {
    $riasecString = !empty($rawRiasec) ? $rawRiasec : 'N/A';
}

// 3. Extract Selected Careers & split into 3 separate variables
$rawCareers = $applicant['selected_careers'] 
    ?? $_SESSION['selected_careers'] 
    ?? $applicant['top_career_choices'] 
    ?? $_SESSION['top_career_choices'] 
    ?? [];

if (is_string($rawCareers)) {
    $selected_careers = array_map('trim', explode(',', $rawCareers));
} else {
    $selected_careers = is_array($rawCareers) ? array_values($rawCareers) : [];
}

// Map exact 3 slots (pads with empty strings if fewer than 3 were selected)
$career1 = $selected_careers[0] ?? '';
$career2 = $selected_careers[1] ?? '';
$career3 = $selected_careers[2] ?? '';

// 4. Extract Major and Credential Type
$selected_major = $applicant['selected_major'] ?? $_SESSION['selected_major'] ?? 'Not specified';
$selected_credential_type = $applicant['selected_credential_type'] ?? $_SESSION['selected_credential_type'] ?? 'Not specified';

// 5. Extract Detailed Inventory Answers
$inventoryAnswers = $applicant['interest_inventory'] ?? $_SESSION['interest_inventory'] ?? [];
$inventoryString = is_array($inventoryAnswers) ? json_encode($inventoryAnswers) : $inventoryAnswers;

// --- GOOGLE SHEETS API INTEGRATION ---
$spreadsheetId = '1-19mTWjH2vl-eeW6z-zlfjxSkv1DbW5hQjQkzzdpZXU';
$credentialsPath = __DIR__ . '/major-selector-credentials.json';

if (file_exists($credentialsPath) && !empty($spreadsheetId)) {
    try {
        $client = new Client();
        $client->setAuthConfig($credentialsPath);
        $client->addScope(Sheets::SPREADSHEETS);

        // Local dev SSL workaround to prevent cURL error 60
        $guzzleClient = new \GuzzleHttp\Client(['verify' => false]);
        $client->setHttpClient($guzzleClient);

        $service = new Sheets($client);

        // Row values mapped across Columns A through L
        $rowValues = [
            date('Y-m-d H:i:s'),            // Column A: Timestamp
            $applicant['first_name'] ?? '', // Column B: First Name
            $applicant['last_name'] ?? '',  // Column C: Last Name
            $applicant['email'] ?? '',      // Column D: Email
            $pathwayString,                 // Column E: Pathway / LCP
            $riasecString,                  // Column F: RIASEC Profile
            $career1,                       // Column G: Career Choice 1
            $career2,                       // Column H: Career Choice 2 (or blank)
            $career3,                       // Column I: Career Choice 3 (or blank)
            $selected_major,                // Column J: Major
            $selected_credential_type,      // Column K: Credential Type
            $inventoryString                // Column L: Detailed Inventory Answers
        ];

        $body = new ValueRange([
            'values' => [$rowValues]
        ]);

        $params = [
            'valueInputOption' => 'USER_ENTERED'
        ];

        // Expands range to A:L for all 12 columns
        $range = 'A:L'; 

        $service->spreadsheets_values->append(
            $spreadsheetId,
            $range,
            $body,
            $params
        );
    } catch (Exception $e) {
        error_log("Google Sheets API Error: " . $e->getMessage());
        echo "<div style='color:red; background:#fee; padding:10px; margin:10px; border:1px solid red;'><strong>Google Sheets API Error:</strong> " . htmlspecialchars($e->getMessage()) . "</div>";
    }
} else {
    if (!file_exists($credentialsPath)) {
        echo "<div style='color:red; background:#fee; padding:10px; margin:10px; border:1px solid red;'><strong>Error:</strong> Credentials file not found at <code>" . htmlspecialchars($credentialsPath) . "</code></div>";
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cerritos College - Application Summary</title>
    <style>
        :root {
            --cerritos-blue: #002b49;
            --cerritos-gold: #ffc72c;
            --cerritos-dark: #333333;
            --cerritos-light: #f4f6f9;
        }
        body {
            font-family: Arial, sans-serif, Helvetica;
            background-color: var(--cerritos-light);
            color: var(--cerritos-dark);
            margin: 0;
            padding: 0;
        }
        header {
            background-color: var(--cerritos-blue);
            color: #ffffff;
            padding: 1rem 2rem;
            border-bottom: 5px solid var(--cerritos-gold);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        header h1 {
            font-size: 1.5rem;
            margin: 0;
        }
        .step-indicator {
            font-size: 0.9rem;
            background: rgba(255,255,255,0.15);
            padding: 0.4rem 0.8rem;
            border-radius: 4px;
        }
        .container {
            max-width: 900px;
            margin: 2rem auto;
            background: #ffffff;
            padding: 2.5rem;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        h2 {
            color: var(--cerritos-blue);
            border-bottom: 2px solid var(--cerritos-gold);
            padding-bottom: 0.5rem;
            margin-top: 0;
        }
        .success-banner {
            background-color: #d4edda;
            color: #155724;
            padding: 1rem 1.25rem;
            border: 1px solid #c3e6cb;
            border-radius: 4px;
            margin-bottom: 1.5rem;
            font-weight: bold;
        }
        .summary-section {
            margin-bottom: 1.5rem;
            border: 1px solid #e1e8ed;
            border-radius: 6px;
            padding: 1.25rem;
            background: #fdfdfd;
        }
        .summary-section h3 {
            margin-top: 0;
            color: var(--cerritos-blue);
            font-size: 1.1rem;
            border-bottom: 1px solid #eee;
            padding-bottom: 0.4rem;
        }
        .data-row {
            display: flex;
            padding: 0.4rem 0;
            border-bottom: 1px solid #f9f9f9;
        }
        .data-label {
            font-weight: bold;
            width: 200px;
            color: #555;
        }
        .data-value {
            flex: 1;
            color: #333;
        }
        ul {
            margin: 0;
            padding-left: 1.2rem;
        }
        .button-group {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-top: 1px solid #eee;
            padding-top: 1.5rem;
            margin-top: 2rem;
        }
        .btn {
            background-color: var(--cerritos-blue);
            color: #ffffff;
            border: none;
            padding: 0.75rem 1.5rem;
            font-size: 1rem;
            font-weight: bold;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            transition: background-color 0.2s ease;
        }
        .btn:hover {
            background-color: #001d32;
        }
        .btn-secondary {
            background-color: #e1e8ed;
            color: var(--cerritos-dark);
        }
        .btn-secondary:hover {
            background-color: #cbd5d9;
        }
    </style>
</head>
<body>

<header>
    <h1>Cerritos College Career Exploration</h1>
    <span class="step-indicator">Application Summary</span>
</header>

<div class="container">
    <h2>Exploration Summary &amp; Submission</h2>

    <div class="success-banner">
        Congratulations! Your career exploration profile and major selection have been saved.
    </div>

    <div class="summary-section">
        <h3>Personal Information</h3>
        <div class="data-row">
            <div class="data-label">First Name:</div>
            <div class="data-value"><?php echo htmlspecialchars($applicant['first_name'] ?? ''); ?></div>
        </div>
        <div class="data-row">
            <div class="data-label">Last Name:</div>
            <div class="data-value"><?php echo htmlspecialchars($applicant['last_name'] ?? ''); ?></div>
        </div>
        <div class="data-row" style="border: none;">
            <div class="data-label">Email:</div>
            <div class="data-value"><?php echo htmlspecialchars($applicant['email'] ?? ''); ?></div>
        </div>
    </div>

    <div class="summary-section">
        <h3>Pathway &amp; Career Assessment</h3>
        <div class="data-row">
            <div class="data-label">Selected Pathway (LCP):</div>
            <div class="data-value"><strong><?php echo htmlspecialchars($pathwayString); ?></strong></div>
        </div>
        <div class="data-row">
            <div class="data-label">RIASEC Profile:</div>
            <div class="data-value"><?php echo htmlspecialchars($riasecString); ?></div>
        </div>
        <div class="data-row" style="border: none;">
            <div class="data-label">Selected Careers:</div>
            <div class="data-value">
                <?php if (!empty($selected_careers)): ?>
                    <ul>
                        <?php foreach ($selected_careers as $career): ?>
                            <li><?php echo htmlspecialchars($career); ?></li>
                        <?php endforeach; ?>
                    </ul>
                <?php else: ?>
                    <em>No careers selected.</em>
                <?php endif; ?>
            </div>
        </div>
    </div>

    <div class="summary-section">
        <h3>Chosen Major / Program</h3>
        <div class="data-row">
            <div class="data-label">Major Program:</div>
            <div class="data-value"><strong><?php echo htmlspecialchars($selected_major); ?></strong></div>
        </div>
        <div class="data-row" style="border: none;">
            <div class="data-label">Credential Type:</div>
            <div class="data-value"><strong><?php echo htmlspecialchars($selected_credential_type); ?></strong></div>
        </div>
    </div>

    <div class="button-group">
        <a href="majors.php" class="btn btn-secondary">&larr; Back to Majors</a>
        <a href="summary.php?action=reset" class="btn" onclick="sessionStorage.clear();">Return to home page</a>
    </div>
</div>

</body>
</html>