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

// RIASEC full names map
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
    
    if ($choice === 'keep') {
        header('Location: next_step.php');
        exit;
    } else {
        // Redirect to retake mode (clears active responses for a fresh attempt)
        header('Location: interest_inventory.php?mode=retake');
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

// Determine current step index (0-based)
$current_step = isset($_POST['current_step']) ? (int)$_POST['current_step'] : 0;
$current_step = max(0, min($total_questions - 1, $current_step));

// Process form submission navigation & final calculation
if ($_SERVER['REQUEST_METHOD'] === 'POST' && (!isset($_POST['action']) || $_POST['action'] !== 'handle_existing_choice')) {
    require_valid_csrf();

    // Check if resolving a tie submission
    if (isset($_POST['resolve_tie_code']) && !empty($_POST['resolve_tie_code'])) {
        $selected_tie_code = strtoupper(trim($_POST['resolve_tie_code']));
        $pending = $_SESSION['pending_riasec_calc'] ?? null;

        if ($pending && in_array($selected_tie_code, $pending['tied_codes'] ?? [], true)) {
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

    // Save response for the question just submitted/interacted with
    if (isset($_POST['active_program_id']) && isset($_POST['current_answer'])) {
        $active_id = (int)$_POST['active_program_id'];
        $val = (int)$_POST['current_answer'];
        $expected_id = $questions[$current_step]['program_id'];
        if ($active_id === $expected_id && $val >= 1 && $val <= 5) {
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
            // Final calculation check: ensure all questions are answered
            $all_answered = true;
            foreach ($questions as $q) {
                $answer = (int)($saved_responses['q_' . $q['program_id']] ?? 0);
                if ($answer < 1 || $answer > 5) {
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
            }
        }
    }
}

// Get current active question data
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
            --cerritos-blue: #002b49;
            --cerritos-gold: #ffc72c;
            --cerritos-light: #f8fafc;
            --card-border: #e2e8f0;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background-color: var(--cerritos-light);
            color: #1e293b;
            margin: 0;
            padding: 0;
            font-size: 14px;
        }

        header {
            background-color: var(--cerritos-blue);
            color: #ffffff;
            padding: 0.6rem 1.25rem;
            border-bottom: 3px solid var(--cerritos-gold);
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 100;
        }

        header h1 {
            font-size: 1.1rem;
            margin: 0;
            font-weight: 600;
        }

        .step-badge {
            font-size: 0.75rem;
            background: rgba(255, 255, 255, 0.2);
            padding: 0.2rem 0.6rem;
            border-radius: 12px;
            font-weight: 500;
        }

        .main-container {
            max-width: 650px;
            margin: 2rem auto;
            padding: 0 1rem;
        }

        .progress-bar-container {
            background: #e2e8f0;
            border-radius: 4px;
            height: 8px;
            width: 100%;
            margin-bottom: 1.5rem;
            overflow: hidden;
        }

        .progress-bar-fill {
            background-color: var(--cerritos-blue);
            height: 100%;
            width: <?php echo $progress_percent; ?>%;
            transition: width 0.3s ease;
        }

        .intro-box {
            background: #ffffff;
            padding: 1.25rem 1.5rem;
            border-radius: 8px;
            border: 1px solid var(--card-border);
            border-left: 4px solid var(--cerritos-blue);
            margin-bottom: 1.5rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.02);
        }

        .intro-box h2 {
            margin: 0 0 0.3rem 0;
            color: var(--cerritos-blue);
            font-size: 1.2rem;
        }

        .intro-box p {
            margin: 0;
            color: #64748b;
            font-size: 0.9rem;
        }

        .choice-box {
            background: #ffffff;
            border: 1px solid var(--card-border);
            border-radius: 8px;
            padding: 1.75rem;
            box-shadow: 0 4px 6px rgba(0,0,0,0.02);
            margin-bottom: 1.5rem;
        }

        .choice-inner {
            background: #f0f6fc;
            border: 2px solid var(--cerritos-blue);
            padding: 1.25rem;
            border-radius: 6px;
            margin: 1rem 0 1.5rem 0;
        }

        .tie-banner {
            background: #fff8e1;
            border: 2px solid var(--cerritos-gold);
            border-radius: 8px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        }

        .tie-banner h3 {
            margin: 0 0 0.5rem 0;
            color: var(--cerritos-blue);
            font-size: 1.1rem;
        }

        .tie-options {
            display: flex;
            gap: 0.75rem;
            margin-top: 1rem;
            flex-wrap: wrap;
        }

        .tie-btn {
            background: #ffffff;
            border: 2px solid var(--cerritos-blue);
            color: var(--cerritos-blue);
            padding: 0.6rem 1.2rem;
            border-radius: 6px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .tie-btn:hover {
            background: var(--cerritos-blue);
            color: #ffffff;
        }

        .q-card {
            background: #ffffff;
            border: 1px solid var(--card-border);
            border-radius: 8px;
            padding: 1.75rem;
            box-shadow: 0 4px 6px rgba(0,0,0,0.02);
            margin-bottom: 1.5rem;
        }

        .q-header {
            display: flex;
            align-items: center;
            margin-bottom: 1rem;
        }

        .q-num {
            font-weight: 700;
            color: var(--cerritos-blue);
            font-size: 0.8rem;
            background: #eff6ff;
            padding: 0.2rem 0.6rem;
            border-radius: 4px;
        }

        .q-text {
            font-size: 1.05rem;
            line-height: 1.5;
            color: #1e293b;
            font-weight: 600;
            margin-bottom: 1.5rem;
        }

        .options-group {
            display: flex;
            gap: 0.5rem;
        }

        .option-btn {
            flex: 1;
            position: relative;
        }

        .option-btn input {
            position: absolute;
            opacity: 0;
            width: 0;
            height: 0;
        }

        .option-label {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 0.75rem 0.2rem;
            font-size: 0.75rem;
            font-weight: 600;
            background: #f8fafc;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            color: #475569;
            cursor: pointer;
            user-select: none;
            transition: all 0.15s ease;
            text-align: center;
            line-height: 1.2;
            min-height: 50px;
            box-sizing: border-box;
        }

        .option-btn input:checked + .option-label {
            background-color: var(--cerritos-blue);
            color: #ffffff;
            border-color: var(--cerritos-blue);
            box-shadow: 0 2px 4px rgba(0,0,0,0.15);
        }

        .option-btn:hover .option-label {
            border-color: var(--cerritos-blue);
            color: var(--cerritos-blue);
        }

        .option-btn input:checked:hover + .option-label {
            color: #ffffff;
        }

        .nav-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #ffffff;
            padding: 1rem 1.25rem;
            border-radius: 8px;
            border: 1px solid var(--card-border);
            box-shadow: 0 2px 4px rgba(0,0,0,0.02);
        }

        .btn-nav {
            background-color: #e2e8f0;
            color: #334155;
            border: none;
            padding: 0.6rem 1.2rem;
            font-size: 0.9rem;
            font-weight: 600;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.2s ease;
        }

        .btn-nav:hover {
            background-color: #cbd5e1;
        }

        .btn-submit {
            background-color: var(--cerritos-blue);
            color: #ffffff;
            border: none;
            padding: 0.6rem 1.5rem;
            font-size: 0.9rem;
            font-weight: 600;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.2s ease;
        }

        .btn-submit:hover {
            background-color: #001d32;
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

<div class="main-container">

    <?php if ($has_existing_score && $mode !== 'retake'): ?>
        <!-- Keep or Retake Choice Screen -->
        <div class="choice-box">
            <h2>Existing Assessment Found</h2>
            <p style="color: #64748b; font-size: 0.9rem; margin-top: 0.3rem;">You have already completed the interest inventory in a previous session.</p>
            
            <form method="POST" action="interest_inventory.php">
                <?php echo csrf_field(); ?>
                <input type="hidden" name="action" value="handle_existing_choice">
                
                <div class="choice-inner">
                    <p style="margin-top: 0; font-weight: 600; color: var(--cerritos-blue);">Would you like to keep your existing score or retake the assessment?</p>
                    
                    <label style="display: block; margin-bottom: 0.75rem; cursor: pointer;">
                        <input type="radio" name="score_choice" value="keep" checked> <strong>Keep existing score</strong> and continue forward
                    </label>
                    <label style="display: block; cursor: pointer;">
                        <input type="radio" name="score_choice" value="retake"> <strong>Retake the assessment</strong> (your previous answers will be securely preserved in your session history)
                    </label>
                </div>

                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <a href="next_step.php" class="btn-nav" style="text-decoration: none;">&larr; Back</a>
                    <button type="submit" class="btn-submit">Continue &rarr;</button>
                </div>
            </form>
        </div>

    <?php else: ?>
        <!-- Active Assessment Wizard Screen -->
        <div class="progress-bar-container">
            <div class="progress-bar-fill"></div>
        </div>

        <?php if ($tie_data): ?>
            <div class="tie-banner">
                <h3>We Found a Score Tie!</h3>
                <p>You scored equally high (<strong><?php echo $tie_data['tied_score']; ?> pts</strong>) in multiple interest categories. Please choose which area you would like to include as a primary focus in your Top 3:</p>
                
                <form method="POST" action="">
                    <?php echo csrf_field(); ?>
                    <div class="tie-options">
                        <?php foreach ($tie_data['tied_codes'] as $code): ?>
                            <button type="submit" name="resolve_tie_code" value="<?php echo $code; ?>" class="tie-btn">
                                Use <?php echo htmlspecialchars($riasec_names[$code]); ?>
                            </button>
                        <?php endforeach; ?>
                    </div>
                </form>
            </div>
        <?php else: ?>
            <div class="intro-box">
                <h2>Career Interest Inventory</h2>
                <p>Rate how much you would enjoy each task to help match your interests to academic majors.</p>
            </div>

            <form method="POST" action="" id="wizard-form">
                <?php echo csrf_field(); ?>
                <input type="hidden" name="current_step" value="<?php echo $current_step; ?>">
                <input type="hidden" name="active_program_id" value="<?php echo $active_id; ?>">
                <!-- Hidden action field to handle auto-advance -->
                <input type="hidden" name="action" id="form-action" value="auto_advance">
                
                <div class="q-card">
                    <div class="q-header">
                        <span class="q-num">Task <?php echo ($current_step + 1); ?> of <?php echo $total_questions; ?></span>
                    </div>

                    <div class="q-text"><?php echo $active_desc; ?></div>

                    <div class="options-group">
                        <?php for ($val = 1; $val <= 5; $val++): 
                            $labels = [
                                1 => ['Strongly<br>Disagree', 'Strongly Disagree'],
                                2 => ['<br>Disagree', 'Disagree'],
                                3 => ['<br>Neutral', 'Neutral'],
                                4 => ['<br>Agree', 'Agree'],
                                5 => ['Strongly<br>Agree', 'Strongly Agree']
                            ];
                            $is_checked = ($current_saved_val === $val) ? 'checked' : '';
                        ?>
                            <label class="option-btn" title="<?php echo $labels[$val][1]; ?>">
                                <input type="radio" 
                                       name="current_answer" 
                                       value="<?php echo $val; ?>" 
                                       required
                                       <?php echo $is_checked; ?> 
                                       onchange="<?php echo ($current_step === $total_questions - 1) ? "document.getElementById('form-action').value='finish'; this.form.submit();" : "document.getElementById('form-action').value='auto_advance'; this.form.submit();"; ?>">
                                <span class="option-label"><?php echo $labels[$val][0]; ?></span>
                            </label>
                        <?php endfor; ?>
                    </div>
                </div>

                <div class="nav-bar">
                    <?php if ($current_step > 0): ?>
                        <button type="submit" name="action" value="prev" class="btn-nav" onclick="document.getElementById('form-action').value='prev';">&larr; Previous</button>
                    <?php else: ?>
                        <?php if ($has_existing_score): ?>
                            <a href="interest_inventory.php" class="btn-nav" style="text-decoration: none; display: inline-flex; align-items: center;">&larr; Keep Previous</a>
                        <?php else: ?>
                            <div></div>
                        <?php endif; ?>
                    <?php endif; ?>

                    <?php if ($current_step < $total_questions - 1): ?>
                        <button type="submit" name="action" value="next" class="btn-nav" onclick="document.getElementById('form-action').value='next';">Next &rarr;</button>
                    <?php else: ?>
                        <button type="submit" name="action" value="finish" class="btn-submit" onclick="document.getElementById('form-action').value='finish';">View Results &rarr;</button>
                    <?php endif; ?>
                </div>
            </form>
        <?php endif; ?>
    <?php endif; ?>

</div>

</body>
</html>
