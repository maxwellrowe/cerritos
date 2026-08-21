<?php
// Prevent browser caching
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

require_once __DIR__ . '/app_bootstrap.php';

// 18 Selected Questions (3 per RIASEC code) in Interleaved / Mixed Order
$questions = [
    ["program_id" => 1,  "code" => "R", "description" => "Build, repair, install, or maintain equipment, vehicles, tools, or facilities."],
    ["program_id" => 6,  "code" => "I", "description" => "Analyze data, evidence, symptoms, or patterns to find an answer."],
    ["program_id" => 11, "code" => "A", "description" => "Create visual art, design, music, writing, film, performance, or media."],
    ["program_id" => 16, "code" => "S", "description" => "Teach, tutor, coach, counsel, mentor, or advise other people."],
    ["program_id" => 21, "code" => "E", "description" => "Lead a team, project, business activity, event, or campaign."],
    ["program_id" => 26, "code" => "C", "description" => "Organize records, schedules, budgets, forms, data, or detailed procedures."],

    ["program_id" => 3,  "code" => "R", "description" => "Use machines, tools, instruments, or technical equipment to solve problems."],
    ["program_id" => 8,  "code" => "I", "description" => "Solve math, science, technology, or logic-based problems."],
    ["program_id" => 12, "code" => "A", "description" => "Express ideas in original, imaginative, or unconventional ways."],
    ["program_id" => 17, "code" => "S", "description" => "Help people improve their health, learning, safety, or well-being."],
    ["program_id" => 22, "code" => "E", "description" => "Persuade, negotiate, sell, advocate, or influence decisions."],
    ["program_id" => 27, "code" => "C", "description" => "Use spreadsheets, databases, reports, or information systems accurately."],

    ["program_id" => 5,  "code" => "R", "description" => "Learn by doing hands-on projects rather than mainly reading or discussing."],
    ["program_id" => 10, "code" => "I", "description" => "Ask questions, compare options, and evaluate evidence before deciding."],
    ["program_id" => 14, "code" => "A", "description" => "Tell stories, perform, edit, produce, or communicate through creative work."],
    ["program_id" => 19, "code" => "S", "description" => "Work as part of a service team that supports students, clients, patients, or communities."],
    ["program_id" => 24, "code" => "E", "description" => "Take initiative in competitive, business, public-facing, or leadership settings."],
    ["program_id" => 29, "code" => "C", "description" => "Keep work orderly, complete, documented, and on time."]
];

// Process form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    require_valid_csrf();
    
    // Tally RIASEC scores (1 to 5 points each)
    $scores = ['R' => 0, 'I' => 0, 'A' => 0, 'S' => 0, 'E' => 0, 'C' => 0];
    foreach ($questions as $q) {
        $id = $q['program_id'];
        $val = (int)($_POST['q_' . $id] ?? 0);
        $scores[$q['code']] += $val;
    }
    
    // Sort scores high to low to calculate top 3 codes
    arsort($scores);
    $top_codes = array_slice(array_keys($scores), 0, 3);
    
    $_SESSION['applicant']['riasec_scores'] = $scores;
    $_SESSION['applicant']['top_three_codes'] = $top_codes;
    
    header('Location: next_step.php');
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cerritos College - Career Interest Assessment</title>
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
            max-width: 920px;
            margin: 1rem auto;
            padding: 0 1rem;
        }

        .intro-box {
            background: #ffffff;
            padding: 0.85rem 1.25rem;
            border-radius: 8px;
            border: 1px solid var(--card-border);
            border-left: 4px solid var(--cerritos-blue);
            margin-bottom: 1rem;
        }

        .intro-box h2 {
            margin: 0 0 0.2rem 0;
            color: var(--cerritos-blue);
            font-size: 1.15rem;
        }

        .intro-box p {
            margin: 0;
            color: #64748b;
            font-size: 0.85rem;
        }

        /* Compact 2-Column Grid Layout */
        .survey-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 0.6rem;
        }

        @media (max-width: 768px) {
            .survey-grid {
                grid-template-columns: 1fr;
            }
        }

        /* Compact Question Card */
        .q-card {
            background: #ffffff;
            border: 1px solid var(--card-border);
            border-radius: 6px;
            padding: 0.75rem 0.85rem;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            gap: 0.5rem;
            transition: border-color 0.15s ease, box-shadow 0.15s ease;
        }

        .q-card:focus-within, .q-card:hover {
            border-color: #cbd5e1;
            box-shadow: 0 2px 5px rgba(0,0,0,0.03);
        }

        .q-header {
            display: flex;
            align-items: center;
        }

        .q-num {
            font-weight: 700;
            color: var(--cerritos-blue);
            font-size: 0.72rem;
            background: #eff6ff;
            padding: 0.1rem 0.45rem;
            border-radius: 3px;
        }

        .q-text {
            font-size: 0.84rem;
            line-height: 1.35;
            color: #334155;
            font-weight: 500;
            margin: 0.1rem 0;
            min-height: 2.3em;
        }

        /* 5-Point Likert Radio Button Group */
        .options-group {
            display: flex;
            gap: 0.25rem;
        }

        .option-btn {
            flex: 1;
            position: relative;
        }

        .option-btn input {
            position: absolute;
            opacity: 0;
            width: 0;
            height: 0;
        }

        .option-label {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 0.35rem 0.1rem;
            font-size: 0.65rem;
            font-weight: 600;
            background: #f8fafc;
            border: 1px solid #cbd5e1;
            border-radius: 4px;
            color: #475569;
            cursor: pointer;
            user-select: none;
            transition: all 0.15s ease;
            text-align: center;
            line-height: 1.1;
            height: 100%;
            box-sizing: border-box;
        }

        .option-btn input:checked + .option-label {
            background-color: var(--cerritos-blue);
            color: #ffffff;
            border-color: var(--cerritos-blue);
            box-shadow: 0 1px 3px rgba(0,0,0,0.12);
        }

        .option-btn:hover .option-label {
            border-color: var(--cerritos-blue);
            color: var(--cerritos-blue);
        }

        .option-btn input:checked:hover + .option-label {
            color: #ffffff;
        }

        .submit-bar {
            position: sticky;
            bottom: 0;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(4px);
            border-top: 1px solid var(--card-border);
            padding: 0.75rem 1rem;
            margin-top: 1.25rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 -4px 10px rgba(0,0,0,0.05);
            border-radius: 6px;
        }

        .btn-submit {
            background-color: var(--cerritos-blue);
            color: #ffffff;
            border: none;
            padding: 0.6rem 1.5rem;
            font-size: 0.9rem;
            font-weight: 600;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.2s ease;
        }

        .btn-submit:hover {
            background-color: #001d32;
        }
    </style>
</head>
<body>

<header>
    <h1>Cerritos College Career Assessment</h1>
    <span class="step-badge">Interest Survey</span>
</header>

<div class="main-container">
    
    <div class="intro-box">
        <h2>Career Interest Inventory</h2>
        <p>Rate how much you would enjoy each task to help match your interests to academic majors.</p>
    </div>

    <form method="POST" action="">
        <?php echo csrf_field(); ?>
        
        <div class="survey-grid">
            <?php 
            $display_num = 1;
            foreach ($questions as $q): 
                $id = $q['program_id'];
                $desc = htmlspecialchars($q['description']);
            ?>
                <div class="q-card">
                    <div class="q-header">
                        <span class="q-num">Question <?php echo $display_num++; ?> of 18</span>
                    </div>

                    <div class="q-text"><?php echo $desc; ?></div>

                    <div class="options-group">
                        <label class="option-btn" title="Strongly Disagree">
                            <input type="radio" name="q_<?php echo $id; ?>" value="1" required>
                            <span class="option-label">Strongly<br>Disagree</span>
                        </label>
                        <label class="option-btn" title="Disagree">
                            <input type="radio" name="q_<?php echo $id; ?>" value="2">
                            <span class="option-label"><br>Disagree</span>
                        </label>
                        <label class="option-btn" title="Neutral">
                            <input type="radio" name="q_<?php echo $id; ?>" value="3">
                            <span class="option-label"><br>Neutral</span>
                        </label>
                        <label class="option-btn" title="Agree">
                            <input type="radio" name="q_<?php echo $id; ?>" value="4">
                            <span class="option-label"><br>Agree</span>
                        </label>
                        <label class="option-btn" title="Strongly Agree">
                            <input type="radio" name="q_<?php echo $id; ?>" value="5">
                            <span class="option-label">Strongly<br>Agree</span>
                        </label>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>

        <div class="submit-bar">
            <span style="font-size: 0.8rem; color: #64748b;">18 of 18 questions required</span>
            <button type="submit" class="btn-submit">Continue to Results &rarr;</button>
        </div>
    </form>

</div>

</body>
</html>