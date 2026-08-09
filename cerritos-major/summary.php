<?php
// Prevent browser caching
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Pragma: no-cache");

session_start();

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

// Ensure data/applicant_ data exists
if (!isset($_SESSION['applicant'])) {
    header('Location: index.php');
    exit;
}

$applicant = $_SESSION['applicant'];
$selected_careers = $applicant['selected_careers'] ?? $_SESSION['selected_careers'] ?? [];
$selected_major = $applicant['selected_major'] ?? $_SESSION['selected_major'] ?? 'Not specified';
$selected_credential_type = $applicant['selected_credential_type'] ?? $_SESSION['selected_credential_type'] ?? 'Not specified';
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
        Congratulations! Your career exploration profile and major selection have been successfully saved.
    </div>

    <div class="summary-section">
        <h3>Personal Information</h3>
        <div class="data-row">
            <div class="data-label">First Name:</div>
            <div class="data-value"><?php echo htmlspecialchars($applicant['first_name'] ?? ''); ?></div>
        </div>
        <div class="data-row" style="border: none;">
            <div class="data-label">Email:</div>
            <div class="data-value"><?php echo htmlspecialchars($applicant['email'] ?? ''); ?></div>
        </div>
    </div>

    <div class="summary-section">
        <h3>Selected Careers (Top 3)</h3>
        <?php if (!empty($selected_careers)): ?>
            <ul>
                <?php foreach ($selected_careers as $career): ?>
                    <li><?php echo htmlspecialchars($career); ?></li>
                <?php endforeach; ?>
            </ul>
        <?php else: ?>
            <p style="margin: 0; color: #666;">No careers selected.</p>
        <?php endif; ?>
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