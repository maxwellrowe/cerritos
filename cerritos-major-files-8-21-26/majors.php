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

$normalized_selected_titles = array_map('normalize_title', $selected_career_titles);

// 1. Fetch degree & program listings from degrees.json
$degrees_data = [];
if (file_exists('degrees.json')) {
    $degrees_json_content = file_get_contents('degrees.json');
    $decoded_json = json_decode($degrees_json_content, true) ?: [];
    
    // Handle both top-level array and {"degrees": [...]} object formats
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

foreach ($degrees_data as $data) {
    if (!isset($data['program_name'])) continue;

    $prog_name = trim($data['program_name']);
    $cred_type = trim($data['credential_type'] ?? 'AA-T');
    $cred_cat = trim($data['credential_category'] ?? 'Associate Degree');
    
    // Use description directly from degrees.json
    $prog_desc = trim($data['description'] ?? '');

    $rcms = $data['related_career_matches'] ?? [];
    if (is_string($rcms)) {
        $rcms = json_decode($rcms, true) ?: [];
    }

    if (is_array($rcms)) {
        foreach ($rcms as $rcm) {
            $rcm_title = is_array($rcm) ? trim($rcm['title'] ?? '') : trim($rcm);
            $degree_req = is_array($rcm) ? trim($rcm['degree_required'] ?? '') : '';
            $match_type = is_array($rcm) ? trim($rcm['match_type'] ?? '') : '';
            $degree_type = is_array($rcm) ? trim($rcm['degree_type'] ?? '') : '';

            $norm_rcm = normalize_title($rcm_title);

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

// Consolidate programs by Program Name & Credential Type
$consolidated_programs = [];
foreach ($matched_programs as $p) {
    $p_name = $p['program_name'];
    $c_type = $p['credential_type'];
    $unique_key = $p_name . '|' . $c_type;
    
    // Detect transfer degree status (AA-T or AS-T)
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
        if (normalize_title($det['career_title']) === normalize_title($p['career_title'])) {
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

// Sort career details within each program so "direct" pathways appear at the top, followed by "adjacent"
foreach ($consolidated_programs as &$prog) {
    usort($prog['details'], function($a, $b) {
        $a_is_direct = (strtolower($a['match_type']) === 'direct') ? 0 : 1;
        $b_is_direct = (strtolower($b['match_type']) === 'direct') ? 0 : 1;
        
        if ($a_is_direct !== $b_is_direct) {
            return $a_is_direct <=> $b_is_direct; // 'direct' (0) comes before non-direct (1)
        }
        return strcasecmp($a['career_title'], $b['career_title']);
    });
}
unset($prog);

// Sort programs: 1) ADT (top), 2) Direct match with user's education goal, 3) Program Name
uasort($consolidated_programs, function($a, $b) use ($user_goal_type) {
    // Top Priority: ADT (Guaranteed Transfer)
    if ($a['is_transfer'] !== $b['is_transfer']) {
        return $b['is_transfer'] <=> $a['is_transfer']; 
    }

    // Secondary/Tertiary Priority: Match user's education goal type
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
        return $matches_goal_b <=> $matches_goal_a; // Matching goal type comes first
    }

    return strcasecmp($a['program_name'], $b['program_name']);
});
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
        .error-banner {
            background: #f8d7da;
            color: #721c24;
            padding: 1rem;
            border: 1px solid #f5c6cb;
            border-radius: 4px;
            margin-bottom: 1.5rem;
        }
        .program-card {
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
        .program-card:hover {
            border-color: var(--cerritos-blue);
            background-color: #f1f7ff;
        }
        .program-card input[type="radio"] {
            margin-top: 0.3rem;
            transform: scale(1.2);
            cursor: pointer;
        }
        .program-info h3 {
            margin: 0 0 0.2rem 0;
            color: var(--cerritos-blue);
            font-size: 1.1rem;
        }
        .degree-label {
            font-size: 0.8rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #555;
            font-weight: bold;
            margin-bottom: 0.2rem;
        }
        .program-meta {
            font-size: 0.85rem;
            color: #666;
            margin-top: 0.4rem;
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
        .badge-type { background: #d4edda; color: #155724; }
        .badge-cat { background: #d1ecf1; color: #0c5460; }
        .badge-req { background: #fff3cd; color: #856404; }
        .badge-deg-type { background: #fae8ff; color: #86198f; border: 1px solid #f5d0fe; }
        .badge-match { 
            background: #e0f2fe; 
            color: #0369a1; 
            border: 1px solid #bae6fd; 
        }
        .badge-transfer { 
            background: #002b49; 
            color: #ffffff; 
            border: 1px solid #001d32;
            box-shadow: 0 1px 3px rgba(0,0,0,0.12);
        }
        
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
    </style>
</head>
<body>

<header>
    <h1>Cerritos College Career Exploration</h1>
    <span class="step-indicator">Major Selection</span>
</header>

<div class="container">
    <h2>Select Your Program / Major</h2>
    
    <div class="summary-box">
        <strong>Your Selected Careers:</strong><br>
        <ul>
            <?php foreach ($selected_career_titles as $title): ?>
                <li><?php echo htmlspecialchars($title); ?></li>
            <?php endforeach; ?>
        </ul>
    </div>

    <p class="intro-text">
        Based on your selected careers, here are the corresponding academic programs and majors available. Hover over any program card below to view its description, then choose the program and credential type you want to pursue.
    </p>

    <?php if (isset($error_message)): ?>
        <div class="error-banner">
            <?php echo htmlspecialchars($error_message); ?>
        </div>
    <?php endif; ?>

    <form method="POST" action="majors.php" id="majorForm">
        <input type="hidden" name="action" value="save_major">
        <?php echo csrf_field(); ?>

        <?php if (empty($consolidated_programs)): ?>
            <div class="error-banner">
                No matching academic programs were found for your selected careers. Please return to modify your career choices.
            </div>
        <?php else: ?>
            <?php $index = 0; foreach ($consolidated_programs as $unique_key => $prog): $index++; ?>
                <div class="program-card" 
                     data-name="<?php echo htmlspecialchars($prog['program_name'] . ' (' . $prog['credential_type'] . ')'); ?>"
                     data-description="<?php echo htmlspecialchars(!empty($prog['description']) ? $prog['description'] : 'No detailed description available for this program.'); ?>"
                     onmousemove="moveTooltip(event, this)"
                     onmouseenter="showTooltip(event, this)"
                     onmouseleave="hideTooltip()"
                     onclick="selectCardRadio(this)">
                    
                    <input type="radio" name="selected_major" value="<?php echo htmlspecialchars($prog['program_name'] . '|' . $prog['credential_type']); ?>" id="prog_<?php echo $index; ?>" required>
                    
                    <div class="program-info" style="flex-grow: 1;">
                        <label for="prog_<?php echo $index; ?>" style="cursor: pointer;">
                            <div class="degree-label">Cerritos College Degree:</div>
                            <h3><?php echo htmlspecialchars($prog['program_name']); ?> (<?php echo htmlspecialchars($prog['credential_type']); ?>)</h3>
                        </label>
                        <div class="program-meta">
                            <?php if (!empty($prog['is_transfer'])): ?>
                                <span class="badge badge-transfer">🎓 Guaranteed Transfer (ADT)</span>
                            <?php endif; ?>
                            <?php if (!empty($prog['credential_type'])): ?>
                                <span class="badge badge-type">Credential: <?php echo htmlspecialchars($prog['credential_type']); ?></span>
                            <?php endif; ?>
                            <?php if (!empty($prog['credential_category'])): ?>
                                <span class="badge badge-cat">Category: <?php echo htmlspecialchars($prog['credential_category']); ?></span>
                            <?php endif; ?>
                            <br>
                            <?php foreach ($prog['details'] as $det): ?>
                                <span class="badge">For Career: <?php echo htmlspecialchars($det['career_title']); ?></span>
                                
                                <?php if (!empty($det['match_type'])): ?>
                                    <span class="badge badge-match">
                                        <?php 
                                            $m_type = strtolower(trim($det['match_type']));
                                            if ($m_type === 'direct') {
                                                echo '⭐ Direct Match';
                                            } elseif ($m_type === 'adjacent') {
                                                echo '🔄 Adjacent';
                                            } else {
                                                echo htmlspecialchars(ucwords(str_replace('_', ' ', $det['match_type'])));
                                            }
                                        ?>
                                    </span>
                                <?php endif; ?>

                                <?php if (!empty($det['degree_type'])): ?>
                                    <span class="badge badge-deg-type">Degree Type: <?php echo htmlspecialchars($det['degree_type']); ?></span>
                                <?php endif; ?>

                                <?php if (!empty($det['degree_required'])): ?>
                                    <span class="badge badge-req">Degree Required: <?php echo htmlspecialchars($det['degree_required']); ?></span>
                                <?php endif; ?>
                                <br>
                            <?php endforeach; ?>
                        </div>
                    </div>
                </div>
            <?php endforeach; ?>
        <?php endif; ?>

        <div id="description-tooltip">
            <h3 id="tooltip-title">Program Description</h3>
            <p id="tooltip-text"></p>
        </div>

        <div class="button-group">
            <a href="career_selection.php" class="btn btn-secondary">&larr; Back to Careers</a>
            <button type="submit" class="btn" id="submitBtn">Proceed to Summary &rarr;</button>
        </div>
    </form>
</div>

<script>
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

    function selectCardRadio(cardElement) {
        const radio = cardElement.querySelector('input[type="radio"]');
        if (radio) {
            radio.checked = true;
        }
    }
</script>

</body>
</html>