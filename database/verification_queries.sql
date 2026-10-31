
USE inventory_shrinkage_v2;

-- 1. Check all locations
SELECT * FROM locations;

-- 2. Check all products
SELECT * FROM products;

-- 3. Check suppliers
SELECT * FROM suppliers;

-- 4. Check employees and their roles
SELECT
    e.employee_id,
    e.employee_name,
    r.role_name,
    l.location_name
FROM employees e
LEFT JOIN roles r ON e.role_id = r.role_id
LEFT JOIN locations l ON e.location_id = l.location_id;

-- 5. Check stock documents
SELECT * FROM stock_documents;

-- 6. Check inventory movements
SELECT
    im.movement_id,
    p.product_name,
    l.location_name,
    im.movement_type,
    im.quantity_delta,
    im.movement_at
FROM inventory_movements im
JOIN products p ON im.product_id = p.product_id
JOIN locations l ON im.location_id = l.location_id
ORDER BY im.movement_at;

-- 7. Calculate current stock
SELECT
    p.product_name,
    l.location_name,
    COALESCE(SUM(im.quantity_delta), 0) AS current_stock
FROM products p
CROSS JOIN locations l
LEFT JOIN inventory_movements im
    ON im.product_id = p.product_id
    AND im.location_id = l.location_id
GROUP BY p.product_id, p.product_name, l.location_id, l.location_name
ORDER BY p.product_name, l.location_name;

-- 8. Check shrinkage cases
SELECT
    case_id,
    case_number,
    severity,
    case_status,
    expected_quantity,
    counted_quantity,
    variance_quantity,
    estimated_loss
FROM shrinkage_cases
ORDER BY case_id DESC;

-- 9. Check case audit history
SELECT
    ce.case_event_id,
    sc.case_number,
    ce.event_type,
    ce.old_status,
    ce.new_status,
    ce.event_notes,
    ce.event_at
FROM case_events ce
JOIN shrinkage_cases sc ON ce.case_id = sc.case_id
ORDER BY ce.event_at DESC;

-- 10. Check low-stock products
SELECT
    p.product_name,
    l.location_name,
    COALESCE(SUM(im.quantity_delta), 0) AS current_stock,
    p.minimum_stock
FROM products p
CROSS JOIN locations l
LEFT JOIN inventory_movements im
    ON im.product_id = p.product_id
    AND im.location_id = l.location_id
GROUP BY p.product_id, p.product_name, l.location_id,
         l.location_name, p.minimum_stock
HAVING current_stock <= p.minimum_stock
ORDER BY current_stock;
