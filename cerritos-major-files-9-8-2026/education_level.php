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

    // Store as education_level so summary.php can read it directly
    $_SESSION['education_level'] = $goal_type;
    $_SESSION['applicant']['education_level'] = $goal_type;

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
    [
        'title' => 'Certificate Program',
        'duration' => 'Typically completed in less than 1 year to 2 years',
        'icon' => '📜',
        'value' => 'Certificate program — typically completed in less than 1 year to 2 years'
    ],
    [
        'title' => 'Associate Degree',
        'duration' => 'Typically completed in about 2 years',
        'icon' => '🎓',
        'value' => 'Associate degree — typically completed in about 2 years'
    ],
    [
        'title' => 'Bachelor’s Degree',
        'duration' => 'Typically completed in about 4 years',
        'icon' => '🏛️',
        'value' => 'Bachelor’s degree — typically completed in about 4 years'
    ],
    [
        'title' => 'Graduate / Professional Degree',
        'duration' => 'Typically completed in more than 4 years',
        'icon' => '🩺',
        'value' => 'Graduate or professional degree — typically completed in more than 4 years'
    ],
    [
        'title' => 'Undecided / Not Sure',
        'duration' => 'Explore options and decide as you go',
        'icon' => '🤔',
        'value' => 'Undecided / Not sure'
    ]
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
            /* WCAG AAA/AA compliant high-contrast color palette */
            --cerritos-blue: #002b49;
            --cerritos-gold: #8a6200; /* Darkened gold for 4.5:1 ratio against light backgrounds */
            --cerritos-dark: #222222;
            --cerritos-light: #f4f6f9;
            --focus-outline: #005fcc;
        }
        body {
            font-family: Arial, sans-serif, Helvetica;
            background-color: var(--cerritos-light);
            color: var(--cerritos-dark);
            margin: 0;
            padding: 0;
        }

        /* Visually hidden screen reader utility class */
        .sr-only {
            position: absolute;
            width: 1px;
            height: 1px;
            padding: 0;
            margin: -1px;
            overflow: hidden;
            clip: rect(0, 0, 0, 0);
            white-space: nowrap;
            border: 0;
        }

        header {
            background-color: var(--cerritos-blue);
            color: #ffffff;
            padding: 1rem 2rem;
            border-bottom: 5px solid #ffc72c;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        header h1 {
            font-size: 1.5rem;
            margin: 0;
        }
        .step-indicator {
            font-size: 0.95rem;
            background: rgba(255,255,255,0.2);
            padding: 0.4rem 0.8rem;
            border-radius: 4px;
            color: #ffffff;
        }
        main {
            max-width: 850px;
            margin: 1.5rem auto;
            background: #ffffff;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        h2 {
            color: var(--cerritos-blue);
            border-bottom: 3px solid var(--cerritos-gold);
            padding-bottom: 0.5rem;
            margin-top: 0;
            margin-bottom: 0.75rem;
        }
        
        .education-fieldset {
            border: none;
            padding: 0;
            margin: 0;
        }
        .education-instruction {
            font-size: 1rem;
            color: var(--cerritos-dark);
            margin-top: 0;
            margin-bottom: 1.25rem;
            line-height: 1.4;
        }
        
        /* Compact layout to keep all options on a single screen */
        .education-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 0.85rem;
            margin-bottom: 1.25rem;
        }

        /* High-contrast, large target button cards */
        .education-card {
            appearance: none;
            -webkit-appearance: none;
            font-family: inherit;
            text-align: left;
            width: 100%;
            background: #ffffff;
            border: 2px solid #595959; /* Strong outline for visual and color-blind clarity */
            border-radius: 8px;
            padding: 1rem 1.15rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-sizing: border-box;
            transition: border-color 0.2s ease, background-color 0.2s ease, box-shadow 0.2s ease;
        }
        .education-card:hover {
            border-color: var(--cerritos-blue);
            background-color: #f0f6fc;
            box-shadow: 0 4px 10px rgba(0, 43, 73, 0.12);
        }
        .education-card:focus {
            outline: 3px solid var(--focus-outline);
            outline-offset: 3px;
        }
        
        .card-content {
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        .card-icon {
            font-size: 1.8rem;
            flex-shrink: 0;
        }
        .card-text {
            display: flex;
            flex-direction: column;
        }
        .card-title {
            font-size: 1rem;
            font-weight: bold;
            color: var(--cerritos-blue);
            line-height: 1.25;
            margin-bottom: 0.2rem;
        }
        .card-duration {
            font-size: 0.85rem;
            color: #333333;
            line-height: 1.3;
        }
        .card-arrow {
            font-size: 1.2rem;
            font-weight: bold;
            color: var(--cerritos-blue);
            margin-left: 0.5rem;
            flex-shrink: 0;
        }

        .button-group {
            display: flex;
            justify-content: flex-start;
            align-items: center;
            border-top: 1px solid #767676;
            padding-top: 1.25rem;
        }
        .btn-secondary {
            background-color: #f0f4f8;
            color: var(--cerritos-blue);
            border: 2px solid var(--cerritos-blue);
            padding: 0.6rem 1.25rem;
            font-size: 0.95rem;
            font-weight: bold;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: background-color 0.2s ease, color 0.2s ease;
        }
        .btn-secondary:hover {
            background-color: var(--cerritos-blue);
            color: #ffffff;
        }
        .btn-secondary:focus {
            outline: 3px solid var(--focus-outline);
            outline-offset: 3px;
        }
    </style>
</head>
<body>

<header>
    <h1>Cerritos College Career Exploration</h1>
    <span class="step-indicator">Education Goal (2 of 2)</span>
</header>

<main class="container">
    <form method="POST" action="education_level.php" id="educationForm">
        <input type="hidden" name="action" value="submit_education">
        <?php echo csrf_field(); ?>
        <input type="hidden" name="goal_type" id="selectedGoalInput" value="">
        
        <h2>Education Level</h2>
        
        <fieldset class="education-fieldset">
            <legend class="sr-only">Select Your Education Level</legend>
            <p id="education-desc" class="education-instruction">
                What is the highest level of education you plan to complete? Select an option below to proceed:
            </p>
            
            <div class="education-grid">
                <?php foreach ($education_options as $item): ?>
                    <button 
                        type="button" 
                        class="education-card" 
                        onclick="selectAndSubmit('<?php echo htmlspecialchars($item['value'], ENT_QUOTES); ?>')"
                        aria-describedby="education-desc"
                    >
                        <span class="card-content">
                            <span class="card-icon" aria-hidden="true"><?php echo $item['icon']; ?></span>
                            <span class="card-text">
                                <span class="card-title"><?php echo htmlspecialchars($item['title']); ?></span>
                                <span class="card-duration"><?php echo htmlspecialchars($item['duration']); ?></span>
                            </span>
                        </span>
                        <span class="card-arrow" aria-hidden="true">&rarr;</span>
                    </button>
                <?php endforeach; ?>
            </div>
        </fieldset>
        
        <div class="button-group">
            <a href="goals.php" class="btn-secondary">
                <span aria-hidden="true">&larr;</span> Back to Goals
            </a>
        </div>
    </form>
</main>

<script>
function selectAndSubmit(goalValue) {
    document.getElementById('selectedGoalInput').value = goalValue;
    document.getElementById('educationForm').submit();
}
</script>

</body>
</html>