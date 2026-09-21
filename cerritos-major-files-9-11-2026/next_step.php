<?php
// Prevent browser caching
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

require_once __DIR__ . '/app_bootstrap.php';

// Check if applicant session exists
if (!isset($_SESSION['applicant']) || empty($_SESSION['applicant']['email'])) {
    header('Location: index.php');
    exit;
}

// Ensure assessment data exists before viewing results
if (empty($_SESSION['applicant']['riasec_scores'])) {
    header('Location: interest_inventory.php');
    exit;
}

// RIASEC Category Metadata & Descriptions
$riasec_meta = [
    'R' => [
        'name' => 'Realistic',
        'title' => 'The Doer',
        'badge_class' => 'theme-R',
        'desc' => 'Practical, hands-on, and mechanical. You enjoy working with tools, machines, animals, or outdoor activities.'
    ],
    'I' => [
        'name' => 'Investigative',
        'title' => 'The Thinker',
        'badge_class' => 'theme-I',
        'desc' => 'Analytical, precise, and curious. You enjoy researching, analyzing data, and solving complex problems.'
    ],
    'A' => [
        'name' => 'Artistic',
        'title' => 'The Creator',
        'badge_class' => 'theme-A',
        'desc' => 'Creative, expressive, and original. You enjoy visual arts, design, writing, music, and unconventional thinking.'
    ],
    'S' => [
        'name' => 'Social',
        'title' => 'The Helper',
        'badge_class' => 'theme-S',
        'desc' => 'Empathic, communicative, and supportive. You enjoy teaching, coaching, helping, and advising others.'
    ],
    'E' => [
        'name' => 'Enterprising',
        'title' => 'The Persuader',
        'badge_class' => 'theme-E',
        'desc' => 'Confident, energetic, and goal-oriented. You enjoy leading projects, persuading others, and taking initiative.'
    ],
    'C' => [
        'name' => 'Conventional',
        'title' => 'The Organizer',
        'badge_class' => 'theme-C',
        'desc' => 'Detail-oriented, orderly, and reliable. You enjoy organizing data, managing schedules, and following structured processes.'
    ]
];

// Read completed assessment scores from session
$scores = $_SESSION['applicant']['riasec_scores'] ?? ['R' => 0, 'I' => 0, 'A' => 0, 'S' => 0, 'E' => 0, 'C' => 0];
$top_three = $_SESSION['applicant']['top_three_codes'] ?? ['R', 'I', 'A'];

// Calculate max score possible per theme (3 questions * max 5 points = 15)
$max_score = 15;
$holland_code = implode('', $top_three);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cerritos College - Assessment Results</title>
    <style>
        :root {
            /* WCAG AAA High Contrast Color System */
            --cerritos-blue: #002b49;
            --cerritos-gold: #8a6200;
            --cerritos-light: #f8fafc;
            --cerritos-dark: #0f172a;
            --card-border: #475569;
            --text-muted: #334155;
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

        /* Screen Reader Only Utility */
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
            padding: 0.75rem 1.25rem;
            border-bottom: 4px solid var(--cerritos-gold);
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 100;
        }

        header h1 {
            font-size: 1.15rem;
            margin: 0;
            font-weight: 600;
        }

        .step-badge {
            font-size: 0.85rem;
            background: rgba(255, 255, 255, 0.2);
            padding: 0.3rem 0.7rem;
            border-radius: 12px;
            font-weight: 600;
            color: #ffffff;
        }

        .main-container {
            max-width: 850px;
            margin: 1.5rem auto;
            padding: 0 1rem;
        }

        .intro-card {
            background: #ffffff;
            padding: 1.25rem;
            border-radius: 8px;
            border: 2px solid var(--card-border);
            border-left: 6px solid var(--cerritos-blue);
            margin-bottom: 1.5rem;
        }

        .intro-card h2 {
            margin: 0 0 0.4rem 0;
            color: var(--cerritos-blue);
            font-size: 1.3rem;
        }

        .intro-card p {
            margin: 0;
            color: var(--text-muted);
            font-size: 0.95rem;
        }

        .code-banner {
            display: inline-flex;
            gap: 0.5rem;
            margin-top: 0.85rem;
        }

        .code-chip {
            background: var(--cerritos-blue);
            color: #ffffff;
            font-weight: 700;
            font-size: 1.05rem;
            padding: 0.3rem 0.75rem;
            border-radius: 4px;
            letter-spacing: 0.5px;
            border: 1px solid #ffffff;
        }

        /* Top 3 Themes Grid */
        .results-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1rem;
            margin-bottom: 1.5rem;
        }

        @media (max-width: 768px) {
            .results-grid {
                grid-template-columns: 1fr;
            }
        }

        .result-card {
            background: #ffffff;
            border: 2px solid var(--card-border);
            border-radius: 8px;
            padding: 1.1rem;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .result-card.rank-1 {
            border: 3px solid var(--cerritos-gold);
            background-color: #fffdf8;
        }

        .card-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 0.5rem;
        }

        .rank-tag {
            font-size: 0.75rem;
            font-weight: 800;
            text-transform: uppercase;
            color: var(--cerritos-blue);
            background: #eef6ff;
            padding: 0.2rem 0.5rem;
            border-radius: 4px;
            border: 1px solid #cbd5e1;
        }

        .rank-tag.primary-tag {
            background: #fff3d1;
            color: #5c4100;
            border-color: var(--cerritos-gold);
        }

        .theme-title {
            font-size: 1.15rem;
            font-weight: 700;
            margin: 0.3rem 0 0.1rem 0;
            color: var(--cerritos-dark);
        }

        .theme-subtitle {
            font-size: 0.8rem;
            color: var(--text-muted);
            font-weight: 700;
            margin-bottom: 0.6rem;
        }

        .theme-desc {
            font-size: 0.85rem;
            color: var(--cerritos-dark);
            line-height: 1.45;
            margin-bottom: 1rem;
        }

        /* Accessible Progress Bar */
        .progress-container {
            background: #cbd5e1;
            border-radius: 6px;
            height: 12px;
            overflow: hidden;
            margin-bottom: 0.35rem;
            border: 1px solid #94a3b8;
        }

        .progress-bar {
            height: 100%;
            background-color: var(--cerritos-blue);
            border-radius: 4px;
            transition: width 0.4s ease;
        }

        .score-text {
            font-size: 0.8rem;
            color: var(--cerritos-dark);
            text-align: right;
            font-weight: 700;
        }

        /* Full Scores Section */
        .all-scores-section {
            background: #ffffff;
            border: 2px solid var(--card-border);
            border-radius: 8px;
            padding: 1.25rem;
            margin-bottom: 1.5rem;
        }

        .all-scores-section h3 {
            margin: 0 0 1rem 0;
            color: var(--cerritos-blue);
            font-size: 1.1rem;
        }

        .score-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .score-row {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 0.75rem;
        }

        .score-row-label {
            width: 140px;
            font-size: 0.85rem;
            font-weight: 700;
            color: var(--cerritos-dark);
        }

        .score-row-bar {
            flex: 1;
        }

        /* Actions Bar */
        .action-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #ffffff;
            padding: 1rem;
            border-radius: 8px;
            border: 2px solid var(--card-border);
        }

        .btn {
            padding: 0.65rem 1.25rem;
            font-size: 0.95rem;
            font-weight: 700;
            border-radius: 5px;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-block;
        }

        .btn-secondary {
            background-color: #f0f4f8;
            color: var(--cerritos-blue);
            border: 2px solid var(--cerritos-blue);
        }

        .btn-secondary:hover {
            background-color: var(--cerritos-blue);
            color: #ffffff;
        }

        .btn-primary {
            background-color: var(--cerritos-blue);
            color: #ffffff;
            border: 2px solid var(--cerritos-blue);
        }

        .btn-primary:hover {
            background-color: #001d32;
            border-color: #001d32;
        }

        .btn:focus,
        a:focus {
            outline: 3px solid var(--focus-outline);
            outline-offset: 3px;
        }
    </style>
</head>
<body>

<header role="banner">
    <h1>Cerritos College Career Assessment</h1>
    <span class="step-badge">Assessment Complete</span>
</header>

<main class="main-container" id="main-content">

    <section class="intro-card" aria-labelledby="profile-heading">
        <h2 id="profile-heading">Your Holland Code Profile</h2>
        <p>Based on your responses, here are your primary career interest drivers:</p>
        
        <div class="code-banner" role="region" aria-label="Holland Code Sequence: <?php echo htmlspecialchars($holland_code); ?>">
            <?php foreach ($top_three as $code): ?>
                <span class="code-chip">
                    <span class="sr-only">Code letter </span><?php echo htmlspecialchars($code); ?>
                </span>
            <?php endforeach; ?>
        </div>
    </section>

    <!-- Top 3 Match Cards -->
    <section aria-label="Top 3 Match Profiles">
        <div class="results-grid">
            <?php 
            $rank = 1;
            foreach ($top_three as $code): 
                $meta = $riasec_meta[$code];
                $score = $scores[$code] ?? 0;
                $percentage = min(100, round(($score / $max_score) * 100));
                $is_primary = ($rank === 1);
            ?>
                <article class="result-card <?php echo $is_primary ? 'rank-1' : ''; ?>" aria-labelledby="theme-title-<?php echo $code; ?>">
                    <div>
                        <div class="card-top">
                            <span class="rank-tag <?php echo $is_primary ? 'primary-tag' : ''; ?>">
                                <?php echo $is_primary ? '★ ' : ''; ?>Top Match #<?php echo $rank++; ?>
                            </span>
                        </div>
                        <h3 id="theme-title-<?php echo $code; ?>" class="theme-title"><?php echo htmlspecialchars($meta['name']); ?></h3>
                        <div class="theme-subtitle"><?php echo htmlspecialchars($meta['title']); ?></div>
                        <p class="theme-desc"><?php echo htmlspecialchars($meta['desc']); ?></p>
                    </div>

                    <div>
                        <div 
                            class="progress-container" 
                            role="progressbar" 
                            aria-valuenow="<?php echo $score; ?>" 
                            aria-valuemin="0" 
                            aria-valuemax="<?php echo $max_score; ?>" 
                            aria-label="<?php echo htmlspecialchars($meta['name']); ?> score progress: <?php echo $score; ?> out of <?php echo $max_score; ?> points"
                        >
                            <div class="progress-bar" style="width: <?php echo $percentage; ?>%;"></div>
                        </div>
                        <div class="score-text">Score: <?php echo $score; ?> / <?php echo $max_score; ?> pts</div>
                    </div>
                </article>
            <?php endforeach; ?>
        </div>
    </section>

    <!-- Full Profile Score Breakdown -->
    <section class="all-scores-section" aria-labelledby="full-breakdown-heading">
        <h3 id="full-breakdown-heading">Full RIASEC Profile Breakdown</h3>
        <ul class="score-list">
            <?php foreach ($scores as $code => $score): 
                $meta = $riasec_meta[$code];
                $pct = min(100, round(($score / $max_score) * 100));
            ?>
                <li class="score-row">
                    <div class="score-row-label">
                        <?php echo htmlspecialchars($meta['name']); ?> (<?php echo $code; ?>)
                    </div>
                    <div class="score-row-bar">
                        <div 
                            class="progress-container" 
                            role="progressbar" 
                            aria-valuenow="<?php echo $score; ?>" 
                            aria-valuemin="0" 
                            aria-valuemax="<?php echo $max_score; ?>"
                            aria-label="<?php echo htmlspecialchars($meta['name']); ?> score: <?php echo $score; ?> out of <?php echo $max_score; ?> points"
                        >
                            <div class="progress-bar" style="width: <?php echo $pct; ?>%;"></div>
                        </div>
                    </div>
                    <div class="score-text" style="width: 55px; text-align: right;"><?php echo $score; ?> pts</div>
                </li>
            <?php endforeach; ?>
        </ul>
    </section>

    <nav class="action-bar" aria-label="Results Actions">
        <a href="interest_inventory.php?mode=retake" class="btn btn-secondary">
            <span aria-hidden="true">&larr;</span> Retake RIASEC Assessment
        </a>
        <a href="career_selection.php" class="btn btn-primary">
            Explore Career Matches <span aria-hidden="true">&rarr;</span>
        </a>
    </nav>

</main>

</body>
</html>