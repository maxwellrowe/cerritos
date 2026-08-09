<?php
// Prevent browser caching of personal applicant data
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

session_start();
require_once __DIR__ . '/db.php';

$errorMessage = '';

// Handle Form Submission for Page 1
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'step_1') {
    $firstName = trim($_POST['first_name'] ?? '');
    $lastName  = trim($_POST['last_name'] ?? '');
    $email     = trim($_POST['email'] ?? '');
    $currentTime = date('Y-m-d H:i:s');

    if (empty($firstName) || empty($lastName) || empty($email)) {
        $errorMessage = 'Please complete all required fields.';
    } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errorMessage = 'Please provide a valid email address.';
    } else {
        try {
            // Check if applicant already exists in database
            $stmt = $pdo->prepare("SELECT id, attempt_count FROM applicants WHERE email = :email");
            $stmt->execute(['email' => $email]);
            $existing = $stmt->fetch();

            if ($existing) {
                $applicantId  = $existing['id'];
                $attemptCount = (int)$existing['attempt_count'] + 1;

                // Update existing applicant record
                $updateStmt = $pdo->prepare("
                    UPDATE applicants 
                    SET first_name = :first_name, 
                        last_name = :last_name, 
                        attempt_count = :attempt_count, 
                        last_updated = :last_updated 
                    WHERE id = :id
                ");
                $updateStmt->execute([
                    'first_name'    => $firstName,
                    'last_name'     => $lastName,
                    'attempt_count' => $attemptCount,
                    'last_updated'  => $currentTime,
                    'id'            => $applicantId
                ]);
            } else {
                $attemptCount = 1;
                // Insert new applicant record
                $insertStmt = $pdo->prepare("
                    INSERT INTO applicants (first_name, last_name, email, attempt_count, last_updated) 
                    VALUES (:first_name, :last_name, :email, :attempt_count, :last_updated)
                ");
                $insertStmt->execute([
                    'first_name'    => $firstName,
                    'last_name'     => $lastName,
                    'email'         => $email,
                    'attempt_count' => $attemptCount,
                    'last_updated'  => $currentTime
                ]);
                $applicantId = $pdo->lastInsertId();
            }

            // Insert attempt log entry
            $logStmt = $pdo->prepare("
                INSERT INTO applicant_attempts (applicant_id, attempt_number, timestamp) 
                VALUES (:applicant_id, :attempt_number, :timestamp)
            ");
            $logStmt->execute([
                'applicant_id'   => $applicantId,
                'attempt_number' => $attemptCount,
                'timestamp'      => $currentTime
            ]);

            // Save to Session
            $_SESSION['applicant'] = [
                'id'            => $applicantId,
                'first_name'    => $firstName,
                'last_name'     => $lastName,
                'email'         => $email,
                'attempt_count' => $attemptCount,
                'last_updated'  => $currentTime
            ];

            header('Location: lcp.php');
            exit;
        } catch (PDOException $e) {
            $errorMessage = 'Database Error: ' . htmlspecialchars($e->getMessage());
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cerritos College - Career & Major Exploration (Page 1)</title>
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
            max-width: 650px;
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
        .form-group {
            margin-bottom: 1.5rem;
        }
        label {
            display: block;
            font-weight: bold;
            margin-bottom: 0.5rem;
            color: var(--cerritos-blue);
        }
        input[type="text"], input[type="email"] {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
            font-size: 1rem;
        }
        input:focus {
            outline: none;
            border-color: var(--cerritos-blue);
            box-shadow: 0 0 5px rgba(0, 43, 73, 0.3);
        }
        .notice-box {
            background-color: #eef3f8;
            border-left: 4px solid var(--cerritos-gold);
            padding: 1rem;
            margin-bottom: 1.5rem;
            font-size: 0.9rem;
            color: #333;
        }
        .error-box {
            background-color: #f8d7da;
            border-left: 4px solid #dc3545;
            color: #721c24;
            padding: 1rem;
            margin-bottom: 1.5rem;
            border-radius: 4px;
        }
        button {
            background-color: var(--cerritos-blue);
            color: #ffffff;
            border: none;
            padding: 0.75rem 1.5rem;
            font-size: 1rem;
            font-weight: bold;
            border-radius: 4px;
            cursor: pointer;
            width: 100%;
            transition: background-color 0.2s ease;
        }
        button:hover {
            background-color: #001d32;
        }
    </style>
</head>
<body>

<header>
    <h1>Cerritos College Career Exploration</h1>
    <span class="step-indicator">Page 1 of 6</span>
</header>

<div class="container">
    <form method="POST" action="index.php">
        <input type="hidden" name="action" value="step_1">
        
        <h2>Welcome Future Falcon!</h2>
        <p>Let's find the learning and career pathway that aligns with your personal goals and interests.</p>
        
        <?php if (!empty($errorMessage)): ?>
            <div class="error-box">
                <?php echo $errorMessage; ?>
            </div>
        <?php endif; ?>

        <div class="notice-box">
            <strong>Important Note:</strong> Please use the email address you enter below consistently for the rest of your college career. For your privacy and security, this information is not saved in browser cache.
        </div>
        
        <div class="form-group">
            <label for="first_name">First Name</label>
            <input type="text" id="first_name" name="first_name" required value="<?php echo htmlspecialchars($_SESSION['applicant']['first_name'] ?? ''); ?>">
        </div>
        
        <div class="form-group">
            <label for="last_name">Last Name</label>
            <input type="text" id="last_name" name="last_name" required value="<?php echo htmlspecialchars($_SESSION['applicant']['last_name'] ?? ''); ?>">
        </div>
        
        <div class="form-group">
            <label for="email">Email Address</label>
            <input type="email" id="email" name="email" required placeholder="your.email@example.com" value="<?php echo htmlspecialchars($_SESSION['applicant']['email'] ?? ''); ?>">
        </div>
        
        <button type="submit">Next: Select Learning & Career Pathway &rarr;</button>
    </form>
</div>

</body>
</html>