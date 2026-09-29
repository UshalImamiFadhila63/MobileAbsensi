-- Script: create_db.sql
-- Run as MySQL root or a user allowed to create databases/users, alter users, and grant privileges.

CREATE DATABASE IF NOT EXISTS `db_absensi` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'absensi_user'@'localhost' IDENTIFIED BY 'change_me';
ALTER USER 'absensi_user'@'localhost' IDENTIFIED BY 'change_me';
GRANT ALL PRIVILEGES ON `db_absensi`.* TO 'absensi_user'@'localhost';
FLUSH PRIVILEGES;

-- Optional: create a sample admin user (password hashed using bcrypt expected by backend)
-- INSERT INTO `users` (nama, email, password, role, createdAt, updatedAt) VALUES
-- ('Admin', 'admin@example.com', '$2a$10$e0NRw...hashedpassword...', 'admin', NOW(), NOW());
