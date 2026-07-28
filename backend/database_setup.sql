-- Run this script in phpMyAdmin or via MySQL command line to create the database and tables.

CREATE DATABASE IF NOT EXISTS crm_db;
USE crm_db;

-- 1. Users (Employees/Staff)
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin', 'sales', 'sourcing', 'executive') NOT NULL,
    phone VARCHAR(20),
    active BOOLEAN DEFAULT TRUE,
    profile_image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Clients (Leads -> Active)
CREATE TABLE IF NOT EXISTS clients (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    company_name VARCHAR(150),
    email VARCHAR(150),
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    status ENUM('lead', 'followUp', 'converted', 'inactive') DEFAULT 'lead',
    loyalty_points INT DEFAULT 0,
    assigned_sales_id VARCHAR(50),
    profile_image_url VARCHAR(255), -- Uploaded during contract/doc collection
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (assigned_sales_id) REFERENCES users(id) ON DELETE SET NULL
);

-- 3. Candidates (Staff sourced by Sourcing Team)
CREATE TABLE IF NOT EXISTS candidates (
    id VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    category VARCHAR(100),
    expected_salary DECIMAL(10, 2),
    status ENUM('newlyAdded', 'verificationPending', 'medicalPending', 'readyToPlace', 'placed', 'blacklisted') DEFAULT 'newlyAdded',
    is_police_verified BOOLEAN DEFAULT FALSE,
    is_aadhaar_verified BOOLEAN DEFAULT FALSE,
    is_medical_cleared BOOLEAN DEFAULT FALSE,
    sourced_by_id VARCHAR(50),
    profile_image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (sourced_by_id) REFERENCES users(id) ON DELETE SET NULL
);

-- 4. Contracts
CREATE TABLE IF NOT EXISTS contracts (
    id VARCHAR(50) PRIMARY KEY,
    client_id VARCHAR(50) NOT NULL,
    candidate_id VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    guarantee_end_date DATE NOT NULL,
    contract_end_date DATE NOT NULL,
    status ENUM('active', 'expired', 'rePlaced', 'terminated') DEFAULT 'active',
    total_fee DECIMAL(10, 2) NOT NULL,
    amount_paid DECIMAL(10, 2) DEFAULT 0,
    replacements_used INT DEFAULT 0,
    is_renewal BOOLEAN DEFAULT FALSE,
    created_by VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- 5. Executive Tasks
CREATE TABLE IF NOT EXISTS executive_tasks (
    id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    type ENUM('candidateDrop', 'paymentCollection', 'documentPickup', 'clientVisit') NOT NULL,
    status ENUM('pending', 'inProgress', 'completed', 'failed') DEFAULT 'pending',
    assigned_executive_id VARCHAR(50),
    contract_id VARCHAR(50),
    due_date TIMESTAMP NOT NULL,
    completed_date TIMESTAMP NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (assigned_executive_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE CASCADE
);

-- 6. Replacement Requests
CREATE TABLE IF NOT EXISTS replacement_requests (
    id VARCHAR(50) PRIMARY KEY,
    contract_id VARCHAR(50) NOT NULL,
    reason TEXT NOT NULL,
    status ENUM('pending', 'inProgress', 'resolved') DEFAULT 'pending',
    is_escalated_to_sourcing BOOLEAN DEFAULT FALSE,
    required_criteria TEXT,
    new_candidate_id VARCHAR(50),
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_date TIMESTAMP NULL,
    created_by VARCHAR(50),
    FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE CASCADE,
    FOREIGN KEY (new_candidate_id) REFERENCES candidates(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Note: In a real app, suggested candidates would be in a join table.
CREATE TABLE IF NOT EXISTS replacement_suggestions (
    request_id VARCHAR(50) NOT NULL,
    candidate_id VARCHAR(50) NOT NULL,
    PRIMARY KEY (request_id, candidate_id),
    FOREIGN KEY (request_id) REFERENCES replacement_requests(id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE
);

-- 7. Audit Logs
CREATE TABLE IF NOT EXISTS audit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_type VARCHAR(50) NOT NULL,
    entity_id VARCHAR(50) NOT NULL,
    action VARCHAR(50) NOT NULL,
    description TEXT,
    performed_by VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (performed_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Insert a default admin user (password is 'admin123' hashed with bcrypt)
-- You can generate new hashes using tools or bcrypt directly.
INSERT INTO users (id, name, email, password_hash, role) 
VALUES ('U_ADMIN_001', 'System Admin', 'admin@example.com', '$2b$10$EPbT2.iW.R4w3S5u5Z.Mme/P6Zg8CqJ.gI0jY0v9Q3lV6X2e2z2iK', 'admin')
ON DUPLICATE KEY UPDATE id=id;
