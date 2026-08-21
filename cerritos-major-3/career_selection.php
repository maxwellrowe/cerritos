<?php
// Prevent browser caching
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Pragma: no-cache");

session_start();

// Ensure applicant data exists
if (!isset($_SESSION['applicant'])) {
    header('Location: index.php');
    exit;
}

$applicant = $_SESSION['applicant'];

// Handle career selection form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'save_careers') {
    $selected_careers = $_POST['selected_careers'] ?? [];
    
    if (count($selected_careers) >= 1 && count($selected_careers) <= 3) {
        $_SESSION['selected_careers'] = $selected_careers;
        
        $currentTime = date('Y-m-d H:i:s');
        
        $applicant['selected_careers'] = $selected_careers;
        $applicant['last_updated'] = $currentTime;
        $_SESSION['applicant'] = $applicant;
        
        header('Location: majors.php');
        exit;
    } else {
        $error_message = "Please select at least 1 and up to 3 careers before continuing to majors.";
    }
}

// Load degrees.json
$jsonFile = 'degrees.json';
$degrees_data = [];
if (file_exists($jsonFile)) {
    $raw_json = file_get_contents($jsonFile);
    $decoded = json_decode($raw_json, true);
    if (is_array($decoded)) {
        $degrees_data = $decoded;
    }
}

// Extract applicant filters correctly from goals / LCP / undecided RIASEC code logic
$lcp = trim($applicant['lcp'] ?? $applicant['pathway_used'] ?? $applicant['pathway'] ?? $_SESSION['pathway'] ?? $_SESSION['lcp'] ?? '');

// Helper function for flexible LCP/Pathway token matching
function matches_lcp_pathway($career_lcp, $user_lcp) {
    if (empty($career_lcp) || empty($user_lcp)) return true;
    
    // Direct match or full string inclusion
    if (strcasecmp($career_lcp, $user_lcp) === 0 || 
        stripos($career_lcp, $user_lcp) !== false || 
        stripos($user_lcp, $career_lcp) !== false) {
        return true;
    }
    
    // Tokenize both pathway strings and compare common non-stopword tokens
    $user_words = array_diff(preg_split('/[\s,\&\/]+/', strtolower($user_lcp)), ['and', '&', 'or', '']);
    $career_words = array_diff(preg_split('/[\s,\&\/]+/', strtolower($career_lcp)), ['and', '&', 'or', '']);
    
    return count(array_intersect($user_words, $career_words)) > 0;
}

// Robust extraction of all possible RIASEC / Holland structures for Primary code detection
$riasec_code = '';

if (isset($applicant['top_three_codes']) && is_array($applicant['top_three_codes']) && !empty($applicant['top_three_codes'])) {
    $riasec_code = trim($applicant['top_three_codes'][0]);
}
if (empty($riasec_code) && isset($_SESSION['top_three_codes']) && is_array($_SESSION['top_three_codes']) && !empty($_SESSION['top_three_codes'])) {
    $riasec_code = trim($_SESSION['top_three_codes'][0]);
}
if (empty($riasec_code) && isset($_SESSION['top_holland_codes']) && is_array($_SESSION['top_holland_codes']) && !empty($_SESSION['top_holland_codes'])) {
    $riasec_code = trim($_SESSION['top_holland_codes'][0]);
}
if (empty($riasec_code) && !empty($applicant['riasec_code'])) {
    $riasec_code = trim($applicant['riasec_code']);
}
if (empty($riasec_code) && !empty($applicant['riasec'])) {
    $riasec_code = trim($applicant['riasec']);
}
if (empty($riasec_code) && !empty($applicant['holland_code'])) {
    $riasec_code = trim($applicant['holland_code']);
}

// Deep recursive scanner to locate any hidden riasec keys or score arrays if still empty
$all_found_riasec_structures = [];
function deep_scan_riasec($data, $path = '') {
    global $all_found_riasec_structures;
    if (!is_array($data)) return;
    foreach ($data as $k => $v) {
        $current_path = $path ? "{$path}.{$k}" : $k;
        if (stripos($k, 'riasec') !== false || stripos($k, 'holland') !== false || stripos($k, 'code') !== false || stripos($k, 'score') !== false) {
            $all_found_riasec_structures[$current_path] = $v;
        }
        if (is_array($v)) {
            deep_scan_riasec($v, $current_path);
        }
    }
}
deep_scan_riasec($applicant, 'applicant');
deep_scan_riasec($_SESSION, 'session');

if (empty($riasec_code)) {
    foreach ($all_found_riasec_structures as $path => $val) {
        if (is_array($val) && !empty($val[0]) && is_string($val[0])) {
            $riasec_code = trim($val[0]);
            break;
        } elseif (is_string($val) && strlen(trim($val)) > 0) {
            $riasec_code = trim(substr($val, 0, 1));
            break;
        }
    }
}

// Check if user selected Exploration & Discovery or Undecided
$is_exploration = (strcasecmp($lcp, 'Exploration & Discovery') === 0 || strcasecmp($lcp, 'Exploration and Discovery') === 0 || stripos($lcp, 'Exploration') !== false || stripos($lcp, 'Undecided') !== false || stripos($lcp, "Not Sure") !== false);

// Extract top_priority from applicant array
$top_priority = trim($applicant['top_priority'] ?? $applicant['forced_choice'] ?? $applicant['priority'] ?? $applicant['primary_goal'] ?? '');
if (empty($top_priority)) {
    $goals_priorities = $applicant['goals_and_priorities'] ?? $applicant['goals'] ?? [];
    if (is_array($goals_priorities)) {
        $top_priority = trim($goals_priorities['top_priority'] ?? $goals_priorities['forced_choice'] ?? $goals_priorities['primary'] ?? '');
    }
}

// Check if user specified searching by interest / matches my interests
$is_interest_priority = (stripos($top_priority, 'matches my interests') !== false || stripos($top_priority, 'interest') !== false);

$show_all_lcp = isset($_GET['show_all']) && $_GET['show_all'] === '1';

// Universal recursive extractor to find ANY array item containing a "title" key and inherit credentials
$all_extracted_career_nodes = [];
function extract_all_title_nodes($data, &$results, $inherited_lcp = '', $inherited_riasec = '', $inherited_type = '', $inherited_degree_req = '') {
    if (!is_array($data)) return;
    
    $current_lcp = $inherited_lcp;
    if (isset($data['pathway_used']) && is_string($data['pathway_used'])) {
        $current_lcp = trim($data['pathway_used']);
    } elseif (isset($data['lcp']) && is_string($data['lcp'])) {
        $current_lcp = trim($data['lcp']);
    }
    
    $current_riasec = $inherited_riasec;
    if (isset($data['riasec_code']) && is_string($data['riasec_code'])) {
        $current_riasec = trim($data['riasec_code']);
    } elseif (isset($data['riasec']) && is_string($data['riasec'])) {
        $current_riasec = trim($data['riasec']);
    }

    $current_type = $inherited_type;
    if (isset($data['credential_type']) && is_string($data['credential_type'])) {
        $current_type = trim($data['credential_type']);
    } elseif (isset($data['credential_category']) && is_string($data['credential_category'])) {
        $current_type = trim($data['credential_category']);
    }

    $current_degree_req = $inherited_degree_req;
    if (isset($data['degree_required'])) {
        if (is_bool($data['degree_required'])) {
            $current_degree_req = $data['degree_required'] ? 'Yes' : 'No';
        } elseif (is_string($data['degree_required'])) {
            $current_degree_req = trim($data['degree_required']);
        }
    }
    
    if (isset($data['title']) && is_string($data['title']) && trim($data['title']) !== '') {
        $results[] = [
            'node' => $data,
            'inherited_lcp' => $current_lcp,
            'inherited_riasec' => $current_riasec,
            'inherited_type' => $current_type,
            'inherited_degree_req' => $current_degree_req
        ];
    }
    
    foreach ($data as $key => $value) {
        if (is_array($value)) {
            $next_lcp = $current_lcp;
            if ($key === 'pathway_used' || $key === 'lcp' || (is_string($key) && stripos($key, 'pathway') !== false)) {
                if (is_string($value)) $next_lcp = trim($value);
            }
            $next_riasec = $current_riasec;
            if ($key === 'riasec_code' || $key === 'riasec') {
                if (is_string($value)) $next_riasec = trim($value);
            }
            $next_type = $current_type;
            if ($key === 'credential_type' || $key === 'credential_category') {
                if (is_string($value)) $next_type = trim($value);
            }
            $next_degree_req = $current_degree_req;
            if ($key === 'degree_required') {
                if (is_bool($value)) {
                    $next_degree_req = $value ? 'Yes' : 'No';
                } elseif (is_string($value)) {
                    $next_degree_req = trim($value);
                }
            }
            extract_all_title_nodes($value, $results, $next_lcp, $next_riasec, $next_type, $next_degree_req);
        }
    }
}

extract_all_title_nodes($degrees_data, $all_extracted_career_nodes);

// Collect all matched careers based on LCP / RIASEC / Top Priority
$initial_matching_careers = [];

foreach ($all_extracted_career_nodes as $entry) {
    $career = $entry['node'];
    $inherited_lcp = $entry['inherited_lcp'];
    $inherited_riasec = $entry['inherited_riasec'];
    
    $career_title = trim($career['title']);
    if ($career_title === 'General Career Pathway') continue;
    
    $career_lcp = trim($career['pathway_used'] ?? $career['lcp'] ?? $inherited_lcp);
    $career_riasec = trim($career['riasec_code'] ?? $career['riasec'] ?? $inherited_riasec);
    $career_salary = trim($career['median_salary'] ?? '');
    $career_growth = trim($career['growth_rate'] ?? '');
    $career_type = trim($career['type'] ?? $career['credential_type'] ?? $career['credential_category'] ?? $entry['inherited_type']);
    
    $raw_deg_req = $career['degree_required'] ?? $entry['inherited_degree_req'];
    if (is_bool($raw_deg_req)) {
        $career_degree_required = $raw_deg_req ? 'Yes' : 'No';
    } else {
        $career_degree_required = trim($raw_deg_req);
    }
    
    $filter_match = false;
    
    $has_specific_lcp = (!empty($lcp) && !$is_exploration);

    if ($has_specific_lcp && $is_interest_priority) {
        $lcp_match = matches_lcp_pathway($career_lcp, $lcp);
        $riasec_match = (
            empty($riasec_code) || 
            empty($career_riasec) || 
            strcasecmp($career_riasec, $riasec_code) === 0 || 
            stripos($career_riasec, $riasec_code) !== false || 
            stripos($riasec_code, $career_riasec) !== false || 
            strncasecmp($career_riasec, $riasec_code, 1) === 0
        );
        
        if ($lcp_match && $riasec_match) {
            $filter_match = true;
        }
    } elseif ($has_specific_lcp && !$is_interest_priority) {
        if (matches_lcp_pathway($career_lcp, $lcp)) {
            $filter_match = true;
        }
    } elseif ($is_exploration || $is_interest_priority) {
        if (!empty($riasec_code) && !empty($career_riasec)) {
            if (strcasecmp($career_riasec, $riasec_code) === 0 || 
                stripos($career_riasec, $riasec_code) !== false || 
                stripos($riasec_code, $career_riasec) !== false ||
                strncasecmp($career_riasec, $riasec_code, 1) === 0) {
                $filter_match = true;
            }
        } else {
            $filter_match = true;
        }
    } else {
        if (empty($lcp) || matches_lcp_pathway($career_lcp, $lcp)) {
            $filter_match = true;
        }
    }
    
    $priority_match = true;
    if ($filter_match && !$show_all_lcp && !empty($top_priority) && !$is_interest_priority) {
        if (stripos($top_priority, 'high earning potential') !== false || stripos($top_priority, 'earning') !== false) {
            if (!(strcasecmp($career_salary, 'High') === 0 || stripos($career_salary, 'High') !== false)) {
                $priority_match = false;
            }
        } elseif (stripos($top_priority, 'strong growth potential') !== false || stripos($top_priority, 'growth') !== false) {
            if (!(strcasecmp($career_growth, 'High') === 0 || stripos($career_growth, 'High') !== false)) {
                $priority_match = false;
            }
        } elseif (stripos($top_priority, 'start quickly') !== false || stripos($top_priority, 'without much training') !== false) {
            if (!(strcasecmp($career_type, 'CERT') === 0 || strcasecmp($career_type, 'Certificate') === 0 || stripos($career_type, 'cert') !== false)) {
                $priority_match = false;
            }
        }
    }
    
    if ($filter_match && $priority_match) {
        $initial_matching_careers[] = [
            'title' => $career_title,
            'lcp' => $career_lcp ?: ($lcp ?: 'General Pathway'),
            'riasec' => $career_riasec,
            'median_salary' => $career_salary,
            'growth_rate' => $career_growth,
            'degree_required' => $career_degree_required,
            'description' => $career['description'] ?? 'Explore rewarding career opportunities in this field.'
        ];
    }
}

// FALLBACK: If strict Pathway + RIASEC combination returned 0 results, match by Pathway alone
if (empty($initial_matching_careers) && !empty($lcp) && !$is_exploration) {
    foreach ($all_extracted_career_nodes as $entry) {
        $career = $entry['node'];
        $career_title = trim($career['title'] ?? '');
        if ($career_title === 'General Career Pathway' || empty($career_title)) continue;

        $career_lcp = trim($career['pathway_used'] ?? $career['lcp'] ?? $entry['inherited_lcp']);
        
        if (matches_lcp_pathway($career_lcp, $lcp)) {
            $initial_matching_careers[] = [
                'title' => $career_title,
                'lcp' => $career_lcp ?: $lcp,
                'riasec' => trim($career['riasec_code'] ?? $career['riasec'] ?? $entry['inherited_riasec']),
                'median_salary' => trim($career['median_salary'] ?? ''),
                'growth_rate' => trim($career['growth_rate'] ?? ''),
                'degree_required' => isset($career['degree_required']) ? ($career['degree_required'] ? 'Yes' : 'No') : $entry['inherited_degree_req'],
                'description' => $career['description'] ?? 'Explore rewarding career opportunities in this field.'
            ];
        }
    }
}

// Deduplicate initial matches
$unique_initial = [];
$seen_titles = [];
foreach ($initial_matching_careers as $c) {
    if (!in_array($c['title'], $seen_titles)) {
        $seen_titles[] = $c['title'];
        $unique_initial[] = $c;
    }
}
$initial_matching_careers = $unique_initial;

// Apply conditional rule: If more than 10 careers, prioritize and cap at first 10 showing growth (High first, then Medium)
$growth_filtered_applied = false;
$matching_careers = $initial_matching_careers;

if (count($initial_matching_careers) > 10 && !$show_all_lcp) {
    $high_growth = [];
    $medium_growth = [];
    $other_growth = [];
    
    foreach ($initial_matching_careers as $c) {
        $g = trim($c['growth_rate']);
        if (strcasecmp($g, 'High') === 0 || stripos($g, 'High') !== false) {
            $high_growth[] = $c;
        } elseif (strcasecmp($g, 'Medium') === 0 || stripos($g, 'Medium') !== false) {
            $medium_growth[] = $c;
        } else {
            $other_growth[] = $c;
        }
    }
    
    usort($high_growth, function($a, $b) { return strcasecmp($a['title'], $b['title']); });
    usort($medium_growth, function($a, $b) { return strcasecmp($a['title'], $b['title']); });
    usort($other_growth, function($a, $b) { return strcasecmp($a['title'], $b['title']); });
    
    $combined_sorted = array_merge($high_growth, $medium_growth, $other_growth);
    $matching_careers = array_slice($combined_sorted, 0, 10);
    $growth_filtered_applied = true;
} else {
    usort($matching_careers, function($a, $b) {
        return strcasecmp($a['title'], $b['title']);
    });
}

$total_matching_count = count($matching_careers);
$initial_total_count = count($initial_matching_careers);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cerritos College - Career Selection</title>
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
            max-width: 1100px;
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
        .intro-text {
            margin-bottom: 1.5rem;
            color: #555;
            line-height: 1.5;
        }
        .summary-box {
            background-color: #eef6fc;
            border-left: 4px solid var(--cerritos-blue);
            padding: 1rem 1.25rem;
            margin-bottom: 1.5rem;
            border-radius: 0 4px 4px 0;
        }
        .notice-banner {
            background-color: #fff3cd;
            color: #856404;
            padding: 1rem;
            border: 1px solid #ffeeba;
            border-radius: 4px;
            margin-top: 1.5rem;
            margin-bottom: 1.5rem;
        }
        .notice-banner a {
            color: #002b49;
            font-weight: bold;
            text-decoration: underline;
        }
        .error-banner {
            background: #f8d7da;
            color: #721c24;
            padding: 1rem;
            border: 1px solid #f5c6cb;
            border-radius: 4px;
            margin-bottom: 1.5rem;
        }
        .career-card {
            background: #fdfdfd;
            border: 1px solid #e1e8ed;
            border-radius: 6px;
            padding: 1.25rem;
            margin-bottom: 1.0rem;
            display: flex;
            align-items: flex-start;
            gap: 1rem;
            transition: border-color 0.2s, background-color 0.2s;
            cursor: pointer;
        }
        .career-card:hover {
            border-color: var(--cerritos-blue);
            background-color: #f1f7ff;
        }
        .career-card input[type="checkbox"] {
            margin-top: 0.3rem;
            transform: scale(1.2);
            cursor: pointer;
        }
        .career-info h3 {
            margin: 0 0 0.4rem 0;
            color: var(--cerritos-blue);
            font-size: 1.1rem;
        }
        .career-meta {
            font-size: 0.85rem;
            color: #666;
            margin-bottom: 0.5rem;
        }
        .badge {
            display: inline-block;
            background: #e2e8f0;
            color: #333;
            padding: 0.2rem 0.5rem;
            border-radius: 3px;
            font-size: 0.75rem;
            font-weight: bold;
            margin-right: 0.5rem;
            margin-bottom: 0.3rem;
        }
        .badge-salary { background: #d4edda; color: #155724; }
        .badge-growth { background: #d1ecf1; color: #0c5460; }
        .badge-degree { background: #fef3c7; color: #92400e; }
        
        #description-tooltip {
            position: fixed;
            z-index: 9999;
            width: 320px;
            max-width: 90vw;
            padding: 15px;
            background-color: #ffffff;
            color: var(--cerritos-dark);
            border: 1px solid #cbd5e1;
            border-left: 4px solid var(--cerritos-blue);
            border-radius: 6px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
            pointer-events: none;
            display: none;
            opacity: 0;
            transition: opacity 0.15s ease-in-out;
        }
        #description-tooltip h3 {
            margin-top: 0;
            margin-bottom: 8px;
            color: var(--cerritos-blue);
            font-size: 1rem;
        }
        #description-tooltip p {
            margin: 0;
            color: #475569;
            font-size: 0.85rem;
            line-height: 1.4;
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
        .counter-display {
            font-weight: bold;
            color: var(--cerritos-blue);
        }
    </style>
</head>
<body>

<header>
    <h1>Cerritos College Career Exploration</h1>
    <span class="step-indicator">Career Selection</span>
</header>

<div class="container">
    <h2>Matched Careers</h2>
    
    <div class="summary-box">
        <strong>Total Matching Careers Listed:</strong> <?php echo $total_matching_count; ?> 
        <?php if ($growth_filtered_applied): ?>
            <em>(Capped at first 10 from <?php echo $initial_total_count; ?> total matches, sorted by growth: High then Medium)</em>
        <?php endif; ?><br>
        <strong>User Target Filter:</strong> <?php echo htmlspecialchars((!$is_exploration && !empty($lcp) && $is_interest_priority) ? "Pathway: {$lcp} + Primary RIASEC Code: " . ($riasec_code ?: 'None') : (($is_exploration || $is_interest_priority) ? "Primary RIASEC Code: " . ($riasec_code ?: 'None') : ($lcp ?: 'All Pathways'))); ?><br>
        <?php if (!empty($top_priority)): ?>
            <strong>Top Priority Filter (`top_priority`):</strong> 
            <?php echo $show_all_lcp ? htmlspecialchars($top_priority) . ' <em>(Bypassed - Showing All Careers)</em>' : htmlspecialchars($top_priority); ?>
        <?php else: ?>
            <strong>Top Priority Filter (`top_priority`):</strong> None set
        <?php endif; ?>
    </div>

    <p class="intro-text">
        Please select up to <strong>3 careers</strong> below to proceed to major recommendations (you can proceed with fewer). Hover over any career card to view details.
    </p>

    <?php if (isset($error_message)): ?>
        <div class="error-banner">
            <?php echo htmlspecialchars($error_message); ?>
        </div>
    <?php endif; ?>

    <form method="POST" action="career_selection.php<?php echo $show_all_lcp ? '?show_all=1' : ''; ?>" id="careerForm">
        <input type="hidden" name="action" value="save_careers">

        <div style="margin-bottom: 1rem; display: flex; justify-content: space-between; align-items: center;">
            <div>Selected: <span id="selectedCount" class="counter-display">0</span> of up to 3 allowed</div>
        </div>

        <?php if (empty($matching_careers)): ?>
            <div class="error-banner">
                No matching careers found matching your criteria.
            </div>
        <?php else: ?>
            <?php foreach ($matching_careers as $index => $career): ?>
                <div class="career-card"
                     data-name="<?php echo htmlspecialchars($career['title']); ?>"
                     data-description="<?php echo htmlspecialchars(!empty($career['description']) ? $career['description'] : 'Explore rewarding career opportunities in this field.'); ?>"
                     onmousemove="moveTooltip(event, this)"
                     onmouseenter="showTooltip(event, this)"
                     onmouseleave="hideTooltip()"
                     onclick="toggleCardCheckbox(this, event)">
                    
                    <input type="checkbox" name="selected_careers[]" value="<?php echo htmlspecialchars($career['title']); ?>" id="career_<?php echo $index; ?>" class="career-checkbox" onclick="event.stopPropagation();">
                    
                    <div class="career-info" style="flex-grow: 1;">
                        <label for="career_<?php echo $index; ?>" style="cursor: pointer;" onclick="event.stopPropagation();">
                            <h3><?php echo htmlspecialchars($career['title']); ?></h3>
                        </label>
                        <div class="career-meta">
                            <span class="badge">Pathway: <?php echo htmlspecialchars($career['lcp']); ?></span>
                            <?php if (!empty($career['riasec'])): ?>
                                <span class="badge" style="background: #e2d9f3; color: #432874;">RIASEC: <?php echo htmlspecialchars($career['riasec']); ?></span>
                            <?php endif; ?>
                            <?php if (!empty($career['median_salary'])): ?>
                                <span class="badge badge-salary">Salary: <?php echo htmlspecialchars($career['median_salary']); ?></span>
                            <?php endif; ?>
                            <?php if (!empty($career['growth_rate'])): ?>
                                <span class="badge badge-growth">Growth: <?php echo htmlspecialchars($career['growth_rate']); ?></span>
                            <?php endif; ?>
                            <?php if (!empty($career['degree_required'])): ?>
                                <span class="badge badge-degree">Degree Required: <?php echo htmlspecialchars($career['degree_required']); ?></span>
                            <?php endif; ?>
                        </div>
                        <p style="margin: 0; font-size: 0.95rem; color: #444;"><?php echo htmlspecialchars($career['description']); ?></p>
                    </div>
                </div>
            <?php endforeach; ?>
        <?php endif; ?>

        <div id="description-tooltip">
            <h3 id="tooltip-title">Career Description</h3>
            <p id="tooltip-text"></p>
        </div>

        <?php if ($initial_total_count < 10 && !$show_all_lcp): ?>
            <div class="notice-banner">
                Fewer than 10 careers match your initial filter settings (<?php echo $initial_total_count; ?> found). 
                If you would like to see all of the careers, please <a href="career_selection.php?show_all=1">click here</a>.
            </div>
        <?php elseif ($growth_filtered_applied && !$show_all_lcp): ?>
            <div class="notice-banner">
                More than 10 careers were initially matched (<?php echo $initial_total_count; ?> found), so the list has been restricted to the first 10 ordered by growth (prioritizing <strong>High</strong>, then <strong>Medium</strong>). 
                To view all matching careers without this restriction, <a href="career_selection.php?show_all=1">click here</a>.
            </div>
        <?php elseif ($show_all_lcp): ?>
            <div class="notice-banner" style="background-color: #d1ecf1; color: #0c5460; border-color: #bee5eb;">
                You are currently viewing all careers (growth and top priority filters bypassed). 
                <a href="career_selection.php" style="color: #002b49;">Click here to reapply filters</a>.
            </div>
        <?php endif; ?>

        <div class="button-group">
            <a href="goals.php" class="btn btn-secondary">&larr; Back to Goals</a>
            <button type="submit" class="btn" id="submitBtn">Proceed to Majors &rarr;</button>
        </div>
    </form>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const checkboxes = document.querySelectorAll('.career-checkbox');
        const counterDisplay = document.getElementById('selectedCount');
        const submitBtn = document.getElementById('submitBtn');

        function updateSelectionCount() {
            const checkedCount = document.querySelectorAll('.career-checkbox:checked').length;
            counterDisplay.textContent = checkedCount;
            
            if (checkedCount >= 1 && checkedCount <= 3) {
                submitBtn.style.opacity = '1';
                submitBtn.removeAttribute('disabled');
            } else if (checkedCount === 0) {
                submitBtn.style.opacity = '0.7';
            }
        }

        checkboxes.forEach(cb => {
            cb.addEventListener('change', function() {
                const checkedCount = document.querySelectorAll('.career-checkbox:checked').length;
                if (checkedCount > 3) {
                    this.checked = false;
                    alert('You selected a maximum of 3 careers.');
                }
                updateSelectionCount();
            });
        });

        updateSelectionCount();
    });

    function showTooltip(event, element) {
        const title = element.getAttribute('data-name');
        const description = element.getAttribute('data-description');
        
        const tooltipBox = document.getElementById('description-tooltip');
        document.getElementById('tooltip-title').textContent = title;
        document.getElementById('tooltip-text').textContent = description;

        updateTooltipPosition(event);
        
        tooltipBox.style.display = 'block';
        tooltipBox.style.opacity = '1';
    }

    function moveTooltip(event) {
        updateTooltipPosition(event);
    }

    function updateTooltipPosition(event) {
        const tooltipBox = document.getElementById('description-tooltip');
        const offsetX = 20;
        const offsetY = 15;
        
        let posX = event.clientX + offsetX;
        let posY = event.clientY + offsetY;

        const tooltipWidth = tooltipBox.offsetWidth;
        if (posX + tooltipWidth > window.innerWidth) {
            posX = event.clientX - tooltipWidth - 10;
        }

        const tooltipHeight = tooltipBox.offsetHeight;
        if (posY + tooltipHeight > window.innerHeight) {
            posY = event.clientY - tooltipHeight - 10;
        }

        tooltipBox.style.left = posX + 'px';
        tooltipBox.style.top = posY + 'px';
    }

    function hideTooltip() {
        const tooltipBox = document.getElementById('description-tooltip');
        tooltipBox.style.opacity = '0';
        tooltipBox.style.display = 'none';
    }

    function toggleCardCheckbox(cardElement, event) {
        const checkbox = cardElement.querySelector('input[type="checkbox"]');
        if (checkbox) {
            checkbox.checked = !checkbox.checked;
            checkbox.dispatchEvent(new Event('change'));
        }
    }
</script>

</body>
</html>