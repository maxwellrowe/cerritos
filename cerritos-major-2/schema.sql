CREATE TABLE IF NOT EXISTS applicants (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    birth_date DATE,
    lcp VARCHAR(100),
    top_priority VARCHAR(255),
    riasec_codes TEXT, -- JSON-encoded or comma-separated
    selected_careers TEXT, -- JSON-encoded array
    last_updated DATETIME NOT NULL,
    CONSTRAINT unique_applicant UNIQUE (first_name, last_name, email)
);