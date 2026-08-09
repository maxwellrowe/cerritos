<?php
// Prevent browser caching of personal applicant data
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

session_start();

// Handle Form Submission for Page 1
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'step_1') {
    $firstName = trim($_POST['first_name'] ?? '');
    $lastName = trim($_POST['last_name'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $currentTime = date('Y-m-d H:i:s');
    
    // Sanitize names and email for filename construction
    $safeFirst = preg_replace('/[^a-zA-Z0-9_-]/', '', strtolower($firstName));
    $safeLast = preg_replace('/[^a-zA-Z0-9_-]/', '', strtolower($lastName));
    $safeEmail = preg_replace('/[^a-zA-Z0-9_-]/', '', strtolower($email));
    $personalizedFilename =  "data/applicant_{$safeFirst}_{$safeLast}_{$safeEmail}.json";
    $historyFilename =  "data/applicant_history.json";
    
    // Load or initialize existing personal record if available
    $existingData = [];
    if (file_exists($personalizedFilename)) {
        $fileContent = file_get_contents($personalizedFilename);
        $decoded = json_decode($fileContent, true);
        if (is_array($decoded)) {
            $existingData = $decoded;
        }
    }
    
    // Determine attempt count and attempts log
    $attempts = $existingData['attempts'] ?? [];
    $attempts[] = [
        'attempt_number' => count($attempts) + 1,
        'timestamp' => $currentTime
    ];
    
    // Build applicant data structure incorporating previous state (interest inventory, goals, LCP, top career choices) if present
    $applicantData = [
        'first_name' => $firstName,
        'last_name' => $lastName,
        'email' => $email,
        'attempt_count' => count($attempts),
        'attempts' => $attempts,
        'interest_inventory' => $existingData['interest_inventory'] ?? [],
        'goals' => $existingData['goals'] ?? [],
        'lcp' => $existingData['lcp'] ?? [],
        'top_career_choices' => $existingData['top_career_choices'] ?? [],
        'last_updated' => $currentTime
    ];
    
    // Save to personalized file
    file_put_contents($personalizedFilename, json_encode($applicantData, JSON_PRETTY_PRINT));
    
    // Update global applicant history file
    $historyData = [];
    if (file_exists($historyFilename)) {
        $historyContent = file_get_contents($historyFilename);
        $decodedHistory = json_decode($historyContent, true);
        if (is_array($decodedHistory)) {
            $historyData = $decodedHistory;
        }
    }
    
    // Match record in history using name and email
    $foundIndex = -1;
    foreach ($historyData as $idx => $record) {
        if (
            strcasecmp(trim($record['first_name'] ?? ''), $firstName) === 0 &&
            strcasecmp(trim($record['last_name'] ?? ''), $lastName) === 0 &&
            trim($record['email'] ?? '') === $email
        ) {
            $foundIndex = $idx;
            break;
        }
    }
    
    if ($foundIndex !== -1) {
        // Update existing history record
        $historyData[$foundIndex] = $applicantData;
    } else {
        // Append new history record
        $historyData[] = $applicantData;
    }
    
    file_put_contents($historyFilename, json_encode($historyData, JSON_PRETTY_PRINT));
    
    // Store session data
    $_SESSION['applicant'] = $applicantData;
    
    // Redirect to Page 2 (Learning and Career Pathways Selection)
    header('Location: lcp.php');
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cerritos College - Career & Major Exploration (Page 1)</title>
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
            max-width: 650px;
            margin: 2.5rem auto;
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
        .form-group {
            margin-bottom: 1.5rem;
        }
        label {
            display: block;
            font-weight: bold;
            margin-bottom: 0.5rem;
            color: var(--cerritos-blue);
        }
        input[type="text"], input[type="email"] {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
            font-size: 1rem;
        }
        input:focus {
            outline: none;
            border-color: var(--cerritos-blue);
            box-shadow: 0 0 5px rgba(0, 43, 73, 0.3);
        }
        .notice-box {
            background-color: #eef3f8;
            border-left: 4px solid var(--cerritos-gold);
            padding: 1rem;
            margin-bottom: 1.5rem;
            font-size: 0.9rem;
            color: #333;
        }
        button {
            background-color: var(--cerritos-blue);
            color: #ffffff;
            border: none;
            padding: 0.75rem 1.5rem;
            font-size: 1rem;
            font-weight: bold;
            border-radius: 4px;
            cursor: pointer;
            width: 100%;
            transition: background-color 0.2s ease;
        }
        button:hover {
            background-color: #001d32;
        }
    </style>
</head>
<body>

<header>
    <h1>Cerritos College Career Exploration</h1>
    <span class="step-indicator">Page 1 of 6</span>
</header>

<div class="container">
    <form method="POST" action="index.php">
        <input type="hidden" name="action" value="step_1">
        
        <h2>Welcome Future Falcon!</h2>
        <p>Let's find the learning and career pathway that aligns with your personal goals and interests.</p>
        
        <div class="notice-box">
            <strong>Important Note:</strong> Please use the email address you enter below consistently for the rest of your college career. For your privacy and security, this information is not saved in browser cache.
        </div>
        
        <div class="form-group">
            <label for="first_name">First Name</label>
            <input type="text" id="first_name" name="first_name" required value="<?php echo htmlspecialchars($_SESSION['applicant']['first_name'] ?? ''); ?>">
        </div>
        
        <div class="form-group">
            <label for="last_name">Last Name</label>
            <input type="text" id="last_name" name="last_name" required value="<?php echo htmlspecialchars($_SESSION['applicant']['last_name'] ?? ''); ?>">
        </div>
        
        <div class="form-group">
            <label for="email">Email Address</label>
            <input type="email" id="email" name="email" required placeholder="your.email@example.com" value="<?php echo htmlspecialchars($_SESSION['applicant']['email'] ?? ''); ?>">
        </div>
        
        <button type="submit">Next: Select Learning & Career Pathway &rarr;</button>
    </form>
</div>

</body>
</html>