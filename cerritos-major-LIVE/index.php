<?php
// Prevent browser caching
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Pragma: no-cache");

require_once __DIR__ . '/app_bootstrap.php';

$error_message = '';

// Handle applicant registration / lookup form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'start_session') {
    require_valid_csrf();
    // Map obfuscated form field names back to clean local variables
    $firstName = trim($_POST['usr_fn_noop'] ?? '');
    $lastName  = trim($_POST['usr_ln_noop'] ?? '');
    $email     = filter_var(trim($_POST['usr_em_noop'] ?? ''), FILTER_VALIDATE_EMAIL);
    $studentId = trim($_POST['usr_id_noop'] ?? '');

    if (!empty($firstName) && !empty($lastName) && $email !== false) {
        
        session_regenerate_id(true);
        $applicantData = [
            'first_name'   => $firstName,
            'last_name'    => $lastName,
            'email'        => $email,
            'student_id'   => $studentId,
            'created_at'   => date('Y-m-d H:i:s'),
            'last_updated' => date('Y-m-d H:i:s')
        ];

        // This prototype is session-only. It intentionally does not claim to restore
        // data from a previous browser session or from the Google Sheet.
        $_SESSION['applicant'] = $applicantData;

        header('Location: lcp.php');
        exit;
    } else {
        $error_message = "Please provide a valid First Name, Last Name, and Email Address to continue.";
    }
}

// Prefill values if session already exists
$applicant = $_SESSION['applicant'] ?? [];
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cerritos College - Career Exploration Intake</title>
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
            max-width: 700px;
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
            line-height: 1.5;
        }
        .error-banner {
            background: #f8d7da;
            color: #721c24;
            padding: 1rem;
            border: 1px solid #f5c6cb;
            border-radius: 4px;
            margin-bottom: 1.5rem;
        }
        .form-group {
            margin-bottom: 1.25rem;
        }
        .form-group label {
            display: block;
            font-weight: bold;
            margin-bottom: 0.4rem;
            color: var(--cerritos-blue);
        }
        .form-group input {
            width: 100%;
            padding: 0.75rem;
            font-size: 1rem;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .form-group input:focus {
            border-color: var(--cerritos-blue);
            outline: none;
            box-shadow: 0 0 4px rgba(0, 43, 73, 0.25);
        }
        .button-group {
            display: flex;
            justify-content: flex-end;
            border-top: 1px solid #eee;
            padding-top: 1.5rem;
            margin-top: 2rem;
        }
        .btn {
            background-color: var(--cerritos-blue);
            color: #ffffff;
            border: none;
            padding: 0.75rem 1.75rem;
            font-size: 1rem;
            font-weight: bold;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.2s ease;
        }
        .btn:hover {
            background-color: #001d32;
        }
    </style>
</head>
<body>

<header>
    <h1>Cerritos College Career Exploration</h1>
    <span class="step-indicator">Welcome</span>
</header>

<div class="container">
    <h2>Student Intake & Start</h2>
    
    <p class="intro-text">
        Welcome! Please enter your information below to begin or continue exploring academic pathways, matching careers, and custom degree options tailored to your goals.
    </p>

    <?php if (!empty($error_message)): ?>
        <div class="error-banner">
            <?php echo htmlspecialchars($error_message); ?>
        </div>
    <?php endif; ?>

    <form method="POST" action="index.php" autocomplete="off">
        <input type="hidden" name="action" value="start_session">
        <?php echo csrf_field(); ?>

        <!-- Hidden bait inputs to trap Chrome autofill -->
        <input type="text" name="fake_name_trap" style="display:none;" tabindex="-1" autocomplete="off">
        <input type="email" name="fake_email_trap" style="display:none;" tabindex="-1" autocomplete="off">

        <div class="form-group">
            <label for="first_name">First Name *</label>
            <input type="text" id="first_name" name="usr_fn_noop" required autocomplete="off" value="<?php echo htmlspecialchars($applicant['first_name'] ?? ''); ?>" placeholder="Enter your first name">
        </div>

        <div class="form-group">
            <label for="last_name">Last Name *</label>
            <input type="text" id="last_name" name="usr_ln_noop" required autocomplete="off" value="<?php echo htmlspecialchars($applicant['last_name'] ?? ''); ?>" placeholder="Enter your last name">
        </div>

        <div class="form-group">
            <label for="email">Email Address *</label>
            <input type="email" id="email" name="usr_em_noop" required autocomplete="off" value="<?php echo htmlspecialchars($applicant['email'] ?? ''); ?>" placeholder="name@example.com">
        </div>

        <div class="form-group">
            <label for="student_id">Student ID (Optional)</label>
            <input type="text" id="student_id" name="usr_id_noop" autocomplete="off" value="<?php echo htmlspecialchars($applicant['student_id'] ?? ''); ?>" placeholder="e.g., 1234567">
        </div>

        <div class="button-group">
            <button type="submit" class="btn">Continue Exploration &rarr;</button>
        </div>
    </form>
</div>

</body>
</html>
