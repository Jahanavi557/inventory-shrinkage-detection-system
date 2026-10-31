
CREATE DATABASE IF NOT EXISTS inventory_shrinkage_v2;
USE inventory_shrinkage_v2;

-- 1. Locations
CREATE TABLE locations (
    location_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    location_code VARCHAR(30) NOT NULL UNIQUE,
    location_name VARCHAR(120) NOT NULL,
    location_type ENUM('STORE', 'WAREHOUSE', 'DISTRIBUTION_CENTER') NOT NULL,
    address VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Products
CREATE TABLE products (
    product_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(50) NOT NULL UNIQUE,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    unit_cost DECIMAL(12,2) NOT NULL DEFAULT 0,
    minimum_stock INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 3. Suppliers
CREATE TABLE suppliers (
    supplier_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    supplier_code VARCHAR(30) NOT NULL UNIQUE,
    supplier_name VARCHAR(150) NOT NULL,
    contact_person VARCHAR(120),
    phone VARCHAR(20),
    email VARCHAR(120),
    address VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 4. Roles
CREATE TABLE roles (
    role_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(80) NOT NULL UNIQUE,
    description VARCHAR(255)
) ENGINE=InnoDB;

-- 5. Employees
CREATE TABLE employees (
    employee_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_code VARCHAR(30) NOT NULL UNIQUE,
    employee_name VARCHAR(120) NOT NULL,
    email VARCHAR(120) UNIQUE,
    phone VARCHAR(20),
    role_id BIGINT UNSIGNED NOT NULL,
    location_id BIGINT UNSIGNED,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_employees_role
        FOREIGN KEY (role_id) REFERENCES roles(role_id),
    CONSTRAINT fk_employees_location
        FOREIGN KEY (location_id) REFERENCES locations(location_id)
) ENGINE=InnoDB;

-- 6. Shifts
CREATE TABLE shifts (
    shift_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    shift_name VARCHAR(80) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    location_id BIGINT UNSIGNED NOT NULL,
    CONSTRAINT fk_shifts_location
        FOREIGN KEY (location_id) REFERENCES locations(location_id)
) ENGINE=InnoDB;

-- 7. Promotions
CREATE TABLE promotions (
    promotion_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    promotion_code VARCHAR(40) NOT NULL UNIQUE,
    promotion_name VARCHAR(120) NOT NULL,
    discount_percentage DECIMAL(5,2) DEFAULT 0,
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

-- 8. Stock Documents
CREATE TABLE stock_documents (
    document_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    document_number VARCHAR(50) NOT NULL UNIQUE,
    document_type ENUM(
        'RECEIPT', 'SALE', 'TRANSFER', 'ADJUSTMENT',
        'CUSTOMER_RETURN', 'SUPPLIER_RETURN'
    ) NOT NULL,
    source_location_id BIGINT UNSIGNED,
    destination_location_id BIGINT UNSIGNED,
    supplier_id BIGINT UNSIGNED,
    promotion_id BIGINT UNSIGNED,
    document_status ENUM('DRAFT', 'POSTED', 'CANCELLED') NOT NULL DEFAULT 'DRAFT',
    document_date DATETIME NOT NULL,
    created_by BIGINT UNSIGNED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_documents_source_location
        FOREIGN KEY (source_location_id) REFERENCES locations(location_id),
    CONSTRAINT fk_documents_destination_location
        FOREIGN KEY (destination_location_id) REFERENCES locations(location_id),
    CONSTRAINT fk_documents_supplier
        FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    CONSTRAINT fk_documents_promotion
        FOREIGN KEY (promotion_id) REFERENCES promotions(promotion_id),
    CONSTRAINT fk_documents_employee
        FOREIGN KEY (created_by) REFERENCES employees(employee_id)
) ENGINE=InnoDB;

-- 9. Stock Document Lines
CREATE TABLE stock_document_lines (
    document_line_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    document_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity DECIMAL(12,2) NOT NULL,
    unit_cost DECIMAL(12,2) NOT NULL DEFAULT 0,
    line_total DECIMAL(14,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_document_lines_document
        FOREIGN KEY (document_id) REFERENCES stock_documents(document_id),
    CONSTRAINT fk_document_lines_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

-- 10. Inventory Movements
CREATE TABLE inventory_movements (
    movement_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    document_line_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    location_id BIGINT UNSIGNED NOT NULL,
    movement_type ENUM(
        'RECEIPT', 'SALE', 'TRANSFER_IN', 'TRANSFER_OUT',
        'ADJUSTMENT', 'CUSTOMER_RETURN', 'SUPPLIER_RETURN'
    ) NOT NULL,
    quantity_delta DECIMAL(12,2) NOT NULL,
    movement_at DATETIME NOT NULL,
    created_by BIGINT UNSIGNED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_movements_document_line
        FOREIGN KEY (document_line_id) REFERENCES stock_document_lines(document_line_id),
    CONSTRAINT fk_movements_product
        FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT fk_movements_location
        FOREIGN KEY (location_id) REFERENCES locations(location_id),
    CONSTRAINT fk_movements_employee
        FOREIGN KEY (created_by) REFERENCES employees(employee_id),
    CONSTRAINT uq_document_movement_location
        UNIQUE (document_line_id, movement_type, location_id)
) ENGINE=InnoDB;

-- 11. Inventory Counts
CREATE TABLE inventory_counts (
    count_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    count_number VARCHAR(50) NOT NULL UNIQUE,
    location_id BIGINT UNSIGNED NOT NULL,
    counted_by BIGINT UNSIGNED,
    count_status ENUM('DRAFT', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'DRAFT',
    count_date DATETIME NOT NULL,
    completed_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_counts_location
        FOREIGN KEY (location_id) REFERENCES locations(location_id),
    CONSTRAINT fk_counts_employee
        FOREIGN KEY (counted_by) REFERENCES employees(employee_id)
) ENGINE=InnoDB;

-- 12. Shrinkage Cases
CREATE TABLE shrinkage_cases (
    case_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    case_number VARCHAR(50) NOT NULL UNIQUE,
    count_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    location_id BIGINT UNSIGNED NOT NULL,
    expected_quantity DECIMAL(12,2) NOT NULL,
    counted_quantity DECIMAL(12,2) NOT NULL,
    variance_quantity DECIMAL(12,2) NOT NULL,
    estimated_loss DECIMAL(14,2) NOT NULL DEFAULT 0,
    severity ENUM('CRITICAL', 'HIGH', 'MEDIUM', 'LOW') NOT NULL,
    case_status ENUM(
        'OPEN', 'INVESTIGATING', 'PENDING_RECOUNT',
        'RESOLVED', 'CLOSED', 'FALSE_POSITIVE'
    ) NOT NULL DEFAULT 'OPEN',
    assigned_to BIGINT UNSIGNED,
    resolved_by BIGINT UNSIGNED,
    resolved_at DATETIME,
    resolution_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_cases_count
        FOREIGN KEY (count_id) REFERENCES inventory_counts(count_id),
    CONSTRAINT fk_cases_product
        FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT fk_cases_location
        FOREIGN KEY (location_id) REFERENCES locations(location_id),
    CONSTRAINT fk_cases_assigned_employee
        FOREIGN KEY (assigned_to) REFERENCES employees(employee_id),
    CONSTRAINT fk_cases_resolved_employee
        FOREIGN KEY (resolved_by) REFERENCES employees(employee_id)
) ENGINE=InnoDB;

-- 13. Case Events
CREATE TABLE case_events (
    case_event_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    case_id BIGINT UNSIGNED NOT NULL,
    event_type ENUM(
        'CREATED', 'ASSIGNED', 'NOTE', 'RECOUNT_REQUESTED',
        'RECOUNT_RECORDED', 'RESOLVED', 'CLOSED', 'REOPENED'
    ) NOT NULL,
    event_by BIGINT UNSIGNED,
    event_notes TEXT,
    old_status VARCHAR(30),
    new_status VARCHAR(30),
    event_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_case_events_case
        FOREIGN KEY (case_id) REFERENCES shrinkage_cases(case_id),
    CONSTRAINT fk_case_events_employee
        FOREIGN KEY (event_by) REFERENCES employees(employee_id)
) ENGINE=InnoDB;
