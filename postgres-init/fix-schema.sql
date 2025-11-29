-- Drop and recreate the votes table with correct schema
DROP TABLE IF EXISTS votes;

CREATE TABLE votes (
    id VARCHAR(50) PRIMARY KEY,
    vote VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
