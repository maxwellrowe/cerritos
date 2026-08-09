<?php
// Prevent browser caching
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Pragma: no-cache");

session_start();

// Ensure applicant data exists, otherwise redirect to start[cite: 9]
if (!isset($_SESSION['applicant'])) {
    header('Location: index.php');
    exit;
}

// Handle Form Submission for Goals (Page 3)[cite: 9]
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'submit_goals') {
    $top_priority = trim($_POST['top_priority'] ?? '');
    
    // Store in session[cite: 9]
    $_SESSION['applicant_goals'] = [
        'top_priority' => $top_priority,
        'last_updated' => date('Y-m-d H:i:s')
    ];
    
    // Retrieve current applicant info from session[cite: 9]
    $applicant = $_SESSION['applicant'];
    $firstName = $applicant['first_name'] ?? '';
    $lastName = $applicant['last_name'] ?? '';
    $birthDate = $applicant['birth_date'] ?? '';
    $email = $applicant['email'] ?? '';
    $currentTime = date('Y-m-d H:i:s');
    
    // Construct filenames[cite: 9]
    $safeFirst = preg_replace('/[^a-zA-Z0-9_-]/', '', strtolower($firstName));
    $safeLast = preg_replace('/[^a-zA-Z0-9_-]/', '', strtolower($lastName));
    $safeEmail = preg_replace('/[^a-zA-Z0-9_-]/', '', strtolower($email));
    $personalizedFilename = "data/applicant_{$safeFirst}_{$safeLast}_{$safeEmail}.json";
    $historyFilename = "data/applicant_history.json";
    
    // Update personal file data[cite: 9]
    $personalData = [];
    if (file_exists($personalizedFilename)) {
        $decodedPersonal = json_decode(file_get_contents($personalizedFilename), true);
        if (is_array($decodedPersonal)) {
            $personalData = $decodedPersonal;
        }
    }
    
    // Save goals and priorities[cite: 9]
    $personalData['goals_and_priorities'] = [
        'top_priority' => $top_priority,
        'last_completed' => $currentTime
    ];
    $personalData['last_updated'] = $currentTime;
    
    // Ensure basic identification fields are preserved[cite: 9]
    $personalData['first_name'] = $firstName;
    $personalData['last_name'] = $lastName;
    $personalData['birth_date'] = $birthDate;
    $personalData['email'] = $email;
    
    file_put_contents($personalizedFilename, json_encode($personalData, JSON_PRETTY_PRINT));
    
    // Update session data[cite: 9]
    $_SESSION['applicant'] = $personalData;
    
    // Update global data/applicant_history.json[cite: 9]
    $historyData = [];
    if (file_exists($historyFilename)) {
        $decodedHistory = json_decode(file_get_contents($historyFilename), true);
        if (is_array($decodedHistory)) {
            $historyData = $decodedHistory;
        }
    }
    
    // Match record in history using name, email, and date of birth[cite: 9]
    $foundIndex = -1;
    foreach ($historyData as $idx => $record) {
        if (
            strcasecmp(trim($record['first_name'] ?? ''), $firstName) === 0 &&
            strcasecmp(trim($record['last_name'] ?? ''), $lastName) === 0 &&
            trim($record['email'] ?? '') === $email &&
            trim($record['birth_date'] ?? '') === $birthDate
        ) {
            $foundIndex = $idx;
            break;
        }
    }
    
    if ($foundIndex !== -1) {
        $historyData[$foundIndex] = $personalData;
    } else {
        $historyData[] = $personalData;
    }
    
    file_put_contents($historyFilename, json_encode($historyData, JSON_PRETTY_PRINT));
    
    // Conditional routing based on top priority / LCP choice
    $lcp_choice = $applicant['lcp'] ?? '';
    if ($top_priority === 'My career that matches my interests' || $lcp_choice === 'Exploration & Discovery') {
        header('Location: interest_inventory.php');
        exit;
    } else {
        header('Location: career_selection.php');
        exit;
    }
}

$goal_questions = [
    'matches_interests' => 'My career that matches my interests',
    'high_earning' => 'My career has high earning potential',
    'strong_growth' => 'My career has strong growth potential',
    'quick_start' => 'My career that I can start quickly without much training'
];
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cerritos College - Goals & Priorities</title>
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
            max-width: 850px;
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
        .priority-section {
            background: #f0f6fc;
            border: 2px solid var(--cerritos-blue);
            padding: 1.5rem;
            border-radius: 8px;
            margin-top: 1rem;
            margin-bottom: 2rem;
        }
        .priority-option {
            display: block;
            margin-bottom: 0.75rem;
            font-size: 0.95rem;
            cursor: pointer;
            color: #333;
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
    <span class="step-indicator">Goals & Priorities</span>
</header>

<div class="container">
    <form method="POST" action="goals.php">
        <input type="hidden" name="action" value="submit_goals">
        
        <h2>Career Priority</h2>
        
        <div class="priority-section">
            <h3 style="color: var(--cerritos-blue); margin-top: 0;">Forced Choice Priority</h3>
            <p style="font-size: 0.9rem; color: #555; margin-bottom: 1rem;">If you had to pick only <strong>one</strong> of these options that you care about the most, which would it be?</p>
            
            <?php 
            $current_priority = $_SESSION['applicant_goals']['top_priority'] ?? '';
            foreach ($goal_questions as $key => $label): 
            ?>
                <label class="priority-option">
                    <input type="radio" name="top_priority" value="<?php echo htmlspecialchars($label); ?>" <?php echo ($current_priority === $label) ? 'checked' : ''; ?> required>
                    <?php echo htmlspecialchars($label); ?>
                </label>
            <?php endforeach; ?>
        </div>
        
        <div class="button-group">
            <a href="lcp.php" class="btn btn-secondary">&larr; Back to Pathways</a>
            <button type="submit" class="btn">Save & Continue &rarr;</button>
        </div>
    </form>
</div>

</body>
</html>