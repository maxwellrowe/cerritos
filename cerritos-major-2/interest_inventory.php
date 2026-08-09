<?php
// Prevent browser caching
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Pragma: no-cache");

session_start();
require_once 'db.php';

// Ensure data exists
if (!isset($_SESSION['applicant'])) {
    header('Location: index.php');
    exit;
}

$applicant = $_SESSION['applicant'];
$email = $applicant['email'] ?? '';

// Standard RIASEC definitions
$riasec_definitions = [
    'R' => 'Realistic: Enjoys practical, hands-on tasks, working with tools, machinery, plants, animals, or physical materials.',
    'I' => 'Investigative: Enjoys analytical tasks, conducting research, solving complex problems, exploring ideas, and working with concepts or scientific data.',
    'A' => 'Artistic: Leans toward creative expression, originality, unstructured environments, and artistic fields like design, writing, or performance.',
    'S' => 'Social: Enjoys helping, teaching, counseling, mentoring, or serving others, often thriving in collaborative, people-oriented roles.',
    'E' => 'Enterprising: Likes leading, persuading, managing, or organizing projects, often gravitating toward business, sales, or entrepreneurial ventures.',
    'C' => 'Conventional: Appreciates structured environments, organizing data, managing details, following clear procedures, and working with numbers or administration.'
];

// Check database for existing scores
$stmt = $pdo->prepare("SELECT top_three_codes, score_data FROM applicant_interests WHERE email = :email");
$stmt->execute(['email' => $email]);
$db_interest = $stmt->fetch();

$existing_top_codes = [];
$existing_scores = [];

if ($db_interest) {
    $existing_top_codes = json_decode($db_interest['top_three_codes'] ?? '[]', true) ?: [];
    $existing_scores = json_decode($db_interest['score_data'] ?? '[]', true) ?: [];
}

$has_existing_score = !empty($existing_top_codes);

// Update primary choice
if (isset($_POST['action']) && $_POST['action'] === 'update_existing_primary' && $has_existing_score) {
    $new_primary = $_POST['primary_code'] ?? '';
    if (!empty($new_primary) && in_array($new_primary, $existing_top_codes)) {
        $reordered = [$new_primary];
        foreach ($existing_top_codes as $c) {
            if ($c !== $new_primary) {
                $reordered[] = $c;
            }
        }
        $existing_top_codes = $reordered;
        $_SESSION['top_holland_codes'] = $existing_top_codes;
        
        // Sync with applicant session array to prevent fallback to previous primary
        $_SESSION['applicant']['top_three_codes'] = $existing_top_codes;
        
        $currentTime = date('Y-m-d H:i:s');
        
        $stmt = $pdo->prepare("
            UPDATE applicant_interests 
            SET top_three_codes = :top_three_codes, last_updated = :last_updated 
            WHERE email = :email
        ");
        $stmt->execute([
            'top_three_codes' => json_encode($existing_top_codes),
            'last_updated' => $currentTime,
            'email' => $email
        ]);
    }
    header('Location: career_selection.php');
    exit;
}

$show_prompt = $has_existing_score && !isset($_GET['retake']) && !isset($_POST['action']) && !isset($_GET['change_primary']);
$show_primary_selector = $has_existing_score && isset($_GET['change_primary']);

if (isset($_GET['choice']) && $_GET['choice'] === 'keep' && $has_existing_score) {
    $_SESSION['top_holland_codes'] = $existing_top_codes;
    $_SESSION['applicant']['top_three_codes'] = $existing_top_codes;
    header('Location: career_selection.php');
    exit;
}

// Fetch survey items directly from database table
$riasec_items = [];
try {
    $stmt = $pdo->query("SELECT program_id, code, theme, description FROM riasec_questions");
    $riasec_items = $stmt->fetchAll();
} catch (\PDOException $e) {
    // Fallback to json if table doesn't exist
    if (file_exists('interest_inventory.json')) {
        $decoded = json_decode(file_get_contents('interest_inventory.json'), true);
        $riasec_items = $decoded['riasec_survey'] ?? ($decoded ?? []);
    }
}

$theme_lookup = [];
$grouped_by_code = [];

foreach ($riasec_items as $item) {
    $code = $item['code'] ?? '';
    $theme = $item['theme'] ?? '';
    if (!empty($code)) {
        if (!empty($theme)) {
            $theme_lookup[$code] = $theme;
        }
        $grouped_by_code[$code][] = $item;
    }
}

// Pick 3 random questions per category
if (!isset($_SESSION['selected_riasec_subset']) || isset($_GET['reshuffle'])) {
    $selected_subset = [];
    foreach ($grouped_by_code as $code => $items) {
        shuffle($items);
        $subset = array_slice($items, 0, 3);
        foreach ($subset as $sub_item) {
            $selected_subset[] = $sub_item;
        }
    }
    shuffle($selected_subset);
    $_SESSION['selected_riasec_subset'] = $selected_subset;
} else {
    $selected_subset = $_SESSION['selected_riasec_subset'];
}

$results_mode = false;
$tie_resolution_mode = false;
$tied_codes = [];
$scores = [];

// Handle Tie-Breaker Submission
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'resolve_tie') {
    $primary_code = $_POST['primary_code'] ?? '';
    $scores = $_SESSION['holland_scores'] ?? [];
    $current_top = $_SESSION['unfiltered_top_codes'] ?? [];
    
    if (!empty($primary_code) && in_array($primary_code, $current_top)) {
        $reordered = [$primary_code];
        foreach ($current_top as $c) {
            if ($c !== $primary_code) {
                $reordered[] = $c;
            }
        }
        $top_code_keys = $reordered;
        $_SESSION['top_holland_codes'] = $top_code_keys;
        $_SESSION['applicant']['top_three_codes'] = $top_code_keys;
        
        $currentTime = date('Y-m-d H:i:s');
        
        $stmt = $pdo->prepare("
            UPDATE applicant_interests 
            SET top_three_codes = :top_three_codes, last_updated = :last_updated 
            WHERE email = :email
        ");
        $stmt->execute([
            'top_three_codes' => json_encode($top_code_keys),
            'last_updated' => $currentTime,
            'email' => $email
        ]);
    }
    $results_mode = true;
}

// Handle Initial Survey Submission
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'submit_inventory') {
    $raw_scores = $_POST['score'] ?? [];
    
    foreach (array_keys($theme_lookup) as $code) {
        $scores[$code] = 0;
    }
    
    foreach ($raw_scores as $code => $items_array) {
        if (!isset($scores[$code])) {
            $scores[$code] = 0;
        }
        if (is_array($items_array)) {
            foreach ($items_array as $val) {
                $scores[$code] += intval($val);
            }
        }
    }
    
    arsort($scores);
    $top_codes = array_slice($scores, 0, 3, true);
    $top_code_keys = array_keys($top_codes);
    
    $_SESSION['holland_scores'] = $scores;
    $_SESSION['unfiltered_top_codes'] = $top_code_keys;
    $_SESSION['top_holland_codes'] = $top_code_keys;
    $_SESSION['applicant']['top_three_codes'] = $top_code_keys;
    
    $score_values = array_values($top_codes);
    if (($score_values[0] === $score_values[1]) || (isset($score_values[2]) && $score_values[1] === $score_values[2])) {
        $max_score = $score_values[0];
        foreach ($scores as $c => $s) {
            if ($s === $max_score) {
                $tied_codes[] = $c;
            }
        }
        $tie_resolution_mode = true;
    } else {
        $results_mode = true;
    }
    
    $currentTime = date('Y-m-d H:i:s');
    
    $stmt = $pdo->prepare("
        INSERT INTO applicant_interests (email, top_three_codes, score_data, last_updated)
        VALUES (:email, :top_three_codes, :score_data, :last_updated)
        ON DUPLICATE KEY UPDATE 
            top_three_codes = VALUES(top_three_codes),
            score_data = VALUES(score_data),
            last_updated = VALUES(last_updated)
    ");
    $stmt->execute([
        'email' => $email,
        'top_three_codes' => json_encode($top_code_keys),
        'score_data' => json_encode($scores),
        'last_updated' => $currentTime
    ]);
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cerritos College - Career Interest Inventory</title>
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
        .intro-text {
            margin-bottom: 1.5rem;
            color: #555;
            line-height: 1.5;
        }
        .question-card {
            background: #fdfdfd;
            border: 1px solid #e1e8ed;
            border-radius: 6px;
            padding: 1.25rem;
            margin-bottom: 1rem;
        }
        .question-text {
            font-size: 1rem;
            margin-bottom: 0.75rem;
            color: #333;
            font-weight: 500;
        }
        .likert-scale {
            display: flex;
            justify-content: space-between;
            max-width: 550px;
            gap: 0.5rem;
        }
        .likert-option {
            text-align: center;
            font-size: 0.75rem;
            color: #555;
            flex: 1;
        }
        .likert-option input {
            display: block;
            margin: 0 auto 0.2rem auto;
        }
        .results-box {
            background: #f0f6fc;
            border: 2px solid var(--cerritos-blue);
            padding: 1.5rem;
            border-radius: 8px;
            margin-bottom: 2rem;
        }
        .top-code-card {
            background: #fff;
            border-left: 5px solid var(--cerritos-gold);
            padding: 1rem;
            margin-bottom: 1rem;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            border-radius: 4px;
        }
        .prompt-box {
            background: #fff8e6;
            border: 1px solid #ffeeba;
            padding: 1.5rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            text-align: center;
        }
        .explanation-box {
            background: #f9fbfd;
            border: 1px solid #d0e1f9;
            padding: 1.25rem;
            border-radius: 6px;
            margin-top: 1.5rem;
            margin-bottom: 1.5rem;
        }
        .explanation-box h4 {
            color: var(--cerritos-blue);
            margin-top: 0;
            margin-bottom: 0.75rem;
        }
        .filter-note {
            background: #eef4fb;
            border-left: 4px solid var(--cerritos-blue);
            padding: 0.75rem 1rem;
            margin-bottom: 1rem;
            font-size: 0.9rem;
            color: #002b49;
            text-align: left;
            border-radius: 0 4px 4px 0;
        }
        .explanation-box ul {
            margin: 0;
            padding-left: 1.25rem;
            color: #444;
            font-size: 0.9rem;
            line-height: 1.4;
            text-align: left;
        }
        .explanation-box li {
            margin-bottom: 0.4rem;
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
            display: inline-block;
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
        .error-notice {
            background: #fff3cd;
            color: #856404;
            padding: 1rem;
            border: 1px solid #ffeeba;
            border-radius: 4px;
            margin-bottom: 1.5rem;
        }
    </style>
</head>
<body>

<header>
    <h1>Cerritos College Career Exploration</h1>
    <span class="step-indicator">Interest Inventory (RIASEC)</span>
</header>

<div class="container">
    <?php if ($show_primary_selector): ?>
        <h2>Select Primary Holland Code</h2>
        <div class="prompt-box" style="text-align: left;">
            <p class="intro-text" style="margin-top: 0;">
                Select which code you want as your primary code to filter your career options:
            </p>
            
            <form method="POST" action="interest_inventory.php">
                <input type="hidden" name="action" value="update_existing_primary">
                
                <div style="margin-bottom: 1.5rem;">
                    <?php foreach ($existing_top_codes as $tcode): 
                        $score_val = $existing_scores[$tcode] ?? '';
                    ?>
                        <label style="display: block; background: #fff; padding: 0.75rem 1rem; border: 1px solid #ccc; border-radius: 4px; margin-bottom: 0.5rem; cursor: pointer;">
                            <input type="radio" name="primary_code" value="<?php echo htmlspecialchars($tcode); ?>" <?php echo ($tcode === $existing_top_codes[0]) ? 'checked' : ''; ?> required style="margin-right: 0.5rem;">
                            <strong>Code <?php echo htmlspecialchars($tcode); ?></strong> — <?php echo htmlspecialchars($theme_lookup[$tcode] ?? ''); ?><?php echo ($score_val !== '') ? " (<strong>{$score_val} pts</strong>)" : ""; ?>
                        </label>
                    <?php endforeach; ?>
                </div>
                
                <div style="display: flex; gap: 1rem;">
                    <button type="submit" class="btn">Save & Continue &rarr;</button>
                    <a href="interest_inventory.php" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    <?php elseif ($show_prompt): ?>
        <h2>Existing Holland Code Found</h2>
        <div class="prompt-box">
            <p style="font-size: 1.1rem; color: var(--cerritos-blue); margin-top: 0;">
                <strong>Your Holland Code:</strong> 
                <?php 
                $formatted_codes_array = [];
                foreach ($existing_top_codes as $tc) {
                    $s_val = $existing_scores[$tc] ?? '';
                    $formatted_codes_array[] = htmlspecialchars($tc) . ($s_val !== '' ? " (" . htmlspecialchars($s_val) . " pts)" : "");
                }
                echo implode(', ', $formatted_codes_array);
                ?>
            </p>
            
            <div class="explanation-box" style="text-align: left;">
                <h4>What Your Code Letters Mean:</h4>
                <div class="filter-note">
                    <strong>Note:</strong> Your <strong>first code letter</strong> represents your primary interest and will be used to filter careers and majors for this tool.
                </div>
                <ul>
                    <?php foreach ($existing_top_codes as $code_letter): 
                        $trimmed_letter = trim($code_letter);
                        $s_val = $existing_scores[$trimmed_letter] ?? '';
                        if (isset($riasec_definitions[$trimmed_letter])):
                    ?>
                        <li><strong><?php echo htmlspecialchars($trimmed_letter); ?><?php echo ($s_val !== '' ? " (" . htmlspecialchars($s_val) . " pts)" : ""); ?>:</strong> <?php echo htmlspecialchars($riasec_definitions[$trimmed_letter]); ?></li>
                    <?php 
                        endif;
                    endforeach; 
                    ?>
                </ul>
            </div>

            <p style="color: #555; margin-bottom: 1.5rem;">Would you like to keep your current score, change your primary code, or retake the test?</p>
            <div style="display: flex; justify-content: center; gap: 1rem; flex-wrap: wrap;">
                <a href="interest_inventory.php?choice=keep" class="btn">Keep Current Score</a>
                <a href="interest_inventory.php?change_primary=1" class="btn btn-secondary">Change Primary Code</a>
                <a href="interest_inventory.php?retake=1" class="btn btn-secondary">Retake Test</a>
            </div>
        </div>
    <?php elseif ($tie_resolution_mode): ?>
        <h2>Score Tie Detected</h2>
        <div class="prompt-box" style="text-align: left;">
            <p class="intro-text" style="margin-top: 0;">
                We noticed a tie in your top inventory scores. Please select which code you would like to designate as your <strong>primary</strong> code. This will be placed first and used to filter your career options.
            </p>
            
            <form method="POST" action="interest_inventory.php">
                <input type="hidden" name="action" value="resolve_tie">
                
                <div style="margin-bottom: 1.5rem;">
                    <?php foreach ($tied_codes as $tcode): 
                        $score_val = $scores[$tcode] ?? '';
                    ?>
                        <label style="display: block; background: #fff; padding: 0.75rem 1rem; border: 1px solid #ccc; border-radius: 4px; margin-bottom: 0.5rem; cursor: pointer;">
                            <input type="radio" name="primary_code" value="<?php echo htmlspecialchars($tcode); ?>" required style="margin-right: 0.5rem;">
                            <strong>Code <?php echo htmlspecialchars($tcode); ?></strong> — <?php echo htmlspecialchars($theme_lookup[$tcode] ?? ''); ?><?php echo ($score_val !== '') ? " (<strong>{$score_val} pts</strong>)" : ""; ?>
                        </label>
                    <?php endforeach; ?>
                </div>
                
                <button type="submit" class="btn">Confirm Primary Code &rarr;</button>
            </form>
        </div>
    <?php elseif ($results_mode): ?>
        <h2>Your Holland Code Results</h2>
        <div class="results-box">
            <p class="intro-text" style="margin-top: 0;">Here are your calculated top Holland Codes based on your recent responses:</p>
            <?php foreach ($_SESSION['top_holland_codes'] as $index => $code): 
                $score_val = $scores[$code] ?? $_SESSION['holland_scores'][$code] ?? '';
            ?>
                <div class="top-code-card">
                    <h3 style="margin: 0 0 0.3rem 0; color: var(--cerritos-blue);">Rank <?php echo $index + 1; ?>: Code <?php echo htmlspecialchars($code); ?><?php echo ($score_val !== '') ? " — " . htmlspecialchars($score_val) . " pts" : ""; ?></h3>
                    <p style="margin: 0; color: #555; font-size: 0.95rem;"><?php echo htmlspecialchars($theme_lookup[$code] ?? ''); ?></p>
                </div>
            <?php endforeach; ?>

            <div class="explanation-box" style="background: #ffffff;">
                <h4>Understanding Your Holland Code Letters:</h4>
                <div class="filter-note">
                    <strong>Note:</strong> Your <strong>first code letter</strong> represents your primary interest and will be used to filter careers and majors for this tool.
                </div>
                <ul>
                    <?php foreach ($_SESSION['top_holland_codes'] as $code_letter): 
                        $trimmed_letter = trim($code_letter);
                        $score_val = $scores[$trimmed_letter] ?? $_SESSION['holland_scores'][$trimmed_letter] ?? '';
                        if (isset($riasec_definitions[$trimmed_letter])):
                    ?>
                        <li><strong><?php echo htmlspecialchars($trimmed_letter); ?><?php echo ($score_val !== '' ? " (" . htmlspecialchars($score_val) . " pts)" : ""); ?>:</strong> <?php echo htmlspecialchars($riasec_definitions[$trimmed_letter]); ?></li>
                    <?php 
                        endif;
                    endforeach; 
                    ?>
                </ul>
            </div>
        </div>
        
        <div class="button-group">
            <div></div>
            <a href="career_selection.php" class="btn">Continue to Career Selection &rarr;</a>
        </div>
    <?php else: ?>
        <?php if (empty($riasec_items)): ?>
            <div class="error-notice">
                <strong>Notice:</strong> Could not load survey questions from database.
            </div>
        <?php endif; ?>

        <form method="POST" action="interest_inventory.php">
            <input type="hidden" name="action" value="submit_inventory">
            
            <h2>Career Interest Inventory</h2>
            <p class="intro-text">Rate how much you agree or disagree with each statement below. Three randomized statements from each of the 6 RIASEC categories (18 total questions) are shown. Your responses will help determine your Holland Career Code.</p>
            
            <?php 
            $q_num = 1;
            foreach ($selected_subset as $item): 
                $code = $item['code'] ?? '';
                $programId = $item['program_id'] ?? $q_num;
                $desc = $item['description'] ?? '';
                if (empty($code) || empty($desc)) continue;
            ?>
                <div class="question-card">
                    <div class="question-text"><?php echo $q_num++; ?>. I like to <?php echo htmlspecialchars(lcfirst($desc)); ?></div>
                    <div class="likert-scale">
                        <label class="likert-option"><input type="radio" name="score[<?php echo $code; ?>][<?php echo $programId; ?>]" value="1" required>1. Strongly Disagree</label>
                        <label class="likert-option"><input type="radio" name="score[<?php echo $code; ?>][<?php echo $programId; ?>]" value="2">2. Disagree</label>
                        <label class="likert-option"><input type="radio" name="score[<?php echo $code; ?>][<?php echo $programId; ?>]" value="3">3. Neutral</label>
                        <label class="likert-option"><input type="radio" name="score[<?php echo $code; ?>][<?php echo $programId; ?>]" value="4">4. Agree</label>
                        <label class="likert-option"><input type="radio" name="score[<?php echo $code; ?>][<?php echo $programId; ?>]" value="5">5. Strongly Agree</label>
                    </div>
                </div>
            <?php endforeach; ?>
            
            <div class="button-group">
                <a href="lcp.php" class="btn btn-secondary">&larr; Back to Pathways</a>
                <button type="submit" class="btn">Calculate My Holland Code &rarr;</button>
            </div>
        </form>
    <?php endif; ?>
</div>

</body>
</html>