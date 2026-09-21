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

// Handle Form Submission for Goals (Page 3)
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'submit_goals') {
    require_valid_csrf();
    $top_priority = trim($_POST['top_priority'] ?? '');
    $currentTime = date('Y-m-d H:i:s');
    
    // Store in session
    $_SESSION['applicant_goals'] = [
        'top_priority' => $top_priority,
        'last_updated' => $currentTime
    ];

    $_SESSION['applicant']['goals_and_priorities'] = [
        'top_priority' => $top_priority,
        'last_completed' => $currentTime
    ];
    
    // Proceed to the new education level step
    header('Location: education_level.php');
    exit;
}

$goal_questions = [
    'matches_interests' => [
        'label' => 'My career that matches my interests',
        'icon' => '🎯'
    ],
    'high_earning' => [
        'label' => 'My career has high earning potential',
        'icon' => '💰'
    ],
    'strong_growth' => [
        'label' => 'My career has strong growth potential',
        'icon' => '📈'
    ],
    'quick_start' => [
        'label' => 'My career that I can start quickly without much training',
        'icon' => '⚡'
    ]
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
            /* WCAG AAA/AA compliant high-contrast color palette */
            --cerritos-blue: #002b49;
            --cerritos-gold: #8a6200;
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

        /* Screen reader utility class */
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
        
        .priority-fieldset {
            border: none;
            padding: 0;
            margin: 0;
        }
        .priority-instruction {
            font-size: 1rem;
            color: var(--cerritos-dark);
            margin-top: 0;
            margin-bottom: 1.25rem;
            line-height: 1.4;
        }
        
        /* Grid layout to fit options neatly on a single screen view */
        .priority-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 1rem;
            margin-bottom: 1.5rem;
        }

        /* Large, prominent card-button options */
        .priority-card {
            appearance: none;
            -webkit-appearance: none;
            font-family: inherit;
            text-align: left;
            width: 100%;
            background: #ffffff;
            border: 2px solid #595959; /* Clear border for visual and color-blind clarity */
            border-radius: 8px;
            padding: 1.25rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-sizing: border-box;
            transition: border-color 0.2s ease, background-color 0.2s ease, box-shadow 0.2s ease;
        }
        .priority-card:hover {
            border-color: var(--cerritos-blue);
            background-color: #f0f6fc;
            box-shadow: 0 4px 10px rgba(0, 43, 73, 0.12);
        }
        .priority-card:focus {
            outline: 3px solid var(--focus-outline);
            outline-offset: 3px;
        }
        
        .card-content {
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        .card-icon {
            font-size: 2rem;
            flex-shrink: 0;
        }
        .card-label {
            font-size: 1.05rem;
            font-weight: bold;
            color: var(--cerritos-blue);
            line-height: 1.3;
        }
        .card-arrow {
            font-size: 1.25rem;
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
    <span class="step-indicator">Goals & Priorities (1 of 2)</span>
</header>

<main class="container">
    <form method="POST" action="goals.php" id="goalsForm">
        <input type="hidden" name="action" value="submit_goals">
        <?php echo csrf_field(); ?>
        <input type="hidden" name="top_priority" id="selectedPriorityInput" value="">
        
        <h2>Career Priority</h2>
        
        <fieldset class="priority-fieldset">
            <legend class="sr-only">Select Your Top Career Priority</legend>
            <p id="priority-desc" class="priority-instruction">
                If you had to pick only <strong>one</strong> of these options that you care about the most, select it below to proceed:
            </p>
            
            <div class="priority-grid">
                <?php foreach ($goal_questions as $key => $item): ?>
                    <button 
                        type="button" 
                        class="priority-card" 
                        onclick="selectAndSubmit('<?php echo htmlspecialchars($item['label'], ENT_QUOTES); ?>')"
                        aria-describedby="priority-desc"
                    >
                        <span class="card-content">
                            <span class="card-icon" aria-hidden="true"><?php echo $item['icon']; ?></span>
                            <span class="card-label"><?php echo htmlspecialchars($item['label']); ?></span>
                        </span>
                        <span class="card-arrow" aria-hidden="true">&rarr;</span>
                    </button>
                <?php endforeach; ?>
            </div>
        </fieldset>
        
        <div class="button-group">
            <a href="lcp.php" class="btn-secondary">
                <span aria-hidden="true">&larr;</span> Back to Pathways
            </a>
        </div>
    </form>
</main>

<script>
function selectAndSubmit(priorityValue) {
    document.getElementById('selectedPriorityInput').value = priorityValue;
    document.getElementById('goalsForm').submit();
}
</script>

</body>
</html>