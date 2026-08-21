<?php
// Prevent browser caching
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

require_once __DIR__ . '/app_bootstrap.php';

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

// Fallback if session is missing
$scores = $_SESSION['applicant']['riasec_scores'] ?? ['R' => 0, 'I' => 0, 'A' => 0, 'S' => 0, 'E' => 0, 'C' => 0];
$top_three = $_SESSION['applicant']['top_three_codes'] ?? ['R', 'I', 'A'];

// Calculate max score possible per theme (3 questions * max 5 points = 15)
$max_score = 15;
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cerritos College - Assessment Results</title>
    <style>
        :root {
            --cerritos-blue: #002b49;
            --cerritos-gold: #ffc72c;
            --cerritos-light: #f8fafc;
            --card-border: #e2e8f0;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background-color: var(--cerritos-light);
            color: #1e293b;
            margin: 0;
            padding: 0;
            font-size: 14px;
        }

        header {
            background-color: var(--cerritos-blue);
            color: #ffffff;
            padding: 0.6rem 1.25rem;
            border-bottom: 3px solid var(--cerritos-gold);
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 100;
        }

        header h1 {
            font-size: 1.1rem;
            margin: 0;
            font-weight: 600;
        }

        .step-badge {
            font-size: 0.75rem;
            background: rgba(255, 255, 255, 0.2);
            padding: 0.2rem 0.6rem;
            border-radius: 12px;
            font-weight: 500;
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
            border: 1px solid var(--card-border);
            border-left: 4px solid var(--cerritos-blue);
            margin-bottom: 1.5rem;
        }

        .intro-card h2 {
            margin: 0 0 0.4rem 0;
            color: var(--cerritos-blue);
            font-size: 1.3rem;
        }

        .intro-card p {
            margin: 0;
            color: #64748b;
            font-size: 0.9rem;
        }

        .code-banner {
            display: inline-flex;
            gap: 0.4rem;
            margin-top: 0.75rem;
        }

        .code-chip {
            background: var(--cerritos-blue);
            color: #ffffff;
            font-weight: 700;
            font-size: 1rem;
            padding: 0.25rem 0.65rem;
            border-radius: 4px;
            letter-spacing: 0.5px;
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
            border: 1px solid var(--card-border);
            border-radius: 8px;
            padding: 1rem;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            box-shadow: 0 2px 4px rgba(0,0,0,0.02);
        }

        .result-card.rank-1 {
            border-color: var(--cerritos-gold);
            box-shadow: 0 4px 12px rgba(255, 199, 44, 0.25);
        }

        .card-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 0.5rem;
        }

        .rank-tag {
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            color: var(--cerritos-blue);
            background: #eff6ff;
            padding: 0.15rem 0.4rem;
            border-radius: 3px;
        }

        .theme-title {
            font-size: 1.1rem;
            font-weight: 700;
            margin: 0.2rem 0;
            color: #0f172a;
        }

        .theme-subtitle {
            font-size: 0.75rem;
            color: #64748b;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .theme-desc {
            font-size: 0.82rem;
            color: #334155;
            line-height: 1.4;
            margin-bottom: 1rem;
        }

        /* Progress Bar */
        .progress-container {
            background: #f1f5f9;
            border-radius: 10px;
            height: 8px;
            overflow: hidden;
            margin-bottom: 0.3rem;
        }

        .progress-bar {
            height: 100%;
            background-color: var(--cerritos-blue);
            border-radius: 10px;
            transition: width 0.4s ease;
        }

        .score-text {
            font-size: 0.75rem;
            color: #64748b;
            text-align: right;
            font-weight: 600;
        }

        /* Full Scores Section */
        .all-scores-section {
            background: #ffffff;
            border: 1px solid var(--card-border);
            border-radius: 8px;
            padding: 1.25rem;
            margin-bottom: 1.5rem;
        }

        .all-scores-section h3 {
            margin: 0 0 1rem 0;
            color: var(--cerritos-blue);
            font-size: 1rem;
        }

        .score-row {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 0.6rem;
        }

        .score-row-label {
            width: 110px;
            font-size: 0.8rem;
            font-weight: 600;
            color: #334155;
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
            border: 1px solid var(--card-border);
        }

        .btn {
            padding: 0.6rem 1.2rem;
            font-size: 0.88rem;
            font-weight: 600;
            border-radius: 5px;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-block;
        }

        .btn-secondary {
            background-color: #f1f5f9;
            color: #475569;
            border: 1px solid #cbd5e1;
        }

        .btn-secondary:hover {
            background-color: #e2e8f0;
        }

        .btn-primary {
            background-color: var(--cerritos-blue);
            color: #ffffff;
            border: none;
        }

        .btn-primary:hover {
            background-color: #001d32;
        }
    </style>
</head>
<body>

<header>
    <h1>Cerritos College Career Assessment</h1>
    <span class="step-badge">Assessment Complete</span>
</header>

<div class="main-container">

    <div class="intro-card">
        <h2>Your Holland Code Profile</h2>
        <p>Based on your responses, here are your primary career interest drivers:</p>
        <div class="code-banner">
            <?php foreach ($top_three as $code): ?>
                <span class="code-chip"><?php echo htmlspecialchars($code); ?></span>
            <?php endforeach; ?>
        </div>
    </div>

    <!-- Top 3 Match Cards -->
    <div class="results-grid">
        <?php 
        $rank = 1;
        foreach ($top_three as $code): 
            $meta = $riasec_meta[$code];
            $score = $scores[$code] ?? 0;
            $percentage = min(100, round(($score / $max_score) * 100));
        ?>
            <div class="result-card <?php echo $rank === 1 ? 'rank-1' : ''; ?>">
                <div>
                    <div class="card-top">
                        <span class="rank-tag">Top Match #<?php echo $rank++; ?></span>
                    </div>
                    <div class="theme-title"><?php echo htmlspecialchars($meta['name']); ?></div>
                    <div class="theme-subtitle"><?php echo htmlspecialchars($meta['title']); ?></div>
                    <div class="theme-desc"><?php echo htmlspecialchars($meta['desc']); ?></div>
                </div>

                <div>
                    <div class="progress-container">
                        <div class="progress-bar" style="width: <?php echo $percentage; ?>%;"></div>
                    </div>
                    <div class="score-text">Score: <?php echo $score; ?> / <?php echo $max_score; ?></div>
                </div>
            </div>
        <?php endforeach; ?>
    </div>

    <!-- Full Profile Score Breakdown -->
    <div class="all-scores-section">
        <h3>Full Profile Breakdown</h3>
        <?php foreach ($scores as $code => $score): 
            $meta = $riasec_meta[$code];
            $pct = min(100, round(($score / $max_score) * 100));
        ?>
            <div class="score-row">
                <div class="score-row-label"><?php echo htmlspecialchars($meta['name']); ?> (<?php echo $code; ?>)</div>
                <div class="score-row-bar">
                    <div class="progress-container">
                        <div class="progress-bar" style="width: <?php echo $pct; ?>%;"></div>
                    </div>
                </div>
                <div class="score-text" style="width: 45px; text-align: right;"><?php echo $score; ?> pts</div>
            </div>
        <?php endforeach; ?>
    </div>

    <div class="action-bar">
        <a href="javascript:history.back()" class="btn btn-secondary">&larr; Retake Assessment</a>
        <a href="career_selection.php" class="btn btn-primary">Explore Career Matches &rarr;</a>
    </div>

</div>

</body>
</html>