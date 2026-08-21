<?php
// Prevent browser caching
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Pragma: no-cache");

session_start();

// Ensure data/applicant_ data and selected careers exist
if (!isset($_SESSION['applicant']) || empty($_SESSION['applicant']['selected_careers'])) {
    header('Location: career_selection.php');
    exit;
}

$applicant = $_SESSION['applicant'];
$selected_careers = $applicant['selected_careers'];

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

// Load degree_descriptions.json separately for dedicated program descriptions
$descJsonFile = 'degree_descriptions.json';
$degree_descriptions_lookup = [];
if (file_exists($descJsonFile)) {
    $raw_desc_json = file_get_contents($descJsonFile);
    $decoded_desc = json_decode($raw_desc_json, true);
    
    if (is_array($decoded_desc)) {
        $desc_list = $decoded_desc['degrees'] ?? ($decoded_desc['programs'] ?? $decoded_desc);
        foreach ($desc_list as $item) {
            $name = trim($item['program_name'] ?? ($item['title'] ?? ''));
            $desc = trim($item['description'] ?? '');
            if (!empty($name)) {
                $degree_descriptions_lookup[strtolower($name)] = $desc;
            }
        }
    }
}

// Handle major selection form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'save_major') {
    $selected_major_key = $_POST['selected_major'] ?? '';
    
    if (!empty($selected_major_key)) {
        $parts = explode('|', $selected_major_key);
        $selected_major = $parts[0] ?? '';
        $selected_credential_type = $parts[1] ?? '';
        
        $_SESSION['selected_major'] = $selected_major;
        $_SESSION['selected_credential_type'] = $selected_credential_type;
        
        $currentTime = date('Y-m-d H:i:s');
        $applicant['selected_major'] = $selected_major;
        $applicant['selected_credential_type'] = $selected_credential_type;
        $applicant['last_updated'] = $currentTime;
        $_SESSION['applicant'] = $applicant;
        
        header('Location: summary.php');
        exit;
    } else {
        $error_message = "Please select a major/program before continuing.";
    }
}

// Extract programs from degrees.json
$matched_programs = [];

function extract_programs_from_degrees($data, $target_careers, &$results) {
    if (!is_array($data)) return;
    
    if (isset($data['program_name']) && isset($data['related_career_matches']) && is_array($data['related_career_matches'])) {
        $prog_name = trim($data['program_name']);
        $cred_type = trim($data['credential_type'] ?? 'Degree / Certificate');
        $cred_cat = trim($data['credential_category'] ?? 'Associate Degree');
        $prog_desc = trim($data['description'] ?? '');
        
        foreach ($data['related_career_matches'] as $rcm) {
            $rcm_title = trim($rcm['title'] ?? '');
            if (!empty($rcm_title) && in_array($rcm_title, $target_careers, true)) {
                $results[] = [
                    'career_title' => $rcm_title,
                    'program_name' => $prog_name,
                    'credential_type' => $cred_type,
                    'credential_category' => $cred_cat,
                    'description' => $prog_desc,
                    'degree_required' => trim($rcm['degree_required'] ?? '')
                ];
            }
        }
    }
    
    foreach ($data as $value) {
        if (is_array($value)) {
            extract_programs_from_degrees($value, $target_careers, $results);
        }
    }
}

extract_programs_from_degrees($degrees_data, $selected_careers, $matched_programs);

if (empty($matched_programs)) {
    foreach ($selected_careers as $sc) {
        $matched_programs[] = [
            'career_title' => $sc,
            'program_name' => $sc . ' Studies',
            'credential_type' => 'AA-T',
            'credential_category' => 'Associate Degree',
            'description' => 'This program develops foundational skills and knowledge tailored for this pathway.',
            'degree_required' => 'Bachelor'
        ];
    }
}

$consolidated_programs = [];
foreach ($matched_programs as $p) {
    $p_name = $p['program_name'];
    $c_type = $p['credential_type'];
    $unique_key = $p_name . '|' . $c_type;
    
    $lower_name = strtolower($p_name);
    $final_desc = '';
    if (isset($degree_descriptions_lookup[$lower_name])) {
        $final_desc = $degree_descriptions_lookup[$lower_name];
    } else {
        $final_desc = $p['description'];
    }
    
    if (!isset($consolidated_programs[$unique_key])) {
        $consolidated_programs[$unique_key] = [
            'program_name' => $p_name,
            'credential_type' => $c_type,
            'credential_category' => $p['credential_category'],
            'description' => $final_desc,
            'details' => []
        ];
    }
    
    $exists = false;
    foreach ($consolidated_programs[$unique_key]['details'] as $det) {
        if ($det['career_title'] === $p['career_title']) {
            $exists = true;
            break;
        }
    }
    
    if (!$exists) {
        $consolidated_programs[$unique_key]['details'][] = [
            'career_title' => $p['career_title'],
            'degree_required' => $p['degree_required']
        ];
    }
}

uasort($consolidated_programs, function($a, $b) {
    if ($a['program_name'] === 'Political Science') return -1;
    if ($b['program_name'] === 'Political Science') return 1;
    return 0;
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

        /* --- PLEASE WAIT OVERLAY STYLES --- */
        #loading-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background-color: rgba(0, 43, 73, 0.75);
            backdrop-filter: blur(4px);
            z-index: 99999;
            align-items: center;
            justify-content: center;
        }
        .loading-card {
            background: #ffffff;
            padding: 2.5rem 3rem;
            border-radius: 12px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.25);
            text-align: center;
            max-width: 420px;
            width: 85%;
            border-top: 6px solid var(--cerritos-gold);
            animation: fadeIn 0.3s ease;
        }
        .spinner {
            width: 55px;
            height: 55px;
            margin: 0 auto 1.25rem auto;
            border: 5px solid #e1e8ed;
            border-top: 5px solid var(--cerritos-blue);
            border-right: 5px solid var(--cerritos-gold);
            border-radius: 50%;
            animation: spin 0.9s linear infinite;
        }
        .loading-title {
            color: var(--cerritos-blue);
            font-size: 1.35rem;
            font-weight: bold;
            margin-bottom: 0.5rem;
        }
        .loading-text {
            color: #555;
            font-size: 0.95rem;
            line-height: 1.4;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: scale(0.95); }
            to { opacity: 1; transform: scale(1); }
        }
    </style>
</head>
<body>

<!-- Overlay element -->
<div id="loading-overlay">
    <div class="loading-card">
        <div class="spinner"></div>
        <div class="loading-title">Please Wait...</div>
        <div class="loading-text">We are compiling your choices and saving your career profile to Google Sheets.</div>
    </div>
</div>

<header>
    <h1>Cerritos College Career Exploration</h1>
    <span class="step-indicator">Major Selection</span>
</header>

<div class="container">
    <h2>Select Your Program / Major</h2>
    
    <div class="summary-box">
        <strong>Your Selected Careers:</strong><br>
        <ul>
            <?php foreach ($selected_careers as $c): ?>
                <li><?php echo htmlspecialchars($c); ?></li>
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

    <form method="POST" action="majors.php" id="majorForm" onsubmit="showLoadingOverlay()">
        <input type="hidden" name="action" value="save_major">

        <?php if (empty($consolidated_programs)): ?>
            <div class="error-banner">
                No specific program records were found matching your chosen careers in our database. Please select your preferred program or return to modify your career choices.
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
                            <?php if (!empty($prog['credential_type'])): ?>
                                <span class="badge badge-type">Credential: <?php echo htmlspecialchars($prog['credential_type']); ?></span>
                            <?php endif; ?>
                            <?php if (!empty($prog['credential_category'])): ?>
                                <span class="badge badge-cat">Category: <?php echo htmlspecialchars($prog['credential_category']); ?></span>
                            <?php endif; ?>
                            <br>
                            <?php foreach ($prog['details'] as $det): ?>
                                <span class="badge">For Career: <?php echo htmlspecialchars($det['career_title']); ?></span>
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
    function showLoadingOverlay() {
        // Trigger overlay only if a radio option is checked
        const selectedRadio = document.querySelector('input[name="selected_major"]:checked');
        if (selectedRadio) {
            document.getElementById('loading-overlay').style.display = 'flex';
        }
    }

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