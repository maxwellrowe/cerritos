<?php
// Prevent browser caching
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Pragma: no-cache");

session_start();

// Ensure data/applicant exists, otherwise redirect to start
if (!isset($_SESSION['applicant'])) {
    header('Location: index.php');
    exit;
}

$applicant = $_SESSION['applicant'];

// Define standard definitions for each Holland Code letter (RIASEC)
$riasec_definitions = [
    'R' => 'Realistic: Enjoys practical, hands-on tasks, working with tools, machinery, plants, animals, or physical materials.',
    'I' => 'Investigative: Enjoys analytical tasks, conducting research, solving complex problems, exploring ideas, and working with concepts or scientific data.',
    'A' => 'Artistic: Leans toward creative expression, originality, unstructured environments, and artistic fields like design, writing, or performance.',
    'S' => 'Social: Enjoys helping, teaching, counseling, mentoring, or serving others, often thriving in collaborative, people-oriented roles.',
    'E' => 'Enterprising: Likes leading, persuading, managing, or organizing projects, often gravitating toward business, sales, or entrepreneurial ventures.',
    'C' => 'Conventional: Appreciates structured environments, organizing data, managing details, following clear procedures, and working with numbers or administration.'
];

// Color and icon styling map for RIASEC categories
$riasec_styles = [
    'R' => ['color' => '#d97706', 'bg' => '#fef3c7', 'border' => '#f59e0b', 'icon' => '🔧'],
    'I' => ['color' => '#2563eb', 'bg' => '#eff6ff', 'border' => '#3b82f6', 'icon' => '🔬'],
    'A' => ['color' => '#7c3aed', 'bg' => '#f5f3ff', 'border' => '#8b5cf6', 'icon' => '🎨'],
    'S' => ['color' => '#db2777', 'bg' => '#fdf2f8', 'border' => '#ec4899', 'icon' => '🤝'],
    'E' => ['color' => '#059669', 'bg' => '#ecfdf5', 'border' => '#10b981', 'icon' => '📈'],
    'C' => ['color' => '#475569', 'bg' => '#f8fafc', 'border' => '#64748b', 'icon' => '📊']
];

// Check if applicant has saved scores/top codes in session
$existing_top_codes = [];
$existing_scores = [];

if (isset($_SESSION['top_holland_codes']) && !empty($_SESSION['top_holland_codes'])) {
    $existing_top_codes = $_SESSION['top_holland_codes'];
}
if (isset($_SESSION['holland_scores']) && !empty($_SESSION['holland_scores'])) {
    $existing_scores = $_SESSION['holland_scores'];
}

function find_inventory_data_in_data($data, &$target_codes, &$target_scores) {
    if (!is_array($data)) return;
    if (empty($target_codes) && isset($data['top_three_codes']) && is_array($data['top_three_codes']) && !empty($data['top_three_codes'])) {
        $target_codes = $data['top_three_codes'];
    }
    if (empty($target_codes) && isset($data['interest_inventory']['top_codes']) && is_array($data['interest_inventory']['top_codes']) && !empty($data['interest_inventory']['top_codes'])) {
        $target_codes = $data['interest_inventory']['top_codes'];
    }
    if (empty($target_scores) && isset($data['interest_inventory']['scores']) && is_array($data['interest_inventory']['scores']) && !empty($data['interest_inventory']['scores'])) {
        $target_scores = $data['interest_inventory']['scores'];
    }
    foreach ($data as $key => $val) {
        if (is_array($val)) {
            find_inventory_data_in_data($val, $target_codes, $target_scores);
        }
    }
}

if (empty($existing_top_codes) || empty($existing_scores)) {
    find_inventory_data_in_data($applicant, $existing_top_codes, $existing_scores);
    if (!empty($existing_top_codes)) {
        $_SESSION['top_holland_codes'] = $existing_top_codes;
    }
    if (!empty($existing_scores)) {
        $_SESSION['holland_scores'] = $existing_scores;
    }
}

$has_existing_score = !empty($existing_top_codes);

// Handle user choice to keep, retake, or update primary choice from existing screen
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
        
        $currentTime = date('Y-m-d H:i:s');
        
        $applicant['top_three_codes'] = $existing_top_codes;
        if (isset($applicant['interest_inventory'])) {
            $applicant['interest_inventory']['top_codes'] = $existing_top_codes;
        }
        $applicant['last_updated'] = $currentTime;
        $_SESSION['applicant'] = $applicant;
    }
    header('Location: career_selection.php');
    exit;
}

$show_prompt = $has_existing_score && !isset($_GET['retake']) && !isset($_POST['action']) && !isset($_GET['change_primary']);
$show_primary_selector = $has_existing_score && isset($_GET['change_primary']);

if (isset($_GET['choice']) && $_GET['choice'] === 'keep' && $has_existing_score) {
    $_SESSION['top_holland_codes'] = $existing_top_codes;
    header('Location: career_selection.php');
    exit;
}

// Load survey questions strictly from interest_inventory.json
$jsonFile = 'interest_inventory.json';
$riasec_items = [];

if (file_exists($jsonFile)) {
    $raw_json = file_get_contents($jsonFile);
    $decoded = json_decode($raw_json, true);
    
    if (isset($decoded['riasec_survey']) && is_array($decoded['riasec_survey'])) {
        $riasec_items = $decoded['riasec_survey'];
    } elseif (is_array($decoded)) {
        $riasec_items = $decoded;
    }
}

// Map themes for results summary and group questions by code
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

// Select 3 random questions from each code category
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

// Handle Tie-Breaker Form Submission
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
        
        $currentTime = date('Y-m-d H:i:s');
        
        $topCodesHistory = $applicant['top_codes_history'] ?? [];
        if (!empty($topCodesHistory)) {
            $lastIdx = count($topCodesHistory) - 1;
            $topCodesHistory[$lastIdx]['top_three_codes'] = $top_code_keys;
        }
        
        $applicant['top_three_codes'] = $top_code_keys;
        if (isset($applicant['interest_inventory'])) {
            $applicant['interest_inventory']['top_codes'] = $top_code_keys;
        }
        $applicant['top_codes_history'] = $topCodesHistory;
        $applicant['last_updated'] = $currentTime;
        
        $_SESSION['applicant'] = $applicant;
    }
    
    $results_mode = true;
}

// Handle Initial Survey Form Submission
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'submit_inventory') {
    $raw_scores = $_POST['score'] ?? [];
    
    foreach (array_keys($theme_lookup) as $code) {
        $scores[$code] = 0;
    }
    
    foreach ($raw_scores as $code => $questions_array) {
        if (!isset($scores[$code])) {
            $scores[$code] = 0;
        }
        if (is_array($questions_array)) {
            foreach ($questions_array as $val) {
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
    
    $score_values = array_values($top_codes);
    $max_score = reset($score_values);
    foreach ($scores as $c => $s) {
        if ($s === $max_score) {
            $tied_codes[] = $c;
        }
    }
    
    if (count($tied_codes) > 1 || ($score_values[0] === $score_values[1]) || (isset($score_values[2]) && $score_values[1] === $score_values[2])) {
        $_SESSION['tied_codes'] = $tied_codes;
        $tie_resolution_mode = true;
    } else {
        $results_mode = true;
    }
    
    $currentTime = date('Y-m-d H:i:s');
    
    $topCodesHistory = $applicant['top_codes_history'] ?? [];
    $topCodesHistory[] = [
        'timestamp' => $currentTime,
        'top_three_codes' => $top_code_keys
    ];
    
    $applicant['top_three_codes'] = $top_code_keys;
    $applicant['interest_inventory'] = [
        'scores' => $scores,
        'top_codes' => $top_code_keys,
        'last_completed' => $currentTime
    ];
    $applicant['top_codes_history'] = $topCodesHistory;
    $applicant['last_updated'] = $currentTime;
    
    $_SESSION['applicant'] = $applicant;
}

if ($tie_resolution_mode && empty($tied_codes) && isset($_SESSION['tied_codes'])) {
    $tied_codes = $_SESSION['tied_codes'];
}
if ($tie_resolution_mode && empty($tied_codes) && isset($_SESSION['holland_scores'])) {
    $scores = $_SESSION['holland_scores'];
    $max_s = max($scores);
    foreach ($scores as $c => $s) {
        if ($s === $max_s) {
            $tied_codes[] = $c;
        }
    }
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
            font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background-color: var(--cerritos-light);
            color: var(--cerritos-dark);
            margin: 0;
            padding: 0;
            line-height: 1.4;
        }
        header {
            background-color: var(--cerritos-blue);
            color: #ffffff;
            padding: 0.75rem 1.5rem;
            border-bottom: 4px solid var(--cerritos-gold);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        header h1 {
            font-size: 1.25rem;
            margin: 0;
        }
        .step-indicator {
            font-size: 0.85rem;
            background: rgba(255,255,255,0.15);
            padding: 0.3rem 0.6rem;
            border-radius: 4px;
        }
        .container {
            max-width: 950px;
            margin: 1.5rem auto;
            background: #ffffff;
            padding: 1.75rem;
            border-radius: 6px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }
        h2 {
            color: var(--cerritos-blue);
            border-bottom: 2px solid var(--cerritos-gold);
            padding-bottom: 0.3rem;
            margin-top: 0;
            font-size: 1.35rem;
        }
        .intro-text {
            margin-bottom: 1.25rem;
            color: #555;
            font-size: 0.95rem;
        }
        .scale-legend {
            background: #f8fafc;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            padding: 0.75rem 1rem;
            margin-bottom: 1.25rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 0.5rem;
        }
        .scale-legend-title {
            font-size: 0.85rem;
            font-weight: bold;
            color: var(--cerritos-blue);
            width: 100%;
            margin-bottom: 0.1rem;
        }
        .scale-legend-item {
            font-size: 0.8rem;
            color: #475569;
            display: flex;
            align-items: center;
            gap: 0.3rem;
        }
        .scale-legend-badge {
            background: #e2e8f0;
            color: #1e293b;
            font-weight: bold;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 0.75rem;
        }
        .questions-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 0.75rem;
            margin-bottom: 1.5rem;
        }
        @media (max-width: 768px) {
            .questions-grid {
                grid-template-columns: 1fr;
            }
            .container {
                margin: 0.5rem;
                padding: 1rem;
            }
            .scale-legend {
                flex-direction: column;
                align-items: flex-start;
                gap: 0.3rem;
            }
        }
        .question-card {
            background: #fafbfc;
            border: 1px solid #e1e8ed;
            border-radius: 6px;
            padding: 0.6rem 0.75rem;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            position: relative;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0,0,0,0.02);
            transition: transform 0.15s ease, box-shadow 0.15s ease;
        }
        .question-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(0,0,0,0.06);
        }
        .question-header-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 0.3rem;
        }
        .q-number {
            font-size: 0.7rem;
            font-weight: bold;
            color: #64748b;
            background: #e2e8f0;
            padding: 0.05rem 0.35rem;
            border-radius: 3px;
        }
        .question-text {
            font-size: 0.85rem;
            color: #222;
            font-weight: 500;
            margin-bottom: 0.6rem;
            line-height: 1.3;
        }
        .likert-scale {
            display: flex;
            justify-content: space-between;
            gap: 0.15rem;
        }
        .likert-option {
            text-align: center;
            font-size: 0.6rem;
            color: #475569;
            flex: 1;
            background: #ffffff;
            border: 1px solid #cbd5e1;
            padding: 0.2rem 0.05rem;
            border-radius: 3px;
            cursor: pointer;
            transition: all 0.15s ease;
            font-weight: 600;
        }
        .likert-option:hover {
            background: #f1f5f9;
            border-color: var(--cerritos-blue);
            color: var(--cerritos-blue);
        }
        .likert-option input {
            display: block;
            margin: 0 auto 0.05rem auto;
            transform: scale(0.8);
            cursor: pointer;
        }
        .results-box {
            background: #f0f6fc;
            border: 1px solid var(--cerritos-blue);
            padding: 1.25rem;
            border-radius: 6px;
            margin-bottom: 1.5rem;
        }
        .top-code-card {
            background: #fff;
            border-left: 4px solid var(--cerritos-gold);
            padding: 0.75rem 1rem;
            margin-bottom: 0.75rem;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
            border-radius: 3px;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        .code-icon-bubble {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            flex-shrink: 0;
        }
        .prompt-box {
            background: #fffdf5;
            border: 1px solid #ffeeba;
            padding: 1.25rem;
            border-radius: 6px;
            margin-bottom: 1.25rem;
            text-align: left;
        }
        .explanation-box {
            background: #f9fbfd;
            border: 1px solid #d0e1f9;
            padding: 1rem;
            border-radius: 5px;
            margin-top: 1rem;
            margin-bottom: 1rem;
        }
        .explanation-box h4 {
            color: var(--cerritos-blue);
            margin-top: 0;
            margin-bottom: 0.5rem;
            font-size: 1rem;
        }
        .filter-note {
            background: #eef4fb;
            border-left: 3px solid var(--cerritos-blue);
            padding: 0.5rem 0.75rem;
            margin-bottom: 0.75rem;
            font-size: 0.85rem;
            color: #002b49;
            text-align: left;
            border-radius: 0 3px 3px 0;
        }
        .explanation-box ul {
            margin: 0;
            padding-left: 1.1rem;
            color: #444;
            font-size: 0.85rem;
            line-height: 1.35;
            text-align: left;
        }
        .explanation-box li {
            margin-bottom: 0.3rem;
        }
        .button-group {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-top: 1px solid #eaeaea;
            padding-top: 1rem;
            margin-top: 1.5rem;
        }
        .btn {
            background-color: var(--cerritos-blue);
            color: #ffffff;
            border: none;
            padding: 0.6rem 1.25rem;
            font-size: 0.95rem;
            font-weight: bold;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            transition: background-color 0.15s ease;
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
    </style>
</head>
<body>

<header>
    <h1>Cerritos College Career Exploration</h1>
    <span class="step-indicator">Interest Inventory</span>
</header>

<div class="container">
    <?php if ($show_primary_selector): ?>
        <h2>Select Primary Career Interest Code</h2>
        <div class="prompt-box">
            <p class="intro-text" style="margin-top: 0;">
                Select which category you want as your primary choice to filter your career options:
            </p>
            
            <form method="POST" action="interest_inventory.php">
                <input type="hidden" name="action" value="update_existing_primary">
                
                <div style="margin-bottom: 1.25rem;">
                    <?php foreach ($existing_top_codes as $tcode): 
                        $score_val = $existing_scores[$tcode] ?? '';
                        $st = $riasec_styles[$tcode] ?? ['color' => '#333', 'bg' => '#f1f5f9', 'icon' => '📌'];
                    ?>
                        <label style="display: flex; align-items: center; gap: 0.75rem; background: #fff; padding: 0.6rem 0.85rem; border: 1px solid #ccc; border-radius: 4px; margin-bottom: 0.4rem; cursor: pointer; font-size: 0.9rem;">
                            <input type="radio" name="primary_code" value="<?php echo htmlspecialchars($tcode); ?>" <?php echo ($tcode === $existing_top_codes[0]) ? 'checked' : ''; ?> required>
                            <span style="display: inline-flex; align-items: center; justify-content: center; width: 28px; height: 28px; background: <?php echo $st['bg']; ?>; color: <?php echo $st['color']; ?>; border-radius: 50%; font-weight: bold; font-size: 0.9rem;"><?php echo $st['icon']; ?></span>
                            <div>
                                <?php echo htmlspecialchars($theme_lookup[$tcode] ?? ''); ?><?php echo ($score_val !== '') ? " (<strong>{$score_val} pts</strong>)" : ""; ?>
                            </div>
                        </label>
                    <?php endforeach; ?>
                </div>
                
                <div style="display: flex; gap: 0.75rem;">
                    <button type="submit" class="btn">Save & Continue &rarr;</button>
                    <a href="interest_inventory.php" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    <?php elseif ($show_prompt): ?>
        <h2>Your Assessment Results</h2>
        <div class="results-box">
            <p class="intro-text" style="margin-top: 0;">Here are your top interest categories based on your saved assessment:</p>
            <?php foreach ($existing_top_codes as $index => $code): 
                $score_val = $existing_scores[$code] ?? '';
                $st = $riasec_styles[$code] ?? ['color' => '#333', 'bg' => '#f1f5f9', 'icon' => '📌'];
            ?>
                <div class="top-code-card">
                    <div class="code-icon-bubble" style="background: <?php echo $st['bg']; ?>; color: <?php echo $st['color']; ?>; border: 1px solid <?php echo $st['border']; ?>;"><?php echo $st['icon']; ?></div>
                    <div>
                        <h3 style="margin: 0 0 0.2rem 0; color: var(--cerritos-blue); font-size: 1.05rem;">
                            <?php echo ($index + 1); ?>. <?php echo htmlspecialchars($theme_lookup[$code] ?? $code); ?> 
                            <?php if ($score_val !== ''): ?><span style="font-weight: normal; color: #555; font-size: 0.9rem;">(<?php echo htmlspecialchars($score_val); ?> points)</span><?php endif; ?>
                        </h3>
                        <p style="margin: 0; font-size: 0.85rem; color: #555;"><?php echo htmlspecialchars($riasec_definitions[$code] ?? ''); ?></p>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>

        <div class="button-group">
            <div style="display: flex; gap: 0.5rem; align-items: center;">
                <a href="interest_inventory.php?retake=1" class="btn btn-secondary">Retake Test</a>
                <a href="interest_inventory.php?change_primary=1" class="btn btn-secondary">Change Primary Category</a>
            </div>
            <a href="career_selection.php" class="btn">Proceed to Career Selection &rarr;</a>
        </div>
    <?php elseif ($tie_resolution_mode): ?>
        <h2>Result Resolution</h2>
        <div class="prompt-box">
            <p class="intro-text" style="margin-top: 0;">
                We noticed a tie in your top category scores. Please review the tied categories below and select which one you would like to designate as your <strong>primary</strong> preference. This will be placed first and used to filter your career options.
            </p>
            
            <form method="POST" action="interest_inventory.php">
                <input type="hidden" name="action" value="resolve_tie">
                
                <div style="margin-bottom: 1.25rem;">
                    <?php 
                    $active_scores = $_SESSION['holland_scores'] ?? $scores;
                    foreach ($tied_codes as $tcode): 
                        $score_val = $active_scores[$tcode] ?? '';
                        $st = $riasec_styles[$tcode] ?? ['color' => '#333', 'bg' => '#f1f5f9', 'icon' => '📌'];
                    ?>
                        <label style="display: flex; align-items: center; gap: 0.75rem; background: #fff; padding: 0.6rem 0.85rem; border: 1px solid #ccc; border-radius: 4px; margin-bottom: 0.4rem; cursor: pointer; font-size: 0.9rem;">
                            <input type="radio" name="primary_code" value="<?php echo htmlspecialchars($tcode); ?>" required>
                            <span style="display: inline-flex; align-items: center; justify-content: center; width: 28px; height: 28px; background: <?php echo $st['bg']; ?>; color: <?php echo $st['color']; ?>; border-radius: 50%; font-weight: bold;"><?php echo $st['icon']; ?></span>
                            <div>
                                <?php echo htmlspecialchars($theme_lookup[$tcode] ?? $tcode); ?><?php echo ($score_val !== '') ? " (<strong>{$score_val} pts</strong>)" : ""; ?>
                            </div>
                        </label>
                    <?php endforeach; ?>
                </div>

                <div class="explanation-box" style="background: #ffffff; margin-bottom: 1.25rem;">
                    <h4>Understanding Your Tied Categories:</h4>
                    <ul>
                        <?php foreach ($tied_codes as $code_letter): 
                            $trimmed_letter = trim($code_letter);
                            $score_val = $active_scores[$trimmed_letter] ?? '';
                            $st = $riasec_styles[$trimmed_letter] ?? ['color' => '#333', 'bg' => '#f1f5f9', 'icon' => '📌'];
                            if (isset($riasec_definitions[$trimmed_letter])):
                        ?>
                            <li style="margin-bottom: 0.5rem; display: flex; align-items: flex-start; gap: 0.5rem;">
                                <span style="font-size: 1rem;"><?php echo $st['icon']; ?></span>
                                <div><strong><?php echo htmlspecialchars($theme_lookup[$trimmed_letter] ?? $trimmed_letter); ?><?php echo ($score_val !== '' ? " (" . htmlspecialchars($score_val) . " pts)" : ""); ?>:</strong> <?php echo htmlspecialchars($riasec_definitions[$trimmed_letter]); ?></div>
                            </li>
                        <?php 
                            endif;
                        endforeach; 
                        ?>
                    </ul>
                </div>
                
                <button type="submit" class="btn">Confirm Primary Selection &rarr;</button>
            </form>
        </div>
    <?php elseif ($results_mode): ?>
        <h2>Your Assessment Results</h2>
        <div class="results-box">
            <p class="intro-text" style="margin-top: 0;">Here are your top interest categories based on your responses:</p>
            <?php foreach ($_SESSION['top_holland_codes'] as $index => $code): 
                $score_val = $scores[$code] ?? $_SESSION['holland_scores'][$code] ?? '';
                $st = $riasec_styles[$code] ?? ['color' => '#333', 'bg' => '#f1f5f9', 'icon' => '📌'];
            ?>
                <div class="top-code-card">
                    <div class="code-icon-bubble" style="background: <?php echo $st['bg']; ?>; color: <?php echo $st['color']; ?>; border: 1px solid <?php echo $st['border']; ?>;"><?php echo $st['icon']; ?></div>
                    <div>
                        <h3 style="margin: 0 0 0.2rem 0; color: var(--cerritos-blue); font-size: 1.05rem;">
                            <?php echo ($index + 1); ?>. <?php echo htmlspecialchars($theme_lookup[$code] ?? $code); ?> 
                            <?php if ($score_val !== ''): ?><span style="font-weight: normal; color: #555; font-size: 0.9rem;">(<?php echo htmlspecialchars($score_val); ?> points)</span><?php endif; ?>
                        </h3>
                        <p style="margin: 0; font-size: 0.85rem; color: #555;"><?php echo htmlspecialchars($riasec_definitions[$code] ?? ''); ?></p>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>

        <div class="button-group">
            <a href="interest_inventory.php?retake=1" class="btn btn-secondary">Retake Test</a>
            <a href="career_selection.php" class="btn">Proceed to Career Selection &rarr;</a>
        </div>
    <?php else: ?>
        <p class="intro-text">
            Rate how much you enjoy or prefer each activity below. Your responses will help determine your preferences to guide your career exploration.
        </p>

        <div class="scale-legend">
            <div class="scale-legend-title">Rating Scale:</div>
            <div class="scale-legend-item"><span class="scale-legend-badge">1</span> Strongly Dislike</div>
            <div class="scale-legend-item"><span class="scale-legend-badge">2</span> Dislike</div>
            <div class="scale-legend-item"><span class="scale-legend-badge">3</span> Neutral</div>
            <div class="scale-legend-item"><span class="scale-legend-badge">4</span> Like</div>
            <div class="scale-legend-item"><span class="scale-legend-badge">5</span> Strongly Like</div>
        </div>

        <form method="POST" action="interest_inventory.php">
            <input type="hidden" name="action" value="submit_inventory">

            <div class="questions-grid">
                <?php foreach ($selected_subset as $index => $item): 
                    $code = $item['code'] ?? '';
                ?>
                    <div class="question-card">
                        <div class="question-header-row">
                            <span class="q-number">Q<?php echo ($index + 1); ?></span>
                        </div>
                        <div class="question-text"><?php echo htmlspecialchars($item['activity'] ?? $item['description'] ?? ''); ?></div>
                        
                        <div class="likert-scale">
                            <?php for ($i = 1; $i <= 5; $i++): ?>
                                <label class="likert-option">
                                    <input type="radio" name="score[<?php echo htmlspecialchars($code); ?>][<?php echo $index; ?>]" value="<?php echo $i; ?>" required>
                                    <?php echo $i; ?>
                                </label>
                            <?php endfor; ?>
                        </div>
                    </div>
                <?php endforeach; ?>
            </div>

            <div class="button-group">
                <a href="goals.php" class="btn btn-secondary">&larr; Back to Goals</a>
                <button type="submit" class="btn">Calculate Results &rarr;</button>
            </div>
        </form>
    <?php endif; ?>
</div>

</body>
</html>