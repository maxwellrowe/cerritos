<?php
// Prevent browser caching
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Pragma: no-cache");

require_once __DIR__ . '/app_bootstrap.php';

// Check if applicant session exists
if (!isset($_SESSION['applicant'])) {
    header('Location: career_selection.php');
    exit;
}

$applicant = $_SESSION['applicant'];
$email = $applicant['email'] ?? '';

// Retrieve user's intended education goal type from session
$user_goal_type = '';
if (isset($_SESSION['applicant_education']['goal_type'])) {
    $user_goal_type = $_SESSION['applicant_education']['goal_type'];
} elseif (isset($applicant['education_goal']['goal_type'])) {
    $user_goal_type = $applicant['education_goal']['goal_type'];
}

// Safely retrieve and normalize $selected_careers into a list of title strings
$selected_careers = [];
if (isset($_SESSION['selected_careers'])) {
    $raw_selected = $_SESSION['selected_careers'];
} else {
    $raw_selected = $applicant['selected_careers'] ?? [];
}

if (is_string($raw_selected)) {
    $decoded = json_decode($raw_selected, true);
    $selected_careers = is_array($decoded) ? $decoded : (!empty($raw_selected) ? [$raw_selected] : []);
} elseif (is_array($raw_selected)) {
    $selected_careers = $raw_selected;
}

// Redirect back if no careers are selected
if (empty($selected_careers)) {
    header('Location: career_selection.php');
    exit;
}

// Extract clean string titles from $selected_careers
$selected_career_titles = [];
foreach ($selected_careers as $sc) {
    if (is_array($sc) && !empty($sc['title'])) {
        $selected_career_titles[] = trim($sc['title']);
    } elseif (is_string($sc) && !empty($sc)) {
        $selected_career_titles[] = trim($sc);
    }
}

// Helper function to normalize strings for robust comparison
function normalize_title($str) {
    $str = html_entity_decode($str, ENT_QUOTES | ENT_HTML5, 'UTF-8');
    $str = preg_replace('/\s+/', ' ', $str);
    return mb_strtolower(trim($str));
}

// Helper to append program completion duration to credential category display
function format_category_with_duration($category_raw) {
    $cat = strtolower(trim((string)$category_raw));
    if (empty($cat)) return '';

    if (strpos($cat, 'certificate') !== false) {
        return htmlspecialchars($category_raw) . ' (1 year)';
    } elseif (strpos($cat, 'associate') !== false) {
        return htmlspecialchars($category_raw) . ' (2 years)';
    } elseif (strpos($cat, 'bachelor') !== false) {
        return htmlspecialchars($category_raw) . ' (4 years)';
    }

    return htmlspecialchars($category_raw);
}

$normalized_selected_titles = array_map('normalize_title', $selected_career_titles);

// 1. Fetch degree & program listings from degrees.json
$degrees_data = [];
if (file_exists('degrees.json')) {
    $degrees_json_content = file_get_contents('degrees.json');
    $decoded_json = json_decode($degrees_json_content, true) ?: [];
    
    if (isset($decoded_json['degrees']) && is_array($decoded_json['degrees'])) {
        $degrees_data = $decoded_json['degrees'];
    } elseif (is_array($decoded_json)) {
        $degrees_data = $decoded_json;
    }
}

// Handle major selection form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'save_major') {
    require_valid_csrf();
    $selected_major_key = $_POST['selected_major'] ?? '';
    
    if (!empty($selected_major_key)) {
        $parts = explode('|', $selected_major_key);
        $selected_major = $parts[0] ?? '';
        $selected_credential_type = $parts[1] ?? '';
        
        $_SESSION['selected_major'] = $selected_major;
        $_SESSION['selected_credential_type'] = $selected_credential_type;
        
        $currentTime = date('Y-m-d H:i:s');
        $_SESSION['applicant']['selected_major'] = $selected_major;
        $_SESSION['applicant']['selected_credential_type'] = $selected_credential_type;
        $_SESSION['applicant']['last_updated'] = $currentTime;
        
        header('Location: summary.php');
        exit;
    } else {
        $error_message = "Please select a major/program before continuing.";
    }
}

// 2. Scan programs and match against selected careers with normalized titles
$matched_programs = [];
$all_consolidated_programs = [];

foreach ($degrees_data as $data) {
    if (!isset($data['program_name'])) continue;

    $prog_name = trim($data['program_name']);
    $cred_type = trim($data['credential_type'] ?? 'AA-T');
    $cred_cat = trim($data['credential_category'] ?? 'Associate Degree');
    $prog_desc = trim($data['description'] ?? '');

    $rcms = $data['related_career_matches'] ?? [];
    if (is_string($rcms)) {
        $rcms = json_decode($rcms, true) ?: [];
    }

    $unique_key = $prog_name . '|' . $cred_type;
    $is_adt = (preg_match('/(AA-T|AS-T|A\.A\.-T|A\.S\.-T)/i', $cred_type) || preg_match('/(AA-T|AS-T|Transfer)/i', $prog_name));

    if (!isset($all_consolidated_programs[$unique_key])) {
        $all_consolidated_programs[$unique_key] = [
            'program_name' => $prog_name,
            'credential_type' => $cred_type,
            'credential_category' => $cred_cat,
            'description' => $prog_desc,
            'is_transfer' => $is_adt,
            'details' => []
        ];
    }

    if (is_array($rcms)) {
        foreach ($rcms as $rcm) {
            $rcm_title = is_array($rcm) ? trim($rcm['title'] ?? '') : trim($rcm);
            $degree_req = is_array($rcm) ? trim($rcm['degree_required'] ?? '') : '';
            $match_type = is_array($rcm) ? trim($rcm['match_type'] ?? '') : '';
            $degree_type = is_array($rcm) ? trim($rcm['degree_type'] ?? '') : '';

            $norm_rcm = normalize_title($rcm_title);

            $all_consolidated_programs[$unique_key]['details'][] = [
                'career_title' => $rcm_title,
                'degree_required' => $degree_req,
                'match_type' => $match_type,
                'degree_type' => $degree_type
            ];

            if (!empty($norm_rcm) && in_array($norm_rcm, $normalized_selected_titles, true)) {
                $matched_programs[] = [
                    'career_title' => $rcm_title,
                    'program_name' => $prog_name,
                    'credential_type' => $cred_type,
                    'credential_category' => $cred_cat,
                    'description' => $prog_desc,
                    'degree_required' => $degree_req,
                    'match_type' => $match_type,
                    'degree_type' => $degree_type
                ];
            }
        }
    }
}

// Consolidate programs matched to selected careers with full attribute deduplication
$consolidated_programs = [];
foreach ($matched_programs as $p) {
    $p_name = $p['program_name'];
    $c_type = $p['credential_type'];
    $unique_key = $p_name . '|' . $c_type;
    $is_adt = (preg_match('/(AA-T|AS-T|A\.A\.-T|A\.S\.-T)/i', $c_type) || preg_match('/(AA-T|AS-T|Transfer)/i', $p_name));

    if (!isset($consolidated_programs[$unique_key])) {
        $consolidated_programs[$unique_key] = [
            'program_name' => $p_name,
            'credential_type' => $c_type,
            'credential_category' => $p['credential_category'],
            'description' => $p['description'],
            'is_transfer' => $is_adt,
            'details' => []
        ];
    }
    
    $exists = false;
    foreach ($consolidated_programs[$unique_key]['details'] as $det) {
        if (
            normalize_title($det['career_title']) === normalize_title($p['career_title']) &&
            $det['match_type'] === $p['match_type'] &&
            $det['degree_type'] === $p['degree_type'] &&
            $det['degree_required'] === $p['degree_required']
        ) {
            $exists = true;
            break;
        }
    }
    
    if (!$exists) {
        $consolidated_programs[$unique_key]['details'][] = [
            'career_title' => $p['career_title'],
            'degree_required' => $p['degree_required'],
            'match_type' => $p['match_type'],
            'degree_type' => $p['degree_type']
        ];
    }
}

// Sort career details
foreach ($consolidated_programs as &$prog) {
    usort($prog['details'], function($a, $b) {
        $a_is_direct = (strtolower($a['match_type']) === 'direct') ? 0 : 1;
        $b_is_direct = (strtolower($b['match_type']) === 'direct') ? 0 : 1;
        
        if ($a_is_direct !== $b_is_direct) {
            return $a_is_direct <=> $b_is_direct;
        }
        return strcasecmp($a['career_title'], $b['career_title']);
    });
}
unset($prog);

// Sort programs by priority
uasort($consolidated_programs, function($a, $b) use ($user_goal_type) {
    if ($a['is_transfer'] !== $b['is_transfer']) {
        return $b['is_transfer'] <=> $a['is_transfer']; 
    }

    $matches_goal_a = false;
    $matches_goal_b = false;

    if (!empty($user_goal_type)) {
        if (stripos($user_goal_type, 'Certificate') !== false) {
            $matches_goal_a = (stripos($a['credential_category'], 'Certificate') !== false || stripos($a['credential_type'], 'Cert') !== false);
            $matches_goal_b = (stripos($b['credential_category'], 'Certificate') !== false || stripos($b['credential_type'], 'Cert') !== false);
        } elseif (stripos($user_goal_type, 'Associate') !== false) {
            $matches_goal_a = (stripos($a['credential_category'], 'Associate') !== false && !$a['is_transfer']);
            $matches_goal_b = (stripos($b['credential_category'], 'Associate') !== false && !$b['is_transfer']);
        } elseif (stripos($user_goal_type, 'Bachelor') !== false) {
            $matches_goal_a = $a['is_transfer'];
            $matches_goal_b = $b['is_transfer'];
        } elseif (stripos($user_goal_type, 'Graduate') !== false) {
            $matches_goal_a = (stripos($a['credential_category'], 'Graduate') !== false || stripos($a['credential_type'], 'Graduate') !== false);
            $matches_goal_b = (stripos($b['credential_category'], 'Graduate') !== false || stripos($b['credential_type'], 'Graduate') !== false);
        }
    }

    if ($matches_goal_a !== $matches_goal_b) {
        return $matches_goal_b <=> $matches_goal_a;
    }

    return strcasecmp($a['program_name'], $b['program_name']);
});

$saved_major = $_SESSION['applicant']['selected_major'] ?? $_SESSION['selected_major'] ?? '';
$saved_credential_type = $_SESSION['applicant']['selected_credential_type'] ?? $_SESSION['selected_credential_type'] ?? '';
$saved_major_key = (!empty($saved_major) && !empty($saved_credential_type)) ? ($saved_major . '|' . $saved_credential_type) : '';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cerritos College - Major Selection</title>
    <style>
        :root {
            --cerritos-blue: #002b49;
            --cerritos-gold: #735000;
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

        .summary-box ul {
            margin: 0.5rem 0 0 1.25rem;
            padding: 0;
        }

        .search-container {
            margin-bottom: 1.5rem;
        }

        .search-label {
            display: block;
            font-weight: 800;
            margin-bottom: 0.5rem;
            color: var(--cerritos-blue);
            font-size: 1.05rem;
        }

        .search-input {
            width: 100%;
            padding: 0.85rem 1rem;
            font-size: 1rem;
            border: 2px solid var(--card-border);
            border-radius: 6px;
            box-sizing: border-box;
            color: var(--cerritos-dark);
            background-color: #ffffff;
        }

        .search-input:focus {
            outline: 3px solid var(--focus-outline) !important;
            outline-offset: 2px;
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

        fieldset.program-fieldset {
            border: none;
            padding: 0;
            margin: 0;
        }

        legend.program-legend {
            font-size: 1.1rem;
            font-weight: 800;
            color: var(--cerritos-blue);
            margin-bottom: 0.75rem;
        }

        .program-card {
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

        .program-card:hover {
            border-color: var(--cerritos-blue);
            background-color: #f0f7ff;
        }

        .program-card.selected-card {
            border: 3px solid var(--cerritos-blue);
            background-color: #f0f7ff;
        }

        .radio-container {
            display: flex;
            align-items: center;
            padding-top: 0.2rem;
        }

        .program-card input[type="radio"] {
            width: 1.35rem;
            height: 1.35rem;
            cursor: pointer;
            accent-color: var(--cerritos-blue);
        }

        .program-card input[type="radio"]:focus {
            outline: 3px solid var(--focus-outline) !important;
            outline-offset: 3px;
        }

        .program-info h3 {
            margin: 0 0 0.4rem 0;
            color: var(--cerritos-blue);
            font-size: 1.2rem;
        }

        .degree-label {
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--text-muted);
            font-weight: 800;
            margin-bottom: 0.25rem;
        }

        .program-meta {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
            margin-top: 0.5rem;
            margin-bottom: 0.75rem;
        }

        .meta-header-row {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            align-items: center;
        }

        .career-detail-row {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            align-items: center;
            padding-top: 0.35rem;
            border-top: 1px dashed #cbd5e1;
        }

        .badge {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            background: #f1f5f9;
            color: #0f172a;
            padding: 0.3rem 0.65rem;
            border-radius: 4px;
            font-size: 0.8rem;
            font-weight: 800;
            border: 1px solid #475569;
        }

        .badge svg {
            width: 14px;
            height: 14px;
            fill: currentColor;
            flex-shrink: 0;
        }

        .badge-transfer { background: #002b49; color: #ffffff; border-color: #001d32; }
        .badge-cat { background: #e0f2fe; color: #0c4a6e; border-color: #0284c7; }
        .badge-deg-type { background: #f3e8ff; color: #581c87; border-color: #a855f7; }
        .badge-match { background: #e0f2fe; color: #0369a1; border-color: #0284c7; }

        .program-description {
            margin: 0.5rem 0 0 0;
            font-size: 0.95rem;
            color: var(--text-muted);
            background: #f8fafc;
            padding: 0.75rem;
            border-radius: 6px;
            border: 1px solid #cbd5e1;
        }

        .button-group {
            display: flex;
            justify-content: flex-start;
            align-items: center;
            border-top: 2px solid #cbd5e1;
            padding-top: 1.5rem;
            margin-top: 2rem;
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
        .search-input:focus,
        a:focus {
            outline: 3px solid var(--focus-outline) !important;
            outline-offset: 3px !important;
        }
    </style>
</head>
<body>

<header role="banner">
    <h1>Cerritos College Career Exploration</h1>
    <span class="step-indicator">Major Selection</span>
</header>

<main class="container" id="main-content">
    <h2>Select Your Program / Major</h2>
    
    <section class="summary-box" aria-label="Selected Career Summary">
        <strong>Your Selected Careers:</strong>
        <ul>
            <?php foreach ($selected_career_titles as $title): ?>
                <li><?php echo htmlspecialchars($title); ?></li>
            <?php endforeach; ?>
        </ul>
    </section>

    <p class="intro-text">
        Below are majors recommended for your selected career paths. Click or select any program to proceed immediately to your summary page.
    </p>

    <div class="search-container">
        <label for="majorSearchInput" class="search-label">Search or Filter Majors</label>
        <input type="text" 
               id="majorSearchInput" 
               class="search-input" 
               placeholder="e.g., Business, Nursing, Computer Science, Accounting..." 
               oninput="filterMajors()"
               aria-describedby="search-hint">
        <span id="search-hint" class="sr-only">Type a keyword to filter available majors instantly. Clearing the input returns to recommended matches.</span>
    </div>

    <?php if (isset($error_message)): ?>
        <div class="error-banner" role="alert">
            <?php echo htmlspecialchars($error_message); ?>
        </div>
    <?php endif; ?>

    <form method="POST" action="majors.php" id="majorForm">
        <input type="hidden" name="action" value="save_major">
        <?php echo csrf_field(); ?>

        <fieldset class="program-fieldset">
            <legend class="program-legend">Available Programs and Degrees</legend>

            <div id="program-list-container" aria-live="polite">
                <?php $index = 0; foreach ($consolidated_programs as $unique_key => $prog): $index++; ?>
                    <?php 
                        $option_value = $prog['program_name'] . '|' . $prog['credential_type'];
                        $is_checked = ($option_value === $saved_major_key);
                        $input_id = "prog_" . $index;
                        $desc_id = "desc_" . $index;
                    ?>
                    <article class="program-card <?php echo $is_checked ? 'selected-card' : ''; ?>" 
                             data-is-recommended="true"
                             data-search-text="<?php echo htmlspecialchars(strtolower($prog['program_name'] . ' ' . $prog['credential_type'] . ' ' . $prog['credential_category'] . ' ' . $prog['description'])); ?>"
                             onclick="selectProgramCard(this, event)"
                             tabindex="0"
                             onkeydown="handleCardKeyDown(this, event)">
                        
                        <div class="radio-container">
                            <input type="radio" 
                                   name="selected_major" 
                                   value="<?php echo htmlspecialchars($option_value); ?>" 
                                   id="<?php echo $input_id; ?>" 
                                   required
                                   <?php echo $is_checked ? 'checked' : ''; ?>
                                   aria-describedby="<?php echo $desc_id; ?>"
                                   onclick="event.stopPropagation(); updateCardSelectionAndSubmit();">
                        </div>
                        
                        <div class="program-info" style="flex-grow: 1;">
                            <label for="<?php echo $input_id; ?>" style="cursor: pointer;" onclick="event.stopPropagation();">
                                <div class="degree-label">Cerritos College Degree:</div>
                                <h3><?php echo htmlspecialchars($prog['program_name']); ?> (<?php echo htmlspecialchars($prog['credential_type']); ?>)</h3>
                            </label>

                            <div class="program-meta">
                                <div class="meta-header-row">
                                    <?php if (!empty($prog['is_transfer'])): ?>
                                        <span class="badge badge-transfer">
                                            <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M12 3L1 9l11 6 9-4.91V17h2V9L12 3zm0 13.5l-7-3.82v3.82c0 2.21 3.13 4 7 4s7-1.79 7-4v-3.82l-7 3.82z"/></svg>
                                            Guaranteed Transfer (ADT)
                                        </span>
                                    <?php endif; ?>
                                    <?php if (!empty($prog['credential_category'])): ?>
                                        <span class="badge badge-cat">
                                            <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M10 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2h-8l-2-2z"/></svg>
                                            Category: <?php echo format_category_with_duration($prog['credential_category']); ?>
                                        </span>
                                    <?php endif; ?>
                                </div>

                                <?php foreach ($prog['details'] as $det): ?>
                                    <div class="career-detail-row">
                                        <span class="badge">
                                            <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M20 6h-4V4c0-1.11-.89-2-2-2h-4c-1.11 0-2 .89-2 2v2H4c-1.11 0-1.99.89-1.99 2L2 19c0 1.11.89 2 2 2h16c1.11 0 2-.89 2-2V8c0-1.11-.89-2-2-2zm-6 0h-4V4h4v2z"/></svg>
                                            For Career: <?php echo htmlspecialchars($det['career_title']); ?>
                                        </span>
                                        
                                        <?php if (!empty($det['match_type'])): ?>
                                            <span class="badge badge-match">
                                                <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                                                <?php 
                                                    $m_type = strtolower(trim($det['match_type']));
                                                    if ($m_type === 'direct') {
                                                        echo 'Direct Match';
                                                    } elseif ($m_type === 'adjacent') {
                                                        echo 'Related';
                                                    } else {
                                                        echo htmlspecialchars(ucwords(str_replace('_', ' ', $det['match_type'])));
                                                    }
                                                ?>
                                            </span>
                                        <?php endif; ?>

                                        <?php if (!empty($det['degree_type']) && empty($prog['is_transfer'])): ?>
                                            <span class="badge badge-deg-type">
                                                <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M12 3L1 9l11 6 9-4.91V17h2V9L12 3z"/></svg>
                                                Good for transfer
                                            </span>
                                        <?php endif; ?>
                                    </div>
                                <?php endforeach; ?>
                            </div>

                            <p class="program-description" id="<?php echo $desc_id; ?>">
                                <strong>Description:</strong> <?php echo htmlspecialchars(!empty($prog['description']) ? $prog['description'] : 'No detailed description available for this program.'); ?>
                            </p>
                        </div>
                    </article>
                <?php endforeach; ?>

                <!-- Additional non-matched programs hidden by default -->
                <?php foreach ($all_consolidated_programs as $unique_key => $prog): ?>
                    <?php if (!isset($consolidated_programs[$unique_key])): $index++; ?>
                        <?php 
                            $option_value = $prog['program_name'] . '|' . $prog['credential_type'];
                            $is_checked = ($option_value === $saved_major_key);
                            $input_id = "prog_" . $index;
                            $desc_id = "desc_" . $index;
                        ?>
                        <article class="program-card unrecommended-card" 
                             style="display: none;"
                             data-is-recommended="false"
                             data-search-text="<?php echo htmlspecialchars(strtolower($prog['program_name'] . ' ' . $prog['credential_type'] . ' ' . $prog['credential_category'] . ' ' . $prog['description'])); ?>"
                             onclick="selectProgramCard(this, event)"
                             tabindex="0"
                             onkeydown="handleCardKeyDown(this, event)">
                            
                            <div class="radio-container">
                                <input type="radio" 
                                       name="selected_major" 
                                       value="<?php echo htmlspecialchars($option_value); ?>" 
                                       id="<?php echo $input_id; ?>" 
                                       required
                                       <?php echo $is_checked ? 'checked' : ''; ?>
                                       aria-describedby="<?php echo $desc_id; ?>"
                                       onclick="event.stopPropagation(); updateCardSelectionAndSubmit();">
                            </div>
                            
                            <div class="program-info" style="flex-grow: 1;">
                                <label for="<?php echo $input_id; ?>" style="cursor: pointer;" onclick="event.stopPropagation();">
                                    <div class="degree-label">Cerritos College Degree:</div>
                                    <h3><?php echo htmlspecialchars($prog['program_name']); ?> (<?php echo htmlspecialchars($prog['credential_type']); ?>)</h3>
                                </label>
                                
                                <div class="program-meta">
                                    <div class="meta-header-row">
                                        <?php if (!empty($prog['is_transfer'])): ?>
                                            <span class="badge badge-transfer">
                                                <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M12 3L1 9l11 6 9-4.91V17h2V9L12 3zm0 13.5l-7-3.82v3.82c0 2.21 3.13 4 7 4s7-1.79 7-4v-3.82l-7 3.82z"/></svg>
                                                Guaranteed Transfer (ADT)
                                            </span>
                                        <?php endif; ?>
                                        <?php if (!empty($prog['credential_category'])): ?>
                                            <span class="badge badge-cat">
                                                <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M10 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2h-8l-2-2z"/></svg>
                                                Category: <?php echo format_category_with_duration($prog['credential_category']); ?>
                                            </span>
                                        <?php endif; ?>
                                    </div>
                                </div>

                                <p class="program-description" id="<?php echo $desc_id; ?>">
                                    <strong>Description:</strong> <?php echo htmlspecialchars(!empty($prog['description']) ? $prog['description'] : 'No detailed description available for this program.'); ?>
                                </p>
                            </div>
                        </article>
                    <?php endif; ?>
                <?php endforeach; ?>
            </div>
        </fieldset>

        <div id="no-results-message" class="error-banner" style="display: none;" role="alert">
            No majors match your search term. Please try another keyword or clear the search.
        </div>

        <nav class="button-group" aria-label="Form Navigation">
            <a href="career_selection.php" class="btn btn-secondary"><span aria-hidden="true">&larr;</span> Back to Careers</a>
        </nav>
    </form>
</main>

<script>
    function filterMajors() {
        const query = document.getElementById('majorSearchInput').value.toLowerCase().trim();
        const cards = document.querySelectorAll('.program-card');
        const noResultsMsg = document.getElementById('no-results-message');
        let visibleCount = 0;

        cards.forEach(card => {
            const searchText = card.getAttribute('data-search-text') || '';
            const isRecommended = card.getAttribute('data-is-recommended') === 'true';

            if (query === '') {
                if (isRecommended) {
                    card.style.display = 'flex';
                    visibleCount++;
                } else {
                    card.style.display = 'none';
                }
            } else {
                if (searchText.includes(query)) {
                    card.style.display = 'flex';
                    visibleCount++;
                } else {
                    card.style.display = 'none';
                }
            }
        });

        if (visibleCount === 0) {
            noResultsMsg.style.display = 'block';
        } else {
            noResultsMsg.style.display = 'none';
        }
    }

    function selectProgramCard(cardElement, event) {
        const radio = cardElement.querySelector('input[type="radio"]');
        if (radio && event.target !== radio && event.target.tagName !== 'LABEL') {
            radio.checked = true;
            updateCardSelectionAndSubmit();
        }
    }

    function handleCardKeyDown(cardElement, event) {
        if (event.key === ' ' || event.key === 'Enter') {
            event.preventDefault();
            const radio = cardElement.querySelector('input[type="radio"]');
            if (radio) {
                radio.checked = true;
                updateCardSelectionAndSubmit();
            }
        }
    }

    function updateCardSelectionAndSubmit() {
        const cards = document.querySelectorAll('.program-card');
        cards.forEach(card => {
            const radio = card.querySelector('input[type="radio"]');
            if (radio && radio.checked) {
                card.classList.add('selected-card');
            } else {
                card.classList.remove('selected-card');
            }
        });

        const form = document.getElementById('majorForm');
        if (form) {
            form.submit();
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        const cards = document.querySelectorAll('.program-card');
        cards.forEach(card => {
            const radio = card.querySelector('input[type="radio"]');
            if (radio && radio.checked) {
                card.classList.add('selected-card');
            } else {
                card.classList.remove('selected-card');
            }
        });
    });
</script>

</body>
</html>