-- Script: create_db.sql
-- Run this as a MySQL root user (or a user with CREATE DATABASE privilege)

CREATE DATABASE IF NOT EXISTS `absensi_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'absensi_user'@'localhost' IDENTIFIED BY 'change_me';
GRANT ALL PRIVILEGES ON `absensi_db`.* TO 'absensi_user'@'localhost';
FLUSH PRIVILEGES;

-- Optional: create a sample admin user (password hashed using bcrypt expected by backend)
-- INSERT INTO `users` (nama, email, password, role, createdAt, updatedAt) VALUES
-- ('Admin', 'admin@example.com', '$2a$10$e0NRw...hashedpassword...', 'admin', NOW(), NOW());
