<?php
// Prevent browser caching
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

require_once __DIR__ . '/app_bootstrap.php';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cerritos College - Thank You</title>
    <style>
        :root {
            /* WCAG AAA/AA Compliant Colors */
            --cerritos-blue: #002b49;
            --cerritos-gold: #735000;
            --cerritos-dark: #0f172a;
            --cerritos-light: #f8fafc;
            --text-muted: #334155;
            --success-green: #166534;
            --focus-outline: #005fcc;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background-color: var(--cerritos-light);
            color: var(--cerritos-dark);
            margin: 0;
            padding: 0;
            font-size: 16px;
            line-height: 1.6;
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

        .container {
            max-width: 800px;
            margin: 3rem auto;
            background: #ffffff;
            padding: 3rem 2.5rem;
            border-radius: 8px;
            border: 2px solid #cbd5e1;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            text-align: center;
        }

        .success-icon-wrapper {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 80px;
            height: 80px;
            background-color: #dcfce7;
            border: 2px solid var(--success-green);
            border-radius: 50%;
            margin-bottom: 1.25rem;
        }

        .success-icon {
            width: 48px;
            height: 48px;
            fill: var(--success-green);
        }

        h2 {
            color: var(--cerritos-blue);
            margin-top: 0;
            margin-bottom: 1rem;
            font-size: 1.75rem;
        }

        p.message {
            font-size: 1.1rem;
            color: var(--text-muted);
            line-height: 1.6;
            margin-bottom: 2rem;
        }

        .btn {
            display: inline-block;
            background-color: var(--cerritos-blue);
            color: #ffffff;
            border: 2px solid var(--cerritos-blue);
            padding: 0.85rem 1.75rem;
            font-size: 1rem;
            font-weight: 800;
            border-radius: 6px;
            cursor: pointer;
            text-decoration: none;
            transition: background-color 0.2s ease, border-color 0.2s ease;
        }

        .btn:hover {
            background-color: #001d32;
            border-color: #001d32;
        }

        .btn:focus {
            outline: 3px solid var(--focus-outline) !important;
            outline-offset: 3px !important;
        }

        .disclaimer {
            margin-top: 2.5rem;
            padding-top: 1.5rem;
            border-top: 1px solid #cbd5e1;
            font-size: 0.9rem;
            color: var(--text-muted);
            text-align: left;
        }

        .disclaimer p {
            margin-bottom: 0.75rem;
        }

        .disclaimer p:last-child {
            margin-bottom: 0;
        }

        /* PRINT STYLES */
        @media print {
            header {
                display: none !important;
            }
            .container {
                border: none !important;
                box-shadow: none !important;
                margin: 0 !important;
                padding: 0 !important;
            }
            .btn {
                display: none !important;
            }
        }
    </style>
</head>
<body>

<header role="banner">
    <h1>Cerritos College Career Exploration</h1>
</header>

<main class="container" id="main-content">
    <div class="success-icon-wrapper" aria-hidden="true">
        <svg class="success-icon" viewBox="0 0 24 24">
            <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
        </svg>
    </div>
    <h2>Submission Received!</h2>
    <p class="message">
        Thank you for submitting your selections. Your response has been securely saved. 
        Your session has been safely closed.
    </p>
    <a href="index.php" class="btn">Start New Assessment</a>

<footer class="disclaimer">
    <p>This tool is a starting point for exploration. The options presented are not a complete list of possible careers or majors. Many additional career and educational options may align with your interests, skills, values, and goals, which may also evolve as you gain new experiences and explore different fields.</p>
    <p>We encourage you to explore additional career resources, including <a href="https://www.onetonline.org/" target="_blank" rel="noopener noreferrer">O*NET OnLine</a> and the <a href="https://www.bls.gov/ooh/" target="_blank" rel="noopener noreferrer">Occupational Outlook Handbook</a>, which offer detailed information about occupations, including job duties, skills, education and training, work environments, pay, and more.</p>
</footer></main>

</body>
</html>