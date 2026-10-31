USE inventory_shrinkage_v2;

-- 1. Locations
INSERT INTO locations
(location_code, location_name, location_type, address)
VALUES
('HYD-MS', 'Hyderabad Main Store', 'STORE', 'Hyderabad, Telangana'),
('HYD-WH', 'Hyderabad Warehouse', 'WAREHOUSE', 'Hyderabad, Telangana'),
('VJA-ST', 'Vijayawada Store', 'STORE', 'Vijayawada, Andhra Pradesh');

-- 2. Suppliers
INSERT INTO suppliers
(supplier_code, supplier_name, contact_person, phone, email, address)
VALUES
('SUP-001', 'ABC Distributors', 'Ramesh', '9876543210', 'abc@example.com', 'Hyderabad'),
('SUP-002', 'Global Traders', 'Suresh', '9876543211', 'global@example.com', 'Vijayawada');

-- 3. Roles
INSERT INTO roles (role_name, description)
VALUES
('Admin', 'System administrator'),
('Manager', 'Store manager'),
('Inventory Executive', 'Handles inventory operations');

-- 4. Employees
INSERT INTO employees
(employee_code, employee_name, email, phone, role_id, location_id)
VALUES
('EMP-001', 'Sneha Sharma', 'sneha@example.com', '9876500001', 2, 1),
('EMP-002', 'Rahul Kumar', 'rahul@example.com', '9876500002', 3, 2),
('EMP-003', 'Priya Reddy', 'priya@example.com', '9876500003', 1, 1),
('EMP-004', 'Arjun Rao', 'arjun@example.com', '9876500004', 3, 3);

-- 5. Products
INSERT INTO products
(sku, product_name, category, unit_cost, minimum_stock)
VALUES
('PRD-001', 'Wireless Mouse', 'Electronics', 500.00, 20),
('PRD-002', 'USB Keyboard', 'Electronics', 750.00, 20),
('PRD-003', 'Bluetooth Headphones', 'Electronics', 1500.00, 15),
('PRD-004', 'Rice 5kg Bag', 'Grocery', 350.00, 25),
('PRD-005', 'Cooking Oil 1L', 'Grocery', 180.00, 20),
('PRD-006', 'Water Bottle', 'Accessories', 250.00, 20),
('PRD-007', 'Storage Box', 'Home', 400.00, 15);

-- 6. Shifts
INSERT INTO shifts
(shift_name, start_time, end_time, location_id)
VALUES
('Morning Shift', '06:00:00', '14:00:00', 1),
('Evening Shift', '14:00:00', '22:00:00', 1),
('Warehouse Shift', '08:00:00', '17:00:00', 2);

-- 7. Promotions
INSERT INTO promotions
(promotion_code, promotion_name, discount_percentage, start_date, end_date)
VALUES
('PROMO-001', 'Festival Sale', 10.00, '2026-10-01', '2026-11-30'),
('PROMO-002', 'Special Discount', 5.00, '2026-10-01', '2026-12-31');

-- 8. Stock Documents
INSERT INTO stock_documents
(
    document_number,
    document_type,
    source_location_id,
    destination_location_id,
    supplier_id,
    promotion_id,
    document_status,
    document_date,
    created_by
)
VALUES
('REC-001', 'RECEIPT', NULL, 1, 1, NULL, 'POSTED', '2026-10-01 09:00:00', 1),
('SALE-001', 'SALE', 1, NULL, NULL, 1, 'POSTED', '2026-10-02 11:00:00', 1),
('TRF-001', 'TRANSFER', 1, 2, NULL, NULL, 'POSTED', '2026-10-03 10:00:00', 2),
('ADJ-001', 'ADJUSTMENT', 1, NULL, NULL, NULL, 'POSTED', '2026-10-04 12:00:00', 1),
('RET-001', 'CUSTOMER_RETURN', NULL, 1, NULL, NULL, 'POSTED', '2026-10-05 14:00:00', 1),
('SRET-001', 'SUPPLIER_RETURN', 1, NULL, 1, NULL, 'POSTED', '2026-10-06 15:00:00', 1);


-- 9. Stock Document Lines
INSERT INTO stock_document_lines
(document_id, product_id, quantity, unit_cost, line_total)
VALUES
-- Receipt
(1, 1, 100, 500.00, 50000.00),
(1, 2, 80, 750.00, 60000.00),
(1, 3, 60, 1500.00, 90000.00),
(1, 4, 100, 350.00, 35000.00),
(1, 5, 100, 180.00, 18000.00),
(1, 6, 80, 250.00, 20000.00),
(1, 7, 70, 400.00, 28000.00),

-- Sale
(2, 1, 20, 500.00, 10000.00),
(2, 2, 10, 750.00, 7500.00),

-- Transfer
(3, 2, 15, 750.00, 11250.00),
(3, 1, 20, 500.00, 10000.00),

-- Adjustment
(4, 3, 5, 1500.00, 7500.00),

-- Customer return
(5, 1, 2, 500.00, 1000.00),

-- Supplier return
(6, 5, 10, 180.00, 1800.00);

-- 10. Inventory Movements
INSERT INTO inventory_movements
(
    document_line_id,
    product_id,
    location_id,
    movement_type,
    quantity_delta,
    movement_at,
    created_by
)
VALUES
-- Receipt movements
(1, 1, 1, 'RECEIPT', 100, '2026-10-01 09:00:00', 1),
(2, 2, 1, 'RECEIPT', 80, '2026-10-01 09:00:00', 1),
(3, 3, 1, 'RECEIPT', 60, '2026-10-01 09:00:00', 1),
(4, 4, 1, 'RECEIPT', 100, '2026-10-01 09:00:00', 1),
(5, 5, 1, 'RECEIPT', 100, '2026-10-01 09:00:00', 1),
(6, 6, 1, 'RECEIPT', 80, '2026-10-01 09:00:00', 1),
(7, 7, 1, 'RECEIPT', 70, '2026-10-01 09:00:00', 1),

-- Sale movements
(8, 1, 1, 'SALE', -20, '2026-10-02 11:00:00', 1),
(9, 2, 1, 'SALE', -10, '2026-10-02 11:00:00', 1),

-- Transfer movements
(10, 2, 1, 'TRANSFER_OUT', -15, '2026-10-03 10:00:00', 2),
(10, 2, 2, 'TRANSFER_IN', 15, '2026-10-03 10:00:00', 2),
(11, 1, 1, 'TRANSFER_OUT', -20, '2026-10-03 10:00:00', 2),
(11, 1, 2, 'TRANSFER_IN', 20, '2026-10-03 10:00:00', 2),

-- Adjustment
(12, 3, 1, 'ADJUSTMENT', -5, '2026-10-04 12:00:00', 1),

-- Customer return
(13, 1, 1, 'CUSTOMER_RETURN', 2, '2026-10-05 14:00:00', 1),

-- Supplier return
(14, 5, 1, 'SUPPLIER_RETURN', -10, '2026-10-06 15:00:00', 1);

-- 11. Inventory Counts
INSERT INTO inventory_counts
(
    count_number,
    location_id,
    counted_by,
    count_status,
    count_date,
    completed_at
)
VALUES
('CNT-001', 1, 1, 'COMPLETED', '2026-10-07 09:00:00', '2026-10-07 12:00:00'),
('CNT-002', 2, 2, 'COMPLETED', '2026-10-08 09:00:00', '2026-10-08 12:00:00');

-- 12. Initial Shrinkage Case
INSERT INTO shrinkage_cases
(
    case_number,
    count_id,
    product_id,
    location_id,
    expected_quantity,
    counted_quantity,
    variance_quantity,
    estimated_loss,
    severity,
    case_status,
    assigned_to
)
VALUES
(
    'SHR-001',
    1,
    1,
    1,
    80,
    70,
    -10,
    5000.00,
    'MEDIUM',
    'OPEN',
    1
);


-- 13. Case Events
INSERT INTO case_events
(
    case_id,
    event_type,
    event_by,
    event_notes,
    old_status,
    new_status
)
VALUES
(
    1,
    'CREATED',
    1,
    'Initial shrinkage case created from inventory count.',
    NULL,
    'OPEN'
);


