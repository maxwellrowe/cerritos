<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Major & Career Matcher</title>
    <link rel="stylesheet" href="styles.css"> <!-- Include your CSS framework or custom styles -->
</head>
<body>
    <div class="container">
        <h1>Find Your Potential Major</h1>
        
        <!-- Filter Form -->
        <form method="GET" action="index.php" class="filter-form">
            <div class="form-group">
                <label for="credential">Education Requirement:</label>
                <select name="credential" id="credential">
                    <option value="ALL">All Credentials</option>
                    <option value="CERT">Certificate (CERT)</option>
                    <option value="AA">Associate Degree (AA)</option>
                    <option value="AS">Associate Science (AS)</option>
                    <option value="AA-T">Associate Degree for Transfer (AA-T)</option>
                </select>
            </div>

            <div class="form-group">
                <label for="min_salary">Minimum Salary Interest ($):</label>
                <input type="number" name="min_salary" id="min_salary" value="<?php echo htmlspecialchars($minSalary); ?>" step="5000">
            </div>

            <div class="form-group">
                <label for="min_growth">Minimum Job Growth (%):</label>
                <input type="number" name="min_growth" id="min_growth" value="<?php echo htmlspecialchars($minGrowth); ?>" step="0.5">
            </div>

            <button type="submit" class="btn-primary">Filter Majors</button>
        </form>

        <!-- Results Display Grid -->
        <div class="results-grid">
            <?php if (empty($filteredDegrees)): ?>
                <p>No programs match your exact criteria. Try adjusting your salary or growth thresholds.</p>
            <?php else: ?>
                <?php foreach ($filteredDegrees as $program): ?>
                    <div class="program-card">
                        <h3><?php echo htmlspecialchars($program['program_name']); ?></h3>
                        <p class="credential-badge"><strong>Credential:</strong> <?php echo htmlspecialchars($program['credential_category']); ?> (<?php echo htmlspecialchars($program['credential_type']); ?>)</p>
                        <p><strong>Pathway:</strong> <?php echo htmlspecialchars($program['pathway_used']); ?></p>
                        
                        <div class="career-highlights">
                            <p><strong>Top Career Match:</strong> <?php echo htmlspecialchars($program['highest_median_career_match']); ?></p>
                            <p><strong>Highest Growth:</strong> <?php echo htmlspecialchars($program['highest_growth_career_match']); ?></p>
                        </div>
                    </div>
                <?php endforeach; ?>
            <?php endif; ?>
        </div>
    </div>
</body>
</html>