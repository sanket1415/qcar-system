-- Create Database
CREATE DATABASE IF NOT EXISTS qcar_db;
USE qcar_db;

-- Admins Table
CREATE TABLE IF NOT EXISTS admins (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Cars Table
CREATE TABLE IF NOT EXISTS cars (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    qr_id VARCHAR(50) UNIQUE NOT NULL,
    unit_no VARCHAR(100) NOT NULL,
    owner_name VARCHAR(255) NOT NULL,
    car_number VARCHAR(100) UNIQUE NOT NULL,
    type ENUM('Tenant', 'Owner') NOT NULL,
    qr_color VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_qr_id (qr_id),
    INDEX idx_car_number (car_number)
);

-- Insert default admin (username: admin, password: admin123)
INSERT INTO admins (username, password) VALUES ('admin', 'admin123')
ON DUPLICATE KEY UPDATE username = username;

-- Sample data for testing (optional)
INSERT INTO cars (qr_id, unit_no, owner_name, car_number, type, qr_color) VALUES
('abc12345', 'A-101', 'John Doe', 'MH-01-AB-1234', 'Owner', '#00008B'),
('def67890', 'B-205', 'Jane Smith', 'MH-02-CD-5678', 'Tenant', '#800000')
ON DUPLICATE KEY UPDATE qr_id = qr_id;
