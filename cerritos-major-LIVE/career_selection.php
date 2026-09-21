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

// Comparator helper for RIASEC Exploration Mode sorting with Top Priority tie-breaking
$riasec_sort_comparator = function($a, $b) use ($top_priority, $is_start_quickly, $growth_rank, $salary_rank) {
    if ($a['match_score'] !== $b['match_score']) {
        return $b['match_score'] <=> $a['match_score'];
    }

    if (stripos($top_priority, 'earning') !== false || stripos($top_priority, 'salary') !== false) {
        $sA = $salary_rank($a['median_salary']);
        $sB = $salary_rank($b['median_salary']);
        if ($sA !== $sB) return $sA <=> $sB;
    }

    if (stripos($top_priority, 'growth') !== false) {
        $gA = $growth_rank($a['growth_rate']);
        $gB = $growth_rank($b['growth_rate']);
        if ($gA !== $gB) return $gA <=> $gB;
    }

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

    if ($a['starts_with_primary'] !== $b['starts_with_primary']) {
        return $b['starts_with_primary'] <=> $a['starts_with_primary'];
    }

    if ($a['contains_primary'] !== $b['contains_primary']) {
        return $b['contains_primary'] <=> $a['contains_primary'];
    }

    return strcasecmp($a['title'], $b['title']);
};

// Standard Pathway mode comparator
$standard_pathway_comparator = function($a, $b) use ($top_priority, $is_start_quickly, $growth_rank, $salary_rank) {
    if (stripos($top_priority, 'growth') !== false) {
        $gA = $growth_rank($a['growth_rate']);
        $gB = $growth_rank($b['growth_rate']);
        if ($gA !== $gB) return $gA <=> $gB;
    }

    if (stripos($top_priority, 'earning') !== false || stripos($top_priority, 'salary') !== false) {
        $sA = $salary_rank($a['median_salary']);
        $sB = $salary_rank($b['median_salary']);
        if ($sA !== $sB) return $sA <=> $sB;
    }

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
            /* WCAG 2.1 AAA Compliant High-Contrast Colors */
            --cerritos-blue: #002b49;
            --cerritos-gold: #8a6200;
            --cerritos-dark: #0f172a;
            --cerritos-light: #f8fafc;
            --text-muted: #334155;
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
            line-height: 1.5;
        }

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
            border-bottom: 5px solid var(--cerritos-gold);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        header h1 {
            font-size: 1.35rem;
            margin: 0;
            font-weight: 700;
        }

        .step-indicator {
            font-size: 0.85rem;
            background: rgba(255,255,255,0.2);
            padding: 0.4rem 0.8rem;
            border-radius: 12px;
            font-weight: 700;
            color: #ffffff;
        }

        .container {
            max-width: 1100px;
            margin: 2rem auto;
            background: #ffffff;
            padding: 2rem;
            border-radius: 8px;
            border: 2px solid var(--card-border);
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        }

        h2 {
            color: var(--cerritos-blue);
            border-bottom: 3px solid var(--cerritos-gold);
            padding-bottom: 0.5rem;
            margin-top: 0;
            font-size: 1.5rem;
        }

        .intro-text {
            margin-bottom: 1.5rem;
            color: var(--text-muted);
            font-size: 1rem;
        }

        .summary-box {
            background-color: #f0f6ff;
            border-left: 6px solid var(--cerritos-blue);
            border-top: 1px solid #cbd5e1;
            border-right: 1px solid #cbd5e1;
            border-bottom: 1px solid #cbd5e1;
            padding: 1rem 1.25rem;
            margin-bottom: 1.5rem;
            border-radius: 0 6px 6px 0;
            color: var(--cerritos-dark);
        }

        .notice-banner {
            background-color: #fff9e6;
            color: #422d00;
            padding: 1rem;
            border: 2px solid var(--cerritos-gold);
            border-radius: 6px;
            margin-top: 1.5rem;
            margin-bottom: 1.5rem;
            text-align: center;
            font-weight: 600;
        }

        .notice-banner a {
            color: var(--cerritos-blue);
            font-weight: 800;
            text-decoration: underline;
        }

        .error-banner {
            background: #fef2f2;
            color: #991b1b;
            padding: 1rem;
            border: 2px solid #991b1b;
            border-radius: 6px;
            margin-bottom: 1.5rem;
            font-weight: 700;
        }

        fieldset.career-fieldset {
            border: none;
            padding: 0;
            margin: 0;
        }

        legend.career-legend {
            font-size: 1.1rem;
            font-weight: 800;
            color: var(--cerritos-blue);
            margin-bottom: 0.75rem;
        }

        .career-card {
            background: #ffffff;
            border: 2px solid var(--card-border);
            border-radius: 8px;
            padding: 1.25rem;
            margin-bottom: 1rem;
            display: flex;
            align-items: flex-start;
            gap: 1.25rem;
            transition: background-color 0.2s, border-color 0.2s;
            cursor: pointer;
            position: relative;
        }

        .career-card:hover {
            border-color: var(--cerritos-blue);
            background-color: #f0f7ff;
        }

        .career-card.selected-card {
            border: 3px solid var(--cerritos-blue);
            background-color: #f0f7ff;
        }

        .checkbox-container {
            display: flex;
            align-items: center;
            padding-top: 0.2rem;
        }

        .career-card input[type="checkbox"] {
            width: 1.35rem;
            height: 1.35rem;
            cursor: pointer;
            accent-color: var(--cerritos-blue);
        }

        .career-info h3 {
            margin: 0 0 0.4rem 0;
            color: var(--cerritos-blue);
            font-size: 1.2rem;
        }

        .career-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            margin-bottom: 0.75rem;
        }

        /* High Contrast Badges */
        .badge {
            display: inline-block;
            background: #e2e8f0;
            color: #0f172a;
            padding: 0.25rem 0.6rem;
            border-radius: 4px;
            font-size: 0.8rem;
            font-weight: 800;
            border: 1px solid #64748b;
        }

        .badge-riasec { background: #f3e8ff; color: #581c87; border-color: #a855f7; }
        .badge-salary { background: #dcfce7; color: #14532d; border-color: #22c55e; }
        .badge-growth { background: #e0f2fe; color: #0c4a6e; border-color: #0284c7; }
        .badge-degree { background: #fff3d1; color: #5c4100; border-color: var(--cerritos-gold); }

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
            font-weight: 800;
            border-radius: 6px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.2s ease;
        }

        .btn-expand:hover,
        .btn-expand:focus {
            background-color: var(--cerritos-blue);
            color: #ffffff;
        }

        .button-group {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-top: 2px solid #cbd5e1;
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
            border: 2px solid var(--cerritos-blue);
            padding: 0.75rem 1.5rem;
            font-size: 1rem;
            font-weight: 800;
            border-radius: 6px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: background-color 0.2s ease;
        }

        .btn:hover {
            background-color: #001d32;
            border-color: #001d32;
        }

        .btn-secondary {
            background-color: #f1f5f9;
            color: var(--cerritos-blue);
            border: 2px solid var(--cerritos-blue);
        }

        .btn-secondary:hover {
            background-color: var(--cerritos-blue);
            color: #ffffff;
        }

        .btn:focus,
        .btn-expand:focus,
        input[type="checkbox"]:focus,
        a:focus {
            outline: 3px solid var(--focus-outline) !important;
            outline-offset: 3px !important;
        }

        .counter-display {
            font-weight: 800;
            color: var(--cerritos-blue);
            font-size: 1.1rem;
        }

        /* Modal Popup Styling */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(15, 23, 42, 0.75);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 10000;
            opacity: 0;
            pointer-events: none;
            transition: opacity 0.2s ease;
        }

        .modal-overlay.active {
            opacity: 1;
            pointer-events: auto;
        }

        .modal-box {
            background: #ffffff;
            width: 90%;
            max-width: 500px;
            border-radius: 8px;
            padding: 1.75rem;
            box-shadow: 0 12px 32px rgba(0,0,0,0.25);
            border: 3px solid var(--cerritos-blue);
            border-top: 8px solid var(--cerritos-gold);
        }

        .modal-box h3 {
            margin-top: 0;
            color: var(--cerritos-blue);
            font-size: 1.3rem;
        }

        .modal-options {
            margin: 1.25rem 0;
            display: flex;
            flex-direction: column;
            gap: 0.65rem;
        }

        .modal-option-btn {
            background: #f8fafc;
            border: 2px solid #64748b;
            padding: 0.85rem;
            border-radius: 6px;
            text-align: left;
            font-weight: 800;
            color: var(--cerritos-blue);
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .modal-option-btn:hover,
        .modal-option-btn:focus {
            background: var(--cerritos-blue);
            color: #ffffff;
            border-color: var(--cerritos-blue);
        }

        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 0.5rem;
        }
    </style>
</head>
<body>

<header role="banner">
    <h1>Cerritos College Career Exploration</h1>
    <span class="step-indicator">Career Selection</span>
</header>

<main class="container" id="main-content">
    <h2>Matched Careers</h2>

    <?php if (!empty($json_error_msg)): ?>
        <div class="error-banner" role="alert">
            <strong>JSON Error:</strong> Unable to load <code>degrees.json</code> properly. (Reason: <?php echo htmlspecialchars($json_error_msg); ?>)
        </div>
    <?php endif; ?>
    
    <section class="summary-box" aria-label="Filter Summary">
        <strong>Currently Displaying:</strong> <?php echo $total_matching_count; ?> career(s) <?php echo $show_all_lcp ? '(All Pathway Results Expanded)' : '(Top Priority Filtered)'; ?><br>
        <strong>User Target Pathway / Filter:</strong> <?php echo htmlspecialchars($is_exploration ? "Exploration & Discovery (RIASEC: " . ($riasec_3 ?: 'None') . ")" : ($lcp ?: 'All Pathways')); ?><br>
        <strong>Full Target RIASEC Extracted:</strong> <?php echo htmlspecialchars($full_riasec_code ?: 'None'); ?><br>
        <?php if (!empty($top_priority)): ?>
            <strong>Top Priority Filter:</strong> 
            <?php echo $show_all_lcp ? htmlspecialchars($top_priority) . ' <em>(Expanded to All Careers)</em>' : htmlspecialchars($top_priority); ?>
        <?php else: ?>
            <strong>Top Priority Filter:</strong> None set
        <?php endif; ?>
    </section>

    <p class="intro-text">
        Please select up to <strong>3 careers</strong> below to proceed to major recommendations (you can proceed with fewer).
    </p>

    <?php if (isset($error_message)): ?>
        <div class="error-banner" role="alert">
            <?php echo htmlspecialchars($error_message); ?>
        </div>
    <?php endif; ?>

    <form method="POST" action="career_selection.php<?php echo $show_all_lcp ? '?show_all=1' : ''; ?>" id="careerForm">
        <input type="hidden" name="action" value="save_careers">
        <?php echo csrf_field(); ?>

        <div style="margin-bottom: 1.25rem; display: flex; justify-content: space-between; align-items: center;" aria-live="polite" id="counterRegion">
            <div>Selected: <span id="selectedCount" class="counter-display">0</span> of up to 3 allowed</div>
        </div>

        <?php if (empty($matching_careers)): ?>
            <div class="error-banner" role="alert">
                No matching careers found matching your criteria.
            </div>
        <?php else: ?>
            <fieldset class="career-fieldset">
                <legend class="career-legend">Available Career Matches</legend>
                
                <?php foreach ($matching_careers as $index => $career): ?>
                    <?php 
                        $is_checked = in_array($career['title'], $saved_selections, true);
                        $input_id = "career_" . $index;
                    ?>
                    <article class="career-card <?php echo $is_checked ? 'selected-card' : ''; ?>" 
                             onclick="toggleCardCheckbox(this, event)">
                        
                        <div class="checkbox-container">
                            <input type="checkbox" 
                                   name="selected_careers[]" 
                                   value="<?php echo htmlspecialchars($career['title']); ?>" 
                                   id="<?php echo $input_id; ?>" 
                                   class="career-checkbox" 
                                   <?php echo $is_checked ? 'checked' : ''; ?>
                                   aria-describedby="desc_<?php echo $index; ?>"
                                   onclick="event.stopPropagation();">
                        </div>
                        
                        <div class="career-info" style="flex-grow: 1;">
                            <label for="<?php echo $input_id; ?>" style="cursor: pointer;" onclick="event.stopPropagation();">
                                <h3><?php echo htmlspecialchars($career['title']); ?></h3>
                            </label>
                            
                            <div class="career-meta">
                                <span class="badge">Pathway: <?php echo htmlspecialchars($career['lcp']); ?></span>
                                <?php if (!empty($career['riasec'])): ?>
                                    <span class="badge badge-riasec">RIASEC: <?php echo htmlspecialchars($career['riasec']); ?></span>
                                <?php endif; ?>
                                <?php if (!empty($career['degree_required'])): ?>
                                    <span class="badge badge-degree">Degree: <?php echo htmlspecialchars($career['degree_required']); ?></span>
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
                            
                            <p id="desc_<?php echo $index; ?>" style="margin: 0; font-size: 0.95rem; color: var(--text-muted);">
                                <?php echo htmlspecialchars($career['description']); ?>
                            </p>
                        </div>
                    </article>
                <?php endforeach; ?>
            </fieldset>
        <?php endif; ?>

        <!-- Expand / Filter Options -->
        <?php if (!$show_all_lcp): ?>
            <div class="expand-container">
                <a href="career_selection.php?show_all=1" class="btn-expand">
                    Expand Results: Include All Careers in Pathway <span aria-hidden="true">&rarr;</span>
                </a>
            </div>
        <?php else: ?>
            <div class="notice-banner">
                You are currently viewing all <?php echo $total_pathway_count; ?> careers in this pathway. 
                <a href="career_selection.php">Click here to restore top priority filters</a>.
            </div>
        <?php endif; ?>

        <nav class="button-group" aria-label="Form Navigation">
            <div class="nav-buttons-left">
                <a href="lcp.php" class="btn btn-secondary"><span aria-hidden="true">&larr;</span> Back to Pathways</a>
                <a href="goals.php" class="btn btn-secondary"><span aria-hidden="true">&larr;</span> Back to Goals</a>
            </div>
            <button type="submit" class="btn" id="submitBtn">Proceed to Majors <span aria-hidden="true">&rarr;</span></button>
        </nav>
    </form>
</main>

<!-- Accessible Modal Dialog for Selection Limit -->
<div class="modal-overlay" id="swapModal" role="dialog" aria-modal="true" aria-labelledby="modalTitle" aria-describedby="modalDesc">
    <div class="modal-box">
        <h3 id="modalTitle">Selection Limit Reached</h3>
        <p id="modalDesc">You can only select up to 3 careers. Which career would you like to remove to add <strong id="newCareerName"></strong>?</p>
        <div class="modal-options" id="modalOptions"></div>
        <div class="modal-footer">
            <button type="button" class="btn btn-secondary" onclick="closeSwapModal()">Cancel</button>
        </div>
    </div>
</div>

<script>
    let pendingCheckbox = null;

    document.addEventListener('DOMContentLoaded', function() {
        const checkboxes = document.querySelectorAll('.career-checkbox');

        checkboxes.forEach(cb => {
            cb.addEventListener('change', function() {
                const checkedBoxes = Array.from(document.querySelectorAll('.career-checkbox:checked'));
                const card = this.closest('.career-card');
                
                if (this.checked && card) {
                    card.classList.add('selected-card');
                } else if (card) {
                    card.classList.remove('selected-card');
                }

                if (checkedBoxes.length > 3) {
                    // Revert check
                    this.checked = false;
                    if (card) card.classList.remove('selected-card');
                    pendingCheckbox = this;
                    
                    // Show modal
                    openSwapModal(checkedBoxes.filter(c => c !== this), this);
                } else {
                    updateSelectionCount();
                }
            });
        });

        // Close Modal on Escape Key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                const modal = document.getElementById('swapModal');
                if (modal.classList.contains('active')) {
                    closeSwapModal();
                }
            }
        });

        updateSelectionCount();
    });

    function updateSelectionCount() {
        const checkedCount = document.querySelectorAll('.career-checkbox:checked').length;
        const counterDisplay = document.getElementById('selectedCount');
        const submitBtn = document.getElementById('submitBtn');

        if (counterDisplay) counterDisplay.textContent = checkedCount;
        
        if (submitBtn) {
            if (checkedCount >= 1 && checkedCount <= 3) {
                submitBtn.style.opacity = '1';
                submitBtn.removeAttribute('disabled');
            } else if (checkedCount === 0) {
                submitBtn.style.opacity = '0.75';
            }
        }
    }

    function openSwapModal(existingSelections, newCheckbox) {
        const modal = document.getElementById('swapModal');
        const modalOptions = document.getElementById('modalOptions');
        const newCareerName = document.getElementById('newCareerName');
        
        newCareerName.textContent = newCheckbox.value;
        modalOptions.innerHTML = '';

        existingSelections.forEach(cb => {
            const btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'modal-option-btn';
            btn.textContent = 'Remove: ' + cb.value;
            btn.onclick = function() {
                cb.checked = false;
                const oldCard = cb.closest('.career-card');
                if (oldCard) oldCard.classList.remove('selected-card');

                newCheckbox.checked = true;
                const newCard = newCheckbox.closest('.career-card');
                if (newCard) newCard.classList.add('selected-card');

                closeSwapModal();
                updateSelectionCount();
            };
            modalOptions.appendChild(btn);
        });

        modal.classList.add('active');
        const firstBtn = modalOptions.querySelector('button');
        if (firstBtn) firstBtn.focus();
    }

    function closeSwapModal() {
        const modal = document.getElementById('swapModal');
        modal.classList.remove('active');
        if (pendingCheckbox) {
            pendingCheckbox.focus();
        }
        pendingCheckbox = null;
        updateSelectionCount();
    }

    function toggleCardCheckbox(cardElement, event) {
        const checkbox = cardElement.querySelector('input[type="checkbox"]');
        if (checkbox && event.target !== checkbox && event.target.tagName !== 'LABEL') {
            checkbox.checked = !checkbox.checked;
            checkbox.dispatchEvent(new Event('change'));
        }
    }
</script>

</body>
</html>