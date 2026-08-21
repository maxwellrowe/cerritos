<?php
// Prevent browser caching
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Pragma: no-cache");

require_once __DIR__ . '/app_bootstrap.php';

// Ensure applicant data exists
if (!isset($_SESSION['applicant'])) {
    header('Location: index.php');
    exit;
}

$applicant = $_SESSION['applicant'];

// Handle career selection form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'save_careers') {
    require_valid_csrf();
    $selected_careers = $_POST['selected_careers'] ?? [];
    
    // Ensure selected_careers is strictly a native PHP array
    if (is_string($selected_careers)) {
        $decoded = json_decode($selected_careers, true);
        $selected_careers = is_array($decoded) ? $decoded : [$selected_careers];
    } elseif (!is_array($selected_careers)) {
        $selected_careers = [];
    }
    
    // Validate that between 1 and 3 careers are chosen
    if (count($selected_careers) >= 1 && count($selected_careers) <= 3) {
        $currentTime = date('Y-m-d H:i:s');
        
        $selected_careers = array_values(array_map('strval', $selected_careers));

        $_SESSION['selected_careers'] = $selected_careers;
        
        $applicant['selected_careers'] = $selected_careers;
        $applicant['last_updated'] = $currentTime;
        $_SESSION['applicant'] = $applicant;
        
        header('Location: majors.php');
        exit;
    } else {
        $error_message = "Please select at least 1 and up to 3 careers before continuing to majors.";
    }
}

// Load degrees.json for career options lookup
$jsonFile = 'degrees.json';
$degrees_data = [];
$json_error_msg = '';

if (file_exists($jsonFile)) {
    $raw_json = file_get_contents($jsonFile);
    $decoded = json_decode($raw_json, true);
    if (is_array($decoded)) {
        $degrees_data = $decoded;
    } else {
        $json_error_msg = json_last_error_msg();
        error_log("JSON Decode Error in degrees.json: " . $json_error_msg);
    }
} else {
    $json_error_msg = "File 'degrees.json' not found at path.";
}

// Extract applicant filters
$lcp = trim($applicant['lcp'] ?? $applicant['pathway_used'] ?? '');

// Extract RIASEC code explicitly supporting top_three_codes array, top_code, riasec_code, etc.
$full_riasec_code = '';

function find_riasec_in_data($data, &$target_code) {
    if (!is_array($data)) return;
    
    if (isset($data['top_three_codes']) && is_array($data['top_three_codes']) && !empty($data['top_three_codes'])) {
        $target_code = strtoupper(implode('', array_map('trim', $data['top_three_codes'])));
        return;
    }
    if (isset($data['top_holland_codes']) && is_array($data['top_holland_codes']) && !empty($data['top_holland_codes'])) {
        $target_code = strtoupper(implode('', array_map('trim', $data['top_holland_codes'])));
        return;
    }
    if (isset($data['riasec_code']) && is_string($data['riasec_code']) && trim($data['riasec_code']) !== '') {
        $target_code = strtoupper(trim($data['riasec_code']));
        return;
    }
    if (isset($data['riasec']) && is_string($data['riasec']) && trim($data['riasec']) !== '') {
        $target_code = strtoupper(trim($data['riasec']));
        return;
    }
    
    foreach ($data as $key => $val) {
        if (is_array($val)) {
            find_riasec_in_data($val, $target_code);
            if (!empty($target_code)) return;
        }
    }
}

find_riasec_in_data($_SESSION, $full_riasec_code);

// Fallback direct checks if recursive search didn't catch it
if (empty($full_riasec_code)) {
    $top_codes = $_SESSION['top_holland_codes'] ?? $applicant['top_three_codes'] ?? [];
    if (is_array($top_codes) && !empty($top_codes)) {
        $full_riasec_code = strtoupper(implode('', array_map('trim', $top_codes)));
    }
}

// Extract primary 3 letters for comparison
$riasec_3 = substr($full_riasec_code, 0, 3);
$primary_letter = !empty($riasec_3) ? $riasec_3[0] : ''; // e.g. 'E' from 'EIS'

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

// RIASEC-driven mode applies ONLY for Exploration & Discovery OR when explicitly prioritizing Interests
$priority_wants_interests = (stripos($top_priority, 'matches my interests') !== false || stripos($top_priority, 'interest') !== false);
$is_riasec_driven = ($is_exploration || $priority_wants_interests);

// Check if user requested to expand results
$show_all_lcp = isset($_GET['show_all']) && $_GET['show_all'] === '1';

// Helper to extract RIASEC string from any node object
function get_node_riasec($node) {
    if (!is_array($node)) return '';
    $raw = $node['riasec_code'] ?? $node['riasec'] ?? $node['holland_code'] ?? '';
    if (is_array($raw)) {
        return strtoupper(implode('', array_map('trim', $raw)));
    }
    return strtoupper(trim((string)$raw));
}

// Robust extractor to find ANY array item containing career title variations
$all_extracted_career_nodes = [];
function extract_all_title_nodes($data, &$results, $inherited_lcp = '', $inherited_riasec = '') {
    if (!is_array($data)) return;
    
    $current_lcp = $inherited_lcp;
    if (isset($data['pathway_used']) && is_string($data['pathway_used'])) {
        $current_lcp = trim($data['pathway_used']);
    } elseif (isset($data['lcp']) && is_string($data['lcp'])) {
        $current_lcp = trim($data['lcp']);
    }
    
    $node_riasec = get_node_riasec($data);
    $current_riasec = !empty($node_riasec) ? $node_riasec : $inherited_riasec;
    
    // Check multiple common key aliases for title
    $title_key = null;
    foreach (['title', 'career_title', 'job_title', 'name', 'career'] as $possible_key) {
        if (isset($data[$possible_key]) && is_string($data[$possible_key]) && trim($data[$possible_key]) !== '') {
            $title_key = $possible_key;
            break;
        }
    }

    if ($title_key !== null) {
        $data['title'] = trim($data[$title_key]);

        $results[] = [
            'node' => $data,
            'inherited_lcp' => $current_lcp,
            'inherited_riasec' => $current_riasec
        ];
    }
    
    foreach ($data as $key => $value) {
        if (is_array($value)) {
            $next_lcp = $current_lcp;
            if ($key === 'pathway_used' || $key === 'lcp' || (is_string($key) && stripos($key, 'pathway') !== false)) {
                if (is_string($value)) $next_lcp = trim($value);
            }
            extract_all_title_nodes($value, $results, $next_lcp, $current_riasec);
        }
    }
}

extract_all_title_nodes($degrees_data, $all_extracted_career_nodes);

// Collect all pathway-matched careers
$pathway_matched_careers = [];

foreach ($all_extracted_career_nodes as $entry) {
    $career = $entry['node'];
    $inherited_lcp = $entry['inherited_lcp'];
    $inherited_riasec = $entry['inherited_riasec'];
    
    $career_title = trim($career['title']);
    if ($career_title === 'General Career Pathway') continue;
    
    $career_lcp = trim($career['pathway_used'] ?? $career['lcp'] ?? $inherited_lcp);
    $career_riasec = strtoupper(trim(get_node_riasec($career) ?: $inherited_riasec));
    $career_salary = trim($career['median_salary'] ?? '');
    $career_growth = trim($career['growth_rate'] ?? '');
    $career_type = trim($career['type'] ?? $career['credential_type'] ?? '');
    $career_degree_required = trim($career['degree_required'] ?? '');
    
    $filter_match = false;
    $match_score = 0;           // Number of matched RIASEC letters (2 or 3)
    $starts_with_primary = 0;   // 1 if career code starts with user's primary letter (e.g. 'E'), else 0
    $contains_primary = 0;      // 1 if career code contains primary letter anywhere, else 0

    if ($is_exploration && !empty($riasec_3)) {
        if (!empty($career_riasec)) {
            $target_letters = str_split($riasec_3);
            $matched_count = 0;
            
            foreach ($target_letters as $letter) {
                if (!empty($letter) && strpos($career_riasec, $letter) !== false) {
                    $matched_count++;
                }
            }
            
            // Require at least 2 matched codes to qualify in Exploration mode
            if ($matched_count >= 2) {
                $filter_match = true;
                $match_score = $matched_count;
                
                if (!empty($primary_letter)) {
                    if (substr($career_riasec, 0, 1) === $primary_letter) {
                        $starts_with_primary = 1;
                    }
                    if (strpos($career_riasec, $primary_letter) !== false) {
                        $contains_primary = 1;
                    }
                }
            }
        }
    } else {
        // Standard Pathway Mode: Filter strictly by selected Pathway
        if (empty($lcp) || strcasecmp($lcp, 'Undecided') === 0 || strcasecmp($lcp, 'Exploration & Discovery') === 0) {
            $filter_match = true;
        } elseif (empty($career_lcp)) {
            $filter_match = true;
        } elseif (strcasecmp($career_lcp, $lcp) === 0 || stripos($career_lcp, $lcp) !== false || stripos($lcp, $career_lcp) !== false) {
            $filter_match = true;
        }

        // Calculate RIASEC scores if present for secondary matching
        if ($filter_match && !empty($riasec_3) && !empty($career_riasec)) {
            $target_letters = str_split($riasec_3);
            foreach ($target_letters as $letter) {
                if (!empty($letter) && strpos($career_riasec, $letter) !== false) {
                    $match_score++;
                }
            }
            if (!empty($primary_letter)) {
                if (substr($career_riasec, 0, 1) === $primary_letter) {
                    $starts_with_primary = 1;
                }
                if (strpos($career_riasec, $primary_letter) !== false) {
                    $contains_primary = 1;
                }
            }
        }
    }

    if ($filter_match) {
        $pathway_matched_careers[] = [
            'title' => $career_title,
            'lcp' => $career_lcp ?: ($lcp ?: 'General Pathway'),
            'riasec' => $career_riasec,
            'median_salary' => $career_salary,
            'growth_rate' => $career_growth,
            'type' => $career_type,
            'degree_required' => $career_degree_required,
            'description' => $career['description'] ?? 'Explore rewarding career opportunities in this field.',
            'match_score' => $match_score,
            'starts_with_primary' => $starts_with_primary,
            'contains_primary' => $contains_primary
        ];
    }
}

// Remove duplicates
$unique_careers = [];
$seen_titles = [];
foreach ($pathway_matched_careers as $c) {
    if (!in_array($c['title'], $seen_titles)) {
        $seen_titles[] = $c['title'];
        $unique_careers[] = $c;
    }
}
$pathway_matched_careers = $unique_careers;

// Comparator helper for RIASEC Exploration Mode sorting
$riasec_sort_comparator = function($a, $b) {
    // 1. Higher total matched letters first (3-matches before 2-matches)
    if ($a['match_score'] !== $b['match_score']) {
        return $b['match_score'] <=> $a['match_score'];
    }
    // 2. Starts with the 1st primary letter first (e.g. ECI before CEI for target EIS)
    if ($a['starts_with_primary'] !== $b['starts_with_primary']) {
        return $b['starts_with_primary'] <=> $a['starts_with_primary'];
    }
    // 3. Contains the 1st primary letter anywhere
    if ($a['contains_primary'] !== $b['contains_primary']) {
        return $b['contains_primary'] <=> $a['contains_primary'];
    }
    // 4. Fallback to alphabetical sorting
    return strcasecmp($a['title'], $b['title']);
};

// Weight rank helpers for numerical comparison
$growth_rank = function($growth) {
    $g = strtolower($growth);
    if (strpos($g, 'high') !== false) return 1;
    if (strpos($g, 'medium') !== false) return 2;
    if (strpos($g, 'low') !== false) return 3;
    return 4;
};

$salary_rank = function($salary) {
    $s = strtolower($salary);
    if (strpos($s, 'tier 1') !== false || strpos($s, 'high') !== false) return 1;
    if (strpos($s, 'tier 2') !== false || strpos($s, 'medium') !== false) return 2;
    if (strpos($s, 'tier 3') !== false || strpos($s, 'low') !== false) return 3;
    return 4;
};

$is_start_quickly = (stripos($top_priority, 'start quickly') !== false || stripos($top_priority, 'without much training') !== false || stripos($top_priority, 'quick') !== false);

// Standard Pathway mode comparator
$standard_pathway_comparator = function($a, $b) use ($top_priority, $is_start_quickly, $growth_rank, $salary_rank) {
    // 1. Sort by Growth Rate when user prioritizes Growth
    if (stripos($top_priority, 'growth') !== false) {
        $gA = $growth_rank($a['growth_rate']);
        $gB = $growth_rank($b['growth_rate']);
        if ($gA !== $gB) return $gA <=> $gB;
    }

    // 2. Sort by Salary Tier when user prioritizes Earning Potential
    if (stripos($top_priority, 'earning') !== false || stripos($top_priority, 'salary') !== false) {
        $sA = $salary_rank($a['median_salary']);
        $sB = $salary_rank($b['median_salary']);
        if ($sA !== $sB) return $sA <=> $sB;
    }

    // 3. Sort by Education Length when user wants Quick Entry
    if ($is_start_quickly) {
        $degree_weight = function($c) {
            $deg = strtolower($c['degree_required']);
            if (strpos($deg, 'certificate') !== false || strpos($deg, 'high school') !== false) return 1;
            if (strpos($deg, 'associate') !== false) return 2;
            if (strpos($deg, 'bachelor') !== false) return 3;
            if (strpos($deg, 'master') !== false || strpos($deg, 'doctoral') !== false || strpos($deg, 'graduate') !== false) return 4;
            return 5;
        };
        $wA = $degree_weight($a);
        $wB = $degree_weight($b);
        if ($wA !== $wB) return $wA <=> $wB;
    }

    // 4. Fallback to Alphabetical
    return strcasecmp($a['title'], $b['title']);
};

// Priority filtering & Top 10 capping
$matching_careers = [];

if ($show_all_lcp) {
    $matching_careers = $pathway_matched_careers;
    usort($matching_careers, function($a, $b) use ($is_riasec_driven, $riasec_sort_comparator, $standard_pathway_comparator) {
        if ($is_riasec_driven) {
            return $riasec_sort_comparator($a, $b);
        }
        return $standard_pathway_comparator($a, $b);
    });
} else {
    if ($is_riasec_driven) {
        usort($pathway_matched_careers, $riasec_sort_comparator);
    } else {
        usort($pathway_matched_careers, $standard_pathway_comparator);
    }
    $matching_careers = array_slice($pathway_matched_careers, 0, 10);
}

$total_matching_count = count($matching_careers);
$total_pathway_count = count($pathway_matched_careers);

$saved_selections = $_SESSION['applicant']['selected_careers'] ?? $_SESSION['selected_careers'] ?? [];
if (is_string($saved_selections)) {
    $decoded = json_decode($saved_selections, true);
    $saved_selections = is_array($decoded) ? $decoded : [$saved_selections];
} elseif (!is_array($saved_selections)) {
    $saved_selections = [];
}
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
            text-align: center;
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
        }
        .badge-salary { background: #d4edda; color: #155724; }
        .badge-growth { background: #d1ecf1; color: #0c5460; }
        .badge-degree { background: #fff3cd; color: #856404; }
        
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

        .expand-container {
            text-align: center;
            margin: 2rem 0;
        }

        .btn-expand {
            background-color: #ffffff;
            color: var(--cerritos-blue);
            border: 2px solid var(--cerritos-blue);
            padding: 0.85rem 1.75rem;
            font-size: 1rem;
            font-weight: bold;
            border-radius: 6px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.2s ease;
        }
        .btn-expand:hover {
            background-color: var(--cerritos-blue);
            color: #ffffff;
        }

        .button-group {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-top: 1px solid #eee;
            padding-top: 1.5rem;
            margin-top: 2rem;
        }
        .nav-buttons-left {
            display: flex;
            gap: 0.75rem;
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

    <?php if (!empty($json_error_msg)): ?>
        <div class="error-banner">
            <strong>JSON Error:</strong> Unable to load <code>degrees.json</code> properly. (Reason: <?php echo htmlspecialchars($json_error_msg); ?>)
        </div>
    <?php endif; ?>
    
    <div class="summary-box">
        <strong>Currently Displaying:</strong> <?php echo $total_matching_count; ?> career(s) <?php echo $show_all_lcp ? '(All Pathway Results Expanded)' : '(Top Priority Filtered)'; ?><br>
        <strong>User Target Pathway / Filter:</strong> <?php echo htmlspecialchars($is_exploration ? "Exploration & Discovery (RIASEC: " . ($riasec_3 ?: 'None') . ")" : ($lcp ?: 'All Pathways')); ?><br>
        <strong>Full Target RIASEC Extracted:</strong> <?php echo htmlspecialchars($full_riasec_code ?: 'None'); ?><br>
        <?php if (!empty($top_priority)): ?>
            <strong>Top Priority Filter:</strong> 
            <?php echo $show_all_lcp ? htmlspecialchars($top_priority) . ' <em>(Expanded to All Careers)</em>' : htmlspecialchars($top_priority); ?>
        <?php else: ?>
            <strong>Top Priority Filter:</strong> None set
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
        <?php echo csrf_field(); ?>

        <div style="margin-bottom: 1rem; display: flex; justify-content: space-between; align-items: center;">
            <div>Selected: <span id="selectedCount" class="counter-display">0</span> of up to 3 allowed</div>
        </div>

        <?php if (empty($matching_careers)): ?>
            <div class="error-banner">
                No matching careers found matching your criteria.
            </div>
        <?php else: ?>
            <?php foreach ($matching_careers as $index => $career): ?>
                <?php $is_checked = in_array($career['title'], $saved_selections, true); ?>
                <div class="career-card"
                     data-name="<?php echo htmlspecialchars($career['title']); ?>"
                     data-description="<?php echo htmlspecialchars(!empty($career['description']) ? $career['description'] : 'Explore rewarding career opportunities in this field.'); ?>"
                     onmousemove="moveTooltip(event, this)"
                     onmouseenter="showTooltip(event, this)"
                     onmouseleave="hideTooltip()"
                     onclick="toggleCardCheckbox(this, event)">
                    
                    <input type="checkbox" 
                           name="selected_careers[]" 
                           value="<?php echo htmlspecialchars($career['title']); ?>" 
                           id="career_<?php echo $index; ?>" 
                           class="career-checkbox" 
                           <?php echo $is_checked ? 'checked' : ''; ?>
                           onclick="event.stopPropagation();">
                    
                    <div class="career-info" style="flex-grow: 1;">
                        <label for="career_<?php echo $index; ?>" style="cursor: pointer;" onclick="event.stopPropagation();">
                            <h3><?php echo htmlspecialchars($career['title']); ?></h3>
                        </label>
                        <div class="career-meta">
                            <span class="badge">Pathway: <?php echo htmlspecialchars($career['lcp']); ?></span>
                            <?php if (!empty($career['riasec'])): ?>
                                <span class="badge" style="background: #e2d9f3; color: #432874;">RIASEC: <?php echo htmlspecialchars($career['riasec']); ?></span>
                            <?php endif; ?>
                            <?php if (!empty($career['degree_required'])): ?>
                                <span class="badge badge-degree">Degree Required: <?php echo htmlspecialchars($career['degree_required']); ?></span>
                            <?php endif; ?>
                            <?php if (!empty($career['median_salary'])): ?>
                                <?php 
                                    $salary_raw = trim($career['median_salary']);
                                    $salary_label = $salary_raw;
                                    
                                    if (strcasecmp($salary_raw, 'Tier 1') === 0) {
                                        $salary_label = 'Tier 1: Lucrative / High-Yield';
                                    } elseif (strcasecmp($salary_raw, 'Tier 2') === 0) {
                                        $salary_label = 'Tier 2: Livable Wage / Stable';
                                    } elseif (strcasecmp($salary_raw, 'Tier 3') === 0) {
                                        $salary_label = 'Tier 3: Entry-Wage / Baseline';
                                    }
                                ?>
                                <span class="badge badge-salary">Salary: <?php echo htmlspecialchars($salary_label); ?></span>
                            <?php endif; ?>
                            <?php if (!empty($career['growth_rate'])): ?>
                                <span class="badge badge-growth">Growth: <?php echo htmlspecialchars($career['growth_rate']); ?></span>
                            <?php endif; ?>
                        </div>
                        <p style="margin: 0; font-size: 0.95rem; color: #444;"><?php echo htmlspecialchars($career['description']); ?></p>
                    </div>
                </div>
            <?php endforeach; ?>
        <?php endif; ?>

        <!-- Floating Overlay Tooltip Element -->
        <div id="description-tooltip">
            <h3 id="tooltip-title">Career Description</h3>
            <p id="tooltip-text"></p>
        </div>

        <!-- Expand / Filter Options at the Bottom -->
        <?php if (!$show_all_lcp): ?>
            <div class="expand-container">
                <a href="career_selection.php?show_all=1" class="btn-expand">
                    Expand Results: Include All Careers in Pathway &rarr;
                </a>
            </div>
        <?php else: ?>
            <div class="notice-banner" style="background-color: #d1ecf1; color: #0c5460; border-color: #bee5eb;">
                You are currently viewing all <?php echo $total_pathway_count; ?> careers in this pathway. 
                <a href="career_selection.php" style="color: #002b49;">Click here to restore top priority filters</a>.
            </div>
        <?php endif; ?>

        <div class="button-group">
            <div class="nav-buttons-left">
                <a href="lcp.php" class="btn btn-secondary">&larr; Back to Pathways</a>
                <a href="goals.php" class="btn btn-secondary">&larr; Back to Goals</a>
            </div>
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
                    alert('You can select a maximum of 3 careers.');
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