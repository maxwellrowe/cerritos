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
        .container {
            max-width: 800px;
            margin: 2.5rem auto;
            background: #ffffff;
            padding: 3rem 2.5rem;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            text-align: center;
        }
        .success-icon {
            font-size: 3.5rem;
            color: #2e7d32;
            margin-bottom: 1rem;
        }
        h2 {
            color: var(--cerritos-blue);
            margin-top: 0;
            margin-bottom: 1rem;
        }
        p.message {
            font-size: 1.1rem;
            color: #555555;
            line-height: 1.6;
            margin-bottom: 2rem;
        }
        .btn {
            display: inline-block;
            background-color: var(--cerritos-blue);
            color: #ffffff;
            border: none;
            padding: 0.85rem 1.75rem;
            font-size: 1rem;
            font-weight: bold;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            transition: background-color 0.2s ease, transform 0.1s ease;
        }
        .btn:hover {
            background-color: #001d32;
        }
    </style>
</head>
<body>

<header>
    <h1>Cerritos College Career Exploration</h1>
</header>

<div class="container">
    <div class="success-icon">&#10003;</div>
    <h2>Submission Received!</h2>
    <p class="message">
        Thank you for submitting your selections. Your response has been securely saved. 
        Your session has been safely closed.
    </p>
    <a href="index.php" class="btn">Start New Assessment</a>
</div>

</body>
</html>