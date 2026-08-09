<?php
// setup.php
require_once __DIR__ . '/db.php';

try {
    // 1. Base applicants table
    $pdo->exec("CREATE TABLE IF NOT EXISTS applicants (
        id INT AUTO_INCREMENT PRIMARY KEY,
        first_name VARCHAR(100) NOT NULL,
        last_name VARCHAR(100) NOT NULL,
        email VARCHAR(150) NOT NULL,
        UNIQUE KEY idx_email (email)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

    // Check and add missing columns to applicants table
    $columns = $pdo->query("SHOW COLUMNS FROM applicants")->fetchAll(PDO::FETCH_COLUMN);
    
    if (!in_array('lcp', $columns)) {
        $pdo->exec("ALTER TABLE applicants ADD COLUMN lcp VARCHAR(255) NULL AFTER email;");
    }
    if (!in_array('attempt_count', $columns)) {
        $pdo->exec("ALTER TABLE applicants ADD COLUMN attempt_count INT DEFAULT 1 AFTER lcp;");
    }
    if (!in_array('selected_major', $columns)) {
        $pdo->exec("ALTER TABLE applicants ADD COLUMN selected_major VARCHAR(255) NULL AFTER attempt_count;");
    }
    if (!in_array('selected_credential_type', $columns)) {
        $pdo->exec("ALTER TABLE applicants ADD COLUMN selected_credential_type VARCHAR(255) NULL AFTER selected_major;");
    }
    if (!in_array('last_updated', $columns)) {
        $pdo->exec("ALTER TABLE applicants ADD COLUMN last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER selected_credential_type;");
    }

    // 2. Base applicant_interests table
    $pdo->exec("CREATE TABLE IF NOT EXISTS applicant_interests (
        email VARCHAR(150) PRIMARY KEY,
        top_three_codes VARCHAR(255) NULL,
        score_data LONGTEXT NULL,
        realistic_score INT DEFAULT 0,
        investigative_score INT DEFAULT 0,
        artistic_score INT DEFAULT 0,
        social_score INT DEFAULT 0,
        enterprising_score INT DEFAULT 0,
        conventional_score INT DEFAULT 0,
        last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        CONSTRAINT fk_interests_email FOREIGN KEY (email) REFERENCES applicants(email) ON DELETE CASCADE ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

    echo "<strong>Database schema updated successfully!</strong>";
} catch (PDOException $e) {
    die("Setup Failed: " . $e->getMessage());
}
?>