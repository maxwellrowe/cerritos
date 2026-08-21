<?php
// Prevent browser caching
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Pragma: no-cache");

require_once __DIR__ . '/app_bootstrap.php';

// Ensure applicant data exists, otherwise redirect to start
if (!isset($_SESSION['applicant']) || empty($_SESSION['applicant']['email'])) {
    header('Location: index.php');
    exit;
}

// Handle Form Submission for Education Level
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'submit_education') {
    require_valid_csrf();
    $goal_type = trim($_POST['goal_type'] ?? '');
    $currentTime = date('Y-m-d H:i:s');
    
    // Store in session using goal_type
    $_SESSION['applicant_education'] = [
        'goal_type' => $goal_type,
        'last_updated' => $currentTime
    ];

    $_SESSION['applicant']['education_goal'] = [
        'goal_type' => $goal_type,
        'last_completed' => $currentTime
    ];
    
    // Original conditional routing logic based on goals/LCP
    $applicant = $_SESSION['applicant'];
    $top_priority = $_SESSION['applicant_goals']['top_priority'] ?? '';
    $lcp_choice = $applicant['lcp'] ?? '';
    
    if ($top_priority === 'My career that matches my interests' || $lcp_choice === 'Exploration & Discovery') {
        header('Location: interest_inventory.php');
        exit;
    } else {
        header('Location: career_selection.php');
        exit;
    }
}

$education_options = [
    'Certificate program — typically completed in less than 1 year to 2 years' => 'Certificate program — typically completed in less than 1 year to 2 years',
    'Associate degree — typically completed in about 2 years' => 'Associate degree — typically completed in about 2 years',
    'Bachelor’s degree — typically completed in about 4 years' => 'Bachelor’s degree — typically completed in about 4 years',
    'Graduate or professional degree — typically completed in more than 4 years' => 'Graduate or professional degree — typically completed in more than 4 years',
    'Undecided / Not sure' => 'Undecided / Not sure'
];
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cerritos College - Education Goal</title>
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
        .education-section {
            background: #f0f6fc;
            border: 2px solid var(--cerritos-blue);
            padding: 1.5rem;
            border-radius: 8px;
            margin-top: 1rem;
            margin-bottom: 2rem;
        }
        .education-option {
            display: block;
            margin-bottom: 0.85rem;
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
    <span class="step-indicator">Education Goal (2 of 2)</span>
</header>

<div class="container">
    <form method="POST" action="education_level.php">
        <input type="hidden" name="action" value="submit_education">
        <?php echo csrf_field(); ?>
        
        <h2>Education Level</h2>
        
        <div class="education-section">
            <p style="font-size: 0.9rem; color: #555; margin-bottom: 1rem;">What is the highest level of education you plan to complete?</p>
            
            <?php 
            $current_education = $_SESSION['applicant_education']['goal_type'] ?? '';
            foreach ($education_options as $value => $label): 
            ?>
                <label class="education-option">
                    <input type="radio" name="goal_type" value="<?php echo htmlspecialchars($value); ?>" <?php echo ($current_education === $value) ? 'checked' : ''; ?> required>
                    <?php echo htmlspecialchars($label); ?>
                </label>
            <?php endforeach; ?>
        </div>
        
        <div class="button-group">
            <a href="goals.php" class="btn btn-secondary">&larr; Back to Goals</a>
            <button type="submit" class="btn">Save & Continue &rarr;</button>
        </div>
    </form>
</div>

</body>
</html>