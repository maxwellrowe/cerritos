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

// Handle Form Submission for Page 2
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'step_2') {
    require_valid_csrf();
    $selected_pathway = trim($_POST['pathway'] ?? '');
    
    $_SESSION['pathway_choice'] = $selected_pathway;
    $_SESSION['applicant']['lcp'] = $selected_pathway;
    
    header('Location: goals.php');
    exit;
}

// Official Cerritos College Learning and Career Pathways list
$pathways = [
    [
        'Pathway' => 'Exploration & Discovery', 
        'Description' => 'For undecided students exploring options.'
    ],
    [
        'Pathway' => 'Applied Technology & Skilled Trades', 
        'Description' => 'Hands-on programs for students interested in tools, equipment, machinery, building, repairing, automotive, welding, manufacturing, cosmetology, and other skilled trades.'
    ],
    [
        'Pathway' => 'Arts, Humanities, & Communication', 
        'Description' => 'Creative and communication-focused programs including visual and performing arts, media, journalism, literature, language, and public or nonprofit work.'
    ],
    [
        'Pathway' => 'Business, Accounting, & Law', 
        'Description' => 'Programs focused on managing people and finances, business administration, accounting, finance, marketing, office technology, paralegal studies, real estate, and law.'
    ],
    [
        'Pathway' => 'Education & Human Services', 
        'Description' => 'Programs for students interested in teaching, learning, child welfare, instructional technology, advocacy, and support roles in educational or human-service settings.'
    ],
    [
        'Pathway' => 'Health Sciences & Wellness', 
        'Description' => 'Programs related to fitness, wellness, healthcare practice and support, including nursing, dental hygiene, medical assisting, nutrition, and physical therapist assisting.'
    ],
    [
        'Pathway' => 'Science, Engineering, & Math', 
        'Description' => 'Programs for students interested in technical or abstract problem-solving, natural sciences, engineering, computer science, labs, data science, and medical-field preparation.'
    ],
    [
        'Pathway' => 'Social & Behavioral Sciences', 
        'Description' => 'Programs centered on people, society, institutions, human behavior, culture, relationships, and careers where understanding people or society is important.'
    ]
];

function getPathwayIcon($pathwayName) {
    if (stripos($pathwayName, 'Exploration') !== false) return '🔍';
    if (stripos($pathwayName, 'Applied Technology') !== false) return '⚙️';
    if (stripos($pathwayName, 'Arts') !== false) return '🎨';
    if (stripos($pathwayName, 'Business') !== false) return '💼';
    if (stripos($pathwayName, 'Education') !== false) return '📚';
    if (stripos($pathwayName, 'Health') !== false) return '⚕️';
    if (stripos($pathwayName, 'Social') !== false) return '👥';
    if (stripos($pathwayName, 'Science') !== false) return '🔬';
    return '🎓';
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cerritos College - Learning & Career Pathways (Page 2)</title>
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
            max-width: 900px;
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
        }
        .pathways-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 1.2rem;
            margin-bottom: 2rem;
        }
        .pathway-card {
            border: 2px solid #e1e8ed;
            border-radius: 8px;
            padding: 1.25rem;
            background: #fff;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            flex-direction: column;
            position: relative;
        }
        .pathway-card:hover {
            border-color: var(--cerritos-blue);
            box-shadow: 0 4px 10px rgba(0, 43, 73, 0.08);
            transform: translateY(-2px);
        }
        .pathway-header {
            display: flex;
            align-items: center;
            margin-bottom: 0.75rem;
        }
        .pathway-icon {
            font-size: 2rem;
            margin-right: 0.75rem;
            background: #eef3f8;
            width: 50px;
            height: 50px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            flex-shrink: 0;
        }
        .pathway-title {
            font-weight: bold;
            color: var(--cerritos-blue);
            font-size: 1.05rem;
        }
        .pathway-desc {
            font-size: 0.88rem;
            color: #666;
            line-height: 1.4;
            flex-grow: 1;
            margin-bottom: 1rem;
        }
        .pathway-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-top: 1px solid #eee;
            padding-top: 0.75rem;
            font-size: 0.85rem;
            font-weight: bold;
            color: var(--cerritos-blue);
        }
        .unsure-box {
            background: #fff8e6;
            border: 2px dashed #ffc72c;
            padding: 1.25rem;
            border-radius: 8px;
            margin-bottom: 2rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            cursor: pointer;
            transition: background 0.2s ease;
        }
        .unsure-box:hover {
            background: #fff3d1;
        }
        .button-group {
            display: flex;
            justify-content: flex-start;
            align-items: center;
            border-top: 1px solid #eee;
            padding-top: 1.5rem;
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
    <span class="step-indicator">Page 2 of 6: Learning & Career Pathways</span>
</header>

<div class="container">
    <form method="POST" action="lcp.php" id="pathwayForm">
        <input type="hidden" name="action" value="step_2">
        <?php echo csrf_field(); ?>
        <input type="hidden" name="pathway" id="selectedPathwayInput" value="">
        
        <h2>Choose Your Learning & Career Pathway</h2>
        <p class="intro-text">At Cerritos College, programs are grouped into Learning and Career Pathways to keep you on track. Select any pathway below to instantly proceed to your next step.</p>
        
        <div class="unsure-box" onclick="selectAndSubmit('Exploration & Discovery')">
            <div style="display: flex; align-items: center;">
                <span style="font-size: 2rem; margin-right: 1rem;">🤔</span>
                <div>
                    <strong style="color: var(--cerritos-blue); font-size: 1.05rem; display: block; margin-bottom: 0.2rem;">I'm Not Sure / Undecided</strong>
                    <span style="font-size: 0.88rem; color: #555;">For undecided students exploring options. (Proceeds to Goals)</span>
                </div>
            </div>
            <div>
                <span style="font-weight: bold; color: var(--cerritos-blue); font-size: 1.1rem;">&rarr;</span>
            </div>
        </div>

        <div class="pathways-grid">
            <?php foreach ($pathways as $p): 
                $pName = $p['Pathway'] ?? '';
                $pDesc = $p['Description'] ?? '';
                if (stripos($pName, 'Exploration') !== false) continue;
                $icon = getPathwayIcon($pName);
            ?>
                <div class="pathway-card" onclick="selectAndSubmit('<?php echo htmlspecialchars($pName, ENT_QUOTES); ?>')">
                    <div class="pathway-header">
                        <div class="pathway-icon"><?php echo $icon; ?></div>
                        <div class="pathway-title"><?php echo htmlspecialchars($pName); ?></div>
                    </div>
                    <div class="pathway-desc"><?php echo htmlspecialchars($pDesc); ?></div>
                    <div class="pathway-footer">
                        <span>Select Pathway</span>
                        <span>&rarr;</span>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
        
        <div class="button-group">
            <a href="index.php" class="btn btn-secondary">&larr; Back to Page 1</a>
        </div>
    </form>
</div>

<script>
function selectAndSubmit(pathwayName) {
    document.getElementById('selectedPathwayInput').value = pathwayName;
    document.getElementById('pathwayForm').submit();
}
</script>

</body>
</html>
