<?php
// Prevent browser caching
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Pragma: no-cache");

session_start();

// Ensure applicant data from Page 1 exists, otherwise redirect to start
if (!isset($_SESSION['applicant'])) {
    header('Location: index.php');
    exit;
}

// Handle Form Submission for Page 2
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'step_2') {
    $selected_pathway = trim($_POST['pathway'] ?? '');
    $_SESSION['pathway_choice'] = $selected_pathway;
    $_SESSION['selected_pathway'] = $selected_pathway;
    $_SESSION['lcp'] = $selected_pathway;
    $_SESSION['pathway_used'] = $selected_pathway;
    
    // Retrieve current applicant info from session
    $applicant = $_SESSION['applicant'];
    
    // Save pathway selection directly to applicant array in session
    $applicant['lcp'] = $selected_pathway;
    $applicant['selected_pathway'] = $selected_pathway;
    $applicant['pathway_used'] = $selected_pathway;
    $applicant['last_updated'] = date('Y-m-d H:i:s');
    
    // Update session data
    $_SESSION['applicant'] = $applicant;
    
    // Route directly to goals.php when any option is clicked
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

// Helper to assign clean visual icons
function getPathwayIcon($pathwayName) {
    if (stripos($pathwayName, 'Exploration') !== false) return '🔍';
    if (stripos($pathwayName, 'Applied Technology') !== false) return '⚙️';
    if (stripos($pathwayName, 'Arts') !== false) return '🎨';
    if (stripos($pathwayName, 'Business') !== false) return '💼';
    if (stripos($pathwayName, 'Education') !== false) return '📚';
    if (stripos($pathwayName, 'Health') !== false) return '⚕️';
    if (stripos($pathwayName, 'Science') !== false) return '🔬';
    if (stripos($pathwayName, 'Social') !== false) return '🌐';
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
    </style>
</head>
<body>

<header>
    <h1>Cerritos College Career Exploration</h1>
    <span class="step-indicator">Page 2 of 6</span>
</header>

<div class="container">
    <h2>Select Your Learning & Career Pathway</h2>
    <p class="intro-text">Choose the pathway that best matches your field of interest to get tailored options.</p>

    <form method="POST" action="lcp.php">
        <input type="hidden" name="action" value="step_2">
        <div class="pathways-grid">
            <?php foreach ($pathways as $p): ?>
                <button type="submit" name="pathway" value="<?php echo htmlspecialchars($p['Pathway']); ?>" class="pathway-card" style="text-align: left; background: none; border: 2px solid #e1e8ed;">
                    <div class="pathway-header">
                        <div class="pathway-icon"><?php echo getPathwayIcon($p['Pathway']); ?></div>
                        <div class="pathway-title"><?php echo htmlspecialchars($p['Pathway']); ?></div>
                    </div>
                    <div style="font-size: 0.85rem; color: #666; font-weight: normal;">
                        <?php echo htmlspecialchars($p['Description']); ?>
                    </div>
                </button>
            <?php endforeach; ?>
        </div>
    </form>
</div>

</body>
</html>