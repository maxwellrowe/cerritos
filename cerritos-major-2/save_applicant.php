<?php
require_once 'db.php';
session_start();

if (!isset($_SESSION['applicant'])) {
    header('Location: index.php');
    exit;
}

$applicant = $_SESSION['applicant'];
$firstName = trim($applicant['first_name'] ?? '');
$lastName  = trim($applicant['last_name'] ?? '');
$email     = trim($applicant['email'] ?? '');
$lcp       = trim($applicant['lcp'] ?? '');
$priority  = trim($applicant['goals_and_priorities']['top_priority'] ?? '');
$careers   = json_encode($applicant['selected_careers'] ?? []);
$riasec    = json_encode($applicant['top_three_codes'] ?? []);
$now       = date('Y-m-d H:i:s');

$pdo = getDbConnection();

// Secure UPSERT (Insert or Update on matching unique identity)
$sql = "INSERT INTO applicants (first_name, last_name, email, lcp, top_priority, riasec_codes, selected_careers, last_updated)
        VALUES (:first_name, :last_name, :email, :lcp, :top_priority, :riasec, :careers, :last_updated)
        ON CONFLICT(first_name, last_name, email) DO UPDATE SET
            lcp = EXCLUDED.lcp,
            top_priority = EXCLUDED.top_priority,
            riasec_codes = EXCLUDED.riasec_codes,
            selected_careers = EXCLUDED.selected_careers,
            last_updated = EXCLUDED.last_updated";

$stmt = $pdo->prepare($sql);
$stmt->execute([
    ':first_name'   => $firstName,
    ':last_name'    => $lastName,
    ':email'        => $email,
    ':lcp'          => $lcp,
    ':top_priority' => $priority,
    ':riasec'       => $riasec,
    ':careers'      => $careers,
    ':last_updated' => $now
]);

$_SESSION['applicant']['last_updated'] = $now;