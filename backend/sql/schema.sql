-- Create database
CREATE DATABASE IF NOT EXISTS flutter_app
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE flutter_app;

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Optional seed data for testing
-- INSERT INTO users (name, email, password_hash)
-- VALUES ('Test User', 'test@example.com', '$2b$10$replace_with_real_hash');
