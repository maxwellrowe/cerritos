<?php
// Prevent browser caching
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

require_once __DIR__ . '/app_bootstrap.php';

// Check if applicant session exists
if (!isset($_SESSION['applicant']) || empty($_SESSION['applicant']['email'])) {
    header('Location: index.php');
    exit;
}

// 18 Selected Questions (3 per RIASEC code) in Interleaved / Mixed Order
$questions = [
    ["program_id" => 1,  "code" => "R", "description" => "Build, repair, install, or maintain equipment, vehicles, tools, or facilities."],
    ["program_id" => 6,  "code" => "I", "description" => "Analyze data, evidence, symptoms, or patterns to find an answer."],
    ["program_id" => 11, "code" => "A", "description" => "Create visual art, design, music, writing, film, performance, or media."],
    ["program_id" => 16, "code" => "S", "description" => "Teach, tutor, coach, counsel, mentor, or advise other people."],
    ["program_id" => 21, "code" => "E", "description" => "Lead a team, project, business activity, event, or campaign."],
    ["program_id" => 26, "code" => "C", "description" => "Organize records, schedules, budgets, forms, data, or detailed procedures."],

    ["program_id" => 3,  "code" => "R", "description" => "Use machines, tools, instruments, or technical equipment to solve problems."],
    ["program_id" => 8,  "code" => "I", "description" => "Solve math, science, technology, or logic-based problems."],
    ["program_id" => 12, "code" => "A", "description" => "Express ideas in original, imaginative, or unconventional ways."],
    ["program_id" => 17, "code" => "S", "description" => "Help people improve their health, learning, safety, or well-being."],
    ["program_id" => 22, "code" => "E", "description" => "Persuade, negotiate, sell, advocate, or influence decisions."],
    ["program_id" => 27, "code" => "C", "description" => "Use spreadsheets, databases, reports, or information systems accurately."],

    ["program_id" => 5,  "code" => "R", "description" => "Learn by doing hands-on projects rather than mainly reading or discussing."],
    ["program_id" => 10, "code" => "I", "description" => "Ask questions, compare options, and evaluate evidence before deciding."],
    ["program_id" => 14, "code" => "A", "description" => "Tell stories, perform, edit, produce, or communicate through creative work."],
    ["program_id" => 19, "code" => "S", "description" => "Work as part of a service team that supports students, clients, patients, or communities."],
    ["program_id" => 24, "code" => "E", "description" => "Take initiative in competitive, business, public-facing, or leadership settings."],
    ["program_id" => 29, "code" => "C", "description" => "Keep work orderly, complete, documented, and on time."]
];

// RIASEC full names map & valid code definition for validation
$riasec_names = [
    'R' => 'Realistic (The Doer)',
    'I' => 'Investigative (The Thinker)',
    'A' => 'Artistic (The Creator)',
    'S' => 'Social (The Helper)',
    'E' => 'Enterprising (The Persuader)',
    'C' => 'Conventional (The Organizer)'
];

// Check if an existing complete score/response set already exists in session
$has_existing_score = isset($_SESSION['applicant']['riasec_scores']) && !empty($_SESSION['applicant']['riasec_responses']);
$mode = $_GET['mode'] ?? '';

// Handle Keep vs Retake choice submission
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'handle_existing_choice') {
    require_valid_csrf();
    $choice = $_POST['score_choice'] ?? 'keep';
    
    if ($choice === 'retake') {
        header('Location: interest_inventory.php?mode=retake');
        exit;
    } else {
        // Default safe fallback to keep
        header('Location: next_step.php');
        exit;
    }
}

// If in retake mode, clear current active responses so the user starts fresh
if ($mode === 'retake' && !isset($_SESSION['retake_initialized'])) {
    // Archive current score/responses into history if they exist
    if (!empty($_SESSION['applicant']['riasec_responses'])) {
        if (!isset($_SESSION['applicant']['riasec_history'])) {
            $_SESSION['applicant']['riasec_history'] = [];
        }
        $_SESSION['applicant']['riasec_history'][] = [
            'responses' => $_SESSION['applicant']['riasec_responses'],
            'scores' => $_SESSION['applicant']['riasec_scores'] ?? [],
            'top_three_codes' => $_SESSION['applicant']['top_three_codes'] ?? [],
            'completed_at' => date('Y-m-d H:i:s')
        ];
    }
    unset($_SESSION['applicant']['riasec_responses']);
    unset($_SESSION['applicant']['riasec_scores']);
    unset($_SESSION['applicant']['top_three_codes']);
    $_SESSION['retake_initialized'] = true;
} elseif ($mode !== 'retake') {
    unset($_SESSION['retake_initialized']);
}

// Fetch existing responses from session
$saved_responses = $_SESSION['applicant']['riasec_responses'] ?? [];
$tie_data = null;
$total_questions = count($questions);

// Determine current step index (0-based) and ensure strict boundaries
$current_step = isset($_POST['current_step']) ? (int)$_POST['current_step'] : 0;
if ($current_step < 0) {
    $current_step = 0;
}
if ($current_step >= $total_questions) {
    $current_step = $total_questions - 1;
}

// Process form submission navigation & final calculation
if ($_SERVER['REQUEST_METHOD'] === 'POST' && (!isset($_POST['action']) || $_POST['action'] !== 'handle_existing_choice')) {
    require_valid_csrf();

    // Check if resolving a tie submission with strict whitelist validation
    if (isset($_POST['resolve_tie_code']) && !empty($_POST['resolve_tie_code'])) {
        $selected_tie_code = strtoupper(trim($_POST['resolve_tie_code']));
        $pending = $_SESSION['pending_riasec_calc'] ?? null;

        if ($pending && isset($pending['tied_codes']) && in_array($selected_tie_code, $pending['tied_codes'], true)) {
            $scores = $pending['scores'];
            $clear_top = $pending['clear_top']; 
            $tied_codes = $pending['tied_codes'];

            $top_codes = array_merge($clear_top, [$selected_tie_code]);
            foreach ($tied_codes as $code) {
                if ($code !== $selected_tie_code && count($top_codes) < 3) {
                    $top_codes[] = $code;
                }
            }

            // Archive old scores to history if overwriting an existing score
            if (!empty($_SESSION['applicant']['riasec_responses'])) {
                if (!isset($_SESSION['applicant']['riasec_history'])) {
                    $_SESSION['applicant']['riasec_history'] = [];
                }
                $_SESSION['applicant']['riasec_history'][] = [
                    'responses' => $_SESSION['applicant']['riasec_responses'],
                    'scores' => $_SESSION['applicant']['riasec_scores'] ?? [],
                    'top_three_codes' => $_SESSION['applicant']['top_three_codes'] ?? [],
                    'completed_at' => date('Y-m-d H:i:s')
                ];
            }

            $_SESSION['applicant']['riasec_scores'] = $scores;
            $_SESSION['applicant']['top_three_codes'] = array_slice($top_codes, 0, 3);
            $_SESSION['applicant']['riasec_responses'] = $pending['responses'];
            $_SESSION['applicant']['last_updated'] = date('Y-m-d H:i:s');
            unset($_SESSION['pending_riasec_calc']);

            header('Location: next_step.php');
            exit;
        }
    }

    // Save response for the question just submitted/interacted with (with strict ID & range checks)
    if (isset($_POST['active_program_id']) && isset($_POST['current_answer'])) {
        $active_id = (int)$_POST['active_program_id'];
        $val = (int)$_POST['current_answer'];
        
        // Validate that active_id maps to a valid question ID in our array
        $valid_program_id = false;
        foreach ($questions as $q) {
            if ($q['program_id'] === $active_id) {
                $valid_program_id = true;
                break;
            }
        }

        if ($valid_program_id && $val >= 1 && $val <= 5) {
            $saved_responses['q_' . $active_id] = $val;
            $_SESSION['applicant']['riasec_responses'] = $saved_responses;
        }
    }

    // Handle wizard navigation actions
    if (isset($_POST['action'])) {
        if ($_POST['action'] === 'next' || $_POST['action'] === 'auto_advance') {
            $current_step = min($total_questions - 1, $current_step + 1);
        } elseif ($_POST['action'] === 'prev') {
            $current_step = max(0, $current_step - 1);
        } elseif ($_POST['action'] === 'finish') {
            // Final calculation check: ensure ALL questions are truly answered and within bounds
            $all_answered = true;
            foreach ($questions as $q) {
                if (!isset($saved_responses['q_' . $q['program_id']]) || (int)$saved_responses['q_' . $q['program_id']] < 1 || (int)$saved_responses['q_' . $q['program_id']] > 5) {
                    $all_answered = false;
                    break;
                }
            }

            if ($all_answered) {
                $scores = ['R' => 0, 'I' => 0, 'A' => 0, 'S' => 0, 'E' => 0, 'C' => 0];
                $responses = [];

                foreach ($questions as $q) {
                    $id = $q['program_id'];
                    $val = (int)$saved_responses['q_' . $id];
                    $scores[$q['code']] += $val;
                    $responses['q_' . $id] = $val;
                }

                arsort($scores);

                $score_groups = [];
                foreach ($scores as $code => $score) {
                    $score_groups[$score][] = $code;
                }

                $clear_top = [];
                $tied_codes = [];
                $count = 0;

                foreach ($score_groups as $score => $codes) {
                    if ($count + count($codes) <= 3) {
                        foreach ($codes as $c) {
                            $clear_top[] = $c;
                            $count++;
                        }
                    } else {
                        if ($count < 3) {
                            $tied_codes = $codes;
                        }
                        break;
                    }
                }

                if (!empty($tied_codes)) {
                    $_SESSION['pending_riasec_calc'] = [
                        'scores' => $scores,
                        'responses' => $responses,
                        'clear_top' => $clear_top,
                        'tied_codes' => $tied_codes
                    ];

                    $tie_data = [
                        'tied_codes' => $tied_codes,
                        'needed' => 3 - count($clear_top),
                        'tied_score' => $scores[$tied_codes[0]]
                    ];
                } else {
                    $top_codes = array_slice(array_keys($scores), 0, 3);

                    // Archive existing score to history before saving new ones
                    if (!empty($_SESSION['applicant']['riasec_responses']) && $_SESSION['applicant']['riasec_responses'] !== $responses) {
                        if (!isset($_SESSION['applicant']['riasec_history'])) {
                            $_SESSION['applicant']['riasec_history'] = [];
                        }
                        $_SESSION['applicant']['riasec_history'][] = [
                            'responses' => $_SESSION['applicant']['riasec_responses'],
                            'scores' => $_SESSION['applicant']['riasec_scores'] ?? [],
                            'top_three_codes' => $_SESSION['applicant']['top_three_codes'] ?? [],
                            'completed_at' => date('Y-m-d H:i:s')
                        ];
                    }

                    $_SESSION['applicant']['riasec_scores'] = $scores;
                    $_SESSION['applicant']['top_three_codes'] = $top_codes;
                    $_SESSION['applicant']['riasec_responses'] = $responses;
                    $_SESSION['applicant']['last_updated'] = date('Y-m-d H:i:s');

                    header('Location: next_step.php');
                    exit;
                }
            } else {
                // If finish was triggered prematurely, bounce user back to the first unanswered or current step
                $current_step = 0;
            }
        }
    }
}

// Get current active question data safely
$current_q = $questions[$current_step];
$active_id = $current_q['program_id'];
$active_desc = htmlspecialchars($current_q['description']);
$current_saved_val = (int)($saved_responses['q_' . $active_id] ?? 0);
$progress_percent = (($current_step + 1) / $total_questions) * 100;
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cerritos College - Career Interest Assessment</title>
    <style>
        :root {
            /* High contrast WCAG AAA/AA colors */
            --cerritos-blue: #002b49;
            --cerritos-gold: #8a6200;
            --cerritos-dark: #1e293b;
            --cerritos-light: #f8fafc;
            --card-border: #475569;
            --focus-outline: #005fcc;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background-color: var(--cerritos-light);
            color: var(--cerritos-dark);
            margin: 0;
            padding: 0;
            font-size: 15px;
        }

        /* Visually Hidden Utility Class for Screen Readers */
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
            padding: 0.75rem 1.25rem;
            border-bottom: 4px solid #ffc72c;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 100;
        }

        header h1 {
            font-size: 1.15rem;
            margin: 0;
            font-weight: 600;
        }

        .step-badge {
            font-size: 0.85rem;
            background: rgba(255, 255, 255, 0.2);
            padding: 0.3rem 0.7rem;
            border-radius: 12px;
            font-weight: 600;
            color: #ffffff;
        }

        .main-container {
            max-width: 680px;
            margin: 1.25rem auto;
            padding: 0 1rem;
        }

        .progress-bar-container {
            background: #cbd5e1;
            border-radius: 4px;
            height: 10px;
            width: 100%;
            margin-bottom: 1.25rem;
            overflow: hidden;
            border: 1px solid #94a3b8;
        }

        .progress-bar-fill {
            background-color: var(--cerritos-blue);
            height: 100%;
            width: <?php echo $progress_percent; ?>%;
            transition: width 0.3s ease;
        }

        .intro-box {
            background: #ffffff;
            padding: 1rem 1.25rem;
            border-radius: 8px;
            border: 2px solid var(--card-border);
            border-left: 6px solid var(--cerritos-blue);
            margin-bottom: 1rem;
        }

        .intro-box h2 {
            margin: 0 0 0.3rem 0;
            color: var(--cerritos-blue);
            font-size: 1.2rem;
        }

        .intro-box p {
            margin: 0;
            color: #334155;
            font-size: 0.95rem;
            line-height: 1.4;
        }

        .choice-box {
            background: #ffffff;
            border: 2px solid var(--card-border);
            border-radius: 8px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
        }

        .choice-inner {
            background: #f0f6fc;
            border: 2px solid var(--cerritos-blue);
            padding: 1.25rem;
            border-radius: 6px;
            margin: 1rem 0 1.5rem 0;
        }

        .choice-option {
            display: flex;
            align-items: center;
            padding: 0.6rem;
            margin-bottom: 0.5rem;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1rem;
            color: var(--cerritos-dark);
            border: 2px solid transparent;
        }

        .choice-option:hover {
            background-color: #e2edfd;
        }

        .choice-option input[type="radio"] {
            width: 1.25rem;
            height: 1.25rem;
            margin-right: 0.75rem;
            accent-color: var(--cerritos-blue);
            cursor: pointer;
        }

        .choice-option:has(input[type="radio"]:focus) {
            outline: 3px solid var(--focus-outline);
            outline-offset: 2px;
        }

        .tie-banner {
            background: #fffdf5;
            border: 2px solid var(--cerritos-gold);
            border-radius: 8px;
            padding: 1.25rem;
            margin-bottom: 1.25rem;
        }

        .tie-banner h3 {
            margin: 0 0 0.5rem 0;
            color: var(--cerritos-blue);
            font-size: 1.15rem;
        }

        .tie-banner p {
            color: var(--cerritos-dark);
            font-size: 0.95rem;
            line-height: 1.4;
            margin-bottom: 1rem;
        }

        .tie-options {
            display: flex;
            gap: 0.75rem;
            flex-wrap: wrap;
        }

        .tie-btn {
            background: #ffffff;
            border: 2px solid var(--cerritos-blue);
            color: var(--cerritos-blue);
            padding: 0.75rem 1.25rem;
            border-radius: 6px;
            font-size: 0.95rem;
            font-weight: bold;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.5rem;
            transition: all 0.2s ease;
        }

        .tie-btn:hover {
            background: var(--cerritos-blue);
            color: #ffffff;
        }

        .tie-btn:focus {
            outline: 3px solid var(--focus-outline);
            outline-offset: 3px;
        }

        .q-card {
            background: #ffffff;
            border: 2px solid var(--card-border);
            border-radius: 8px;
            padding: 1.25rem;
            margin-bottom: 1.25rem;
        }

        .q-header {
            display: flex;
            align-items: center;
            margin-bottom: 0.75rem;
        }

        .q-num {
            font-weight: 700;
            color: var(--cerritos-blue);
            font-size: 0.85rem;
            background: #eef6ff;
            padding: 0.25rem 0.6rem;
            border-radius: 4px;
            border: 1px solid #cbd5e1;
        }

        .q-text {
            font-size: 1.1rem;
            line-height: 1.45;
            color: var(--cerritos-dark);
            font-weight: bold;
            margin-bottom: 1.25rem;
        }

        .options-fieldset {
            border: none;
            padding: 0;
            margin: 0;
        }

        /* 5 Compact buttons aligned in a single row */
        .options-group {
            display: flex;
            flex-direction: row;
            gap: 0.5rem;
            width: 100%;
        }

        .option-card {
            appearance: none;
            -webkit-appearance: none;
            font-family: inherit;
            flex: 1;
            background: #ffffff;
            border: 2px solid #595959;
            border-radius: 6px;
            padding: 0.5rem 0.25rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            box-sizing: border-box;
            transition: border-color 0.2s ease, background-color 0.2s ease;
            min-height: 44px;
        }

        .option-card:hover {
            border-color: var(--cerritos-blue);
            background-color: #f0f6fc;
        }

        .option-card:focus {
            outline: 3px solid var(--focus-outline);
            outline-offset: 2px;
        }

        .option-label-text {
            font-size: 0.8rem;
            font-weight: bold;
            color: var(--cerritos-blue);
            line-height: 1.2;
        }

        .nav-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #ffffff;
            padding: 0.85rem 1rem;
            border-radius: 8px;
            border: 2px solid var(--card-border);
        }

        .btn-nav {
            background-color: #f0f4f8;
            color: var(--cerritos-blue);
            border: 2px solid var(--cerritos-blue);
            padding: 0.6rem 1.25rem;
            font-size: 0.95rem;
            font-weight: bold;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: background 0.2s ease, color 0.2s ease;
        }

        .btn-nav:hover {
            background-color: var(--cerritos-blue);
            color: #ffffff;
        }

        .btn-nav:focus {
            outline: 3px solid var(--focus-outline);
            outline-offset: 3px;
        }

        /* Responsive fallbacks for smaller mobile screens */
        @media (max-width: 520px) {
            .options-group {
                flex-wrap: wrap;
            }
            .option-card {
                flex: 1 1 30%;
            }
            .option-label-text {
                font-size: 0.75rem;
            }
        }
    </style>
</head>
<body>

<header>
    <h1>Cerritos College Career Assessment</h1>
    <?php if ($has_existing_score && $mode !== 'retake'): ?>
        <span class="step-badge">Existing Results</span>
    <?php else: ?>
        <span class="step-badge">Question <?php echo ($current_step + 1); ?> of <?php echo $total_questions; ?></span>
    <?php endif; ?>
</header>

<main class="main-container">

    <?php if ($has_existing_score && $mode !== 'retake'): ?>
        <!-- Keep or Retake Choice Screen -->
        <div class="choice-box">
            <h2>Existing Assessment Found</h2>
            <p style="color: #334155; font-size: 0.95rem; margin-top: 0.3rem;">You have already completed the interest inventory in a previous session.</p>
            
            <form method="POST" action="interest_inventory.php">
                <?php echo csrf_field(); ?>
                <input type="hidden" name="action" value="handle_existing_choice">
                
                <div class="choice-inner">
                    <p style="margin-top: 0; font-weight: bold; color: var(--cerritos-blue);">Would you like to keep your existing score or retake the assessment?</p>
                    
                    <label class="choice-option">
                        <input type="radio" name="score_choice" value="keep" checked>
                        <span><strong>Keep existing score</strong> and continue forward</span>
                    </label>
                    <label class="choice-option">
                        <input type="radio" name="score_choice" value="retake">
                        <span><strong>Retake the assessment</strong> (your previous answers will be securely preserved in your session history)</span>
                    </label>
                </div>

                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <a href="next_step.php" class="btn-nav">
                        <span aria-hidden="true">&larr;</span> Back
                    </a>
                    <button type="submit" class="btn-nav" style="background-color: var(--cerritos-blue); color: #ffffff;">
                        Continue <span aria-hidden="true">&rarr;</span>
                    </button>
                </div>
            </form>
        </div>

    <?php else: ?>
        <!-- Active Assessment Wizard Screen -->
        <div class="progress-bar-container" aria-label="Assessment Progress">
            <div class="progress-bar-fill" style="width: <?php echo $progress_percent; ?>%;"></div>
        </div>

        <?php if ($tie_data): ?>
            <div class="tie-banner">
                <h3>We Found a Score Tie!</h3>
                <p>You scored equally high (<strong><?php echo $tie_data['tied_score']; ?> pts</strong>) in multiple interest categories. Select which area you would like to include as a primary focus in your Top 3 to proceed:</p>
                
                <form method="POST" action="">
                    <?php echo csrf_field(); ?>
                    <div class="tie-options">
                        <?php foreach ($tie_data['tied_codes'] as $code): ?>
                            <button type="submit" name="resolve_tie_code" value="<?php echo $code; ?>" class="tie-btn">
                                <span>Use <?php echo htmlspecialchars($riasec_names[$code]); ?></span>
                                <span aria-hidden="true">&rarr;</span>
                            </button>
                        <?php endforeach; ?>
                    </div>
                </form>
            </div>
        <?php else: ?>
            <div class="intro-box">
                <h2>Career Interest Inventory</h2>
                <p>Select an answer for each task to auto-advance to the next question.</p>
            </div>

            <form method="POST" action="" id="wizard-form">
                <?php echo csrf_field(); ?>
                <input type="hidden" name="current_step" value="<?php echo $current_step; ?>">
                <input type="hidden" name="active_program_id" value="<?php echo $active_id; ?>">
                <input type="hidden" name="current_answer" id="current_answer_input" value="">
                <input type="hidden" name="action" id="form-action" value="auto_advance">
                
                <div class="q-card">
                    <div class="q-header">
                        <span class="q-num">Task <?php echo ($current_step + 1); ?> of <?php echo $total_questions; ?></span>
                    </div>

                    <div class="q-text" id="task-description"><?php echo $active_desc; ?></div>

                    <fieldset class="options-fieldset">
                        <legend class="sr-only">Rate how much you would enjoy this task</legend>
                        <div class="options-group">
                            <?php 
                            $options = [
                                1 => 'Strongly Disagree',
                                2 => 'Disagree',
                                3 => 'Neutral',
                                4 => 'Agree',
                                5 => 'Strongly Agree'
                            ];
                            $is_last = ($current_step === $total_questions - 1);
                            foreach ($options as $val => $label_text): 
                            ?>
                                <button 
                                    type="button" 
                                    class="option-card"
                                    onclick="selectAndSubmit(<?php echo $val; ?>, <?php echo $is_last ? "'finish'" : "'auto_advance'"; ?>)"
                                    aria-describedby="task-description"
                                >
                                    <span class="option-label-text"><?php echo $label_text; ?></span>
                                </button>
                            <?php endforeach; ?>
                        </div>
                    </fieldset>
                </div>

                <?php if ($current_step > 0 || $has_existing_score): ?>
                    <div class="nav-bar">
                        <?php if ($current_step > 0): ?>
                            <button type="submit" name="action" value="prev" class="btn-nav" onclick="document.getElementById('form-action').value='prev';">
                                <span aria-hidden="true">&larr;</span> Previous Task
                            </button>
                        <?php elseif ($has_existing_score): ?>
                            <a href="interest_inventory.php" class="btn-nav">
                                <span aria-hidden="true">&larr;</span> Keep Previous
                            </a>
                        <?php endif; ?>
                    </div>
                <?php endif; ?>
            </form>
        <?php endif; ?>
    <?php endif; ?>

</main>

<script>
function selectAndSubmit(val, actionType) {
    document.getElementById('current_answer_input').value = val;
    document.getElementById('form-action').value = actionType;
    document.getElementById('wizard-form').submit();
}
</script>

</body>
</html>