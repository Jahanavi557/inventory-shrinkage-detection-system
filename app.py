from flask import Flask, jsonify, render_template, request
from flask_mysqldb import MySQL
from dotenv import load_dotenv
import os
import uuid

load_dotenv()

app = Flask(__name__)

# MySQL configuration
app.config["MYSQL_HOST"] = os.getenv("MYSQL_HOST")
app.config["MYSQL_USER"] = os.getenv("MYSQL_USER")
app.config["MYSQL_PASSWORD"] = os.getenv("MYSQL_PASSWORD")
app.config["MYSQL_DB"] = os.getenv("MYSQL_DB")
app.config["MYSQL_CURSORCLASS"] = "DictCursor"

mysql = MySQL(app)


@app.route("/")
def home():
    return render_template("index.html")


@app.route("/api/test-db")
def test_db():
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT DATABASE() AS database_name")
    result = cursor.fetchone()
    cursor.close()

    return jsonify({
        "message": "Database connected successfully",
        "database": result["database_name"]
    })




@app.route("/api/dashboard/summary")
def dashboard_summary():
    cursor = mysql.connection.cursor()

    query = """
        SELECT
            COUNT(*) AS total_cases,
            COALESCE(SUM(estimated_loss), 0) AS total_estimated_loss,

            SUM(CASE WHEN severity = 'CRITICAL' THEN 1 ELSE 0 END) AS critical_cases,
            SUM(CASE WHEN severity = 'HIGH' THEN 1 ELSE 0 END) AS high_cases,
            SUM(CASE WHEN severity = 'MEDIUM' THEN 1 ELSE 0 END) AS medium_cases,
            SUM(CASE WHEN severity = 'LOW' THEN 1 ELSE 0 END) AS low_cases,

            SUM(CASE WHEN case_status = 'OPEN' THEN 1 ELSE 0 END) AS open_cases,
            SUM(CASE WHEN case_status = 'INVESTIGATING' THEN 1 ELSE 0 END) AS investigating_cases,
            SUM(CASE WHEN case_status = 'PENDING_RECOUNT' THEN 1 ELSE 0 END) AS pending_recount_cases,
            SUM(CASE WHEN case_status = 'RESOLVED' THEN 1 ELSE 0 END) AS resolved_cases,
            SUM(CASE WHEN case_status = 'CLOSED' THEN 1 ELSE 0 END) AS closed_cases,
            SUM(CASE WHEN case_status = 'FALSE_POSITIVE' THEN 1 ELSE 0 END) AS false_positive_cases

        FROM shrinkage_cases
    """

    cursor.execute(query)
    result = cursor.fetchone()
    cursor.close()

    result["high_risk_cases"] = (
        result["critical_cases"] + result["high_cases"]
    )

    return jsonify(result)


@app.route("/api/stock")
def stock_dashboard():
    cursor = mysql.connection.cursor()

    query = """
        SELECT
            l.location_name,
            p.sku,
            p.product_name,
            COALESCE(SUM(m.quantity_delta), 0) AS current_stock,
            p.unit_cost,
            COALESCE(SUM(m.quantity_delta), 0) * p.unit_cost AS stock_value
        FROM locations l
        CROSS JOIN products p
        LEFT JOIN inventory_movements m
            ON m.location_id = l.location_id
            AND m.product_id = p.product_id
        WHERE l.is_active = TRUE
          AND p.is_active = TRUE
        GROUP BY
            l.location_id,
            l.location_name,
            p.product_id,
            p.sku,
            p.product_name,
            p.unit_cost
        ORDER BY l.location_name, p.product_name
    """

    cursor.execute(query)
    result = cursor.fetchall()
    cursor.close()

    return jsonify(result)

@app.route("/api/counts")
def get_inventory_counts():
    cursor = mysql.connection.cursor()

    cursor.execute("""
        SELECT count_id, count_number, status
        FROM inventory_counts
        WHERE status IN ('COMPLETED', 'APPROVED')
        ORDER BY count_id DESC
    """)

    counts = cursor.fetchall()
    cursor.close()

    return jsonify(counts)

@app.route("/api/products")
def get_products():
    cursor = mysql.connection.cursor()

    cursor.execute("""
        SELECT product_id, product_name
        FROM products
        WHERE is_active = TRUE
        ORDER BY product_name
    """)

    products = cursor.fetchall()
    cursor.close()

    return jsonify(products)

@app.route("/api/cases")
def get_shrinkage_cases():
    cursor = mysql.connection.cursor()

    query = """
        SELECT
            sc.case_id,
            sc.case_number,
            p.sku,
            p.product_name,
            l.location_name,
            sc.expected_quantity,
            sc.counted_quantity,
            sc.variance_quantity,
            sc.estimated_loss,
            sc.severity,
            sc.case_status,
            e.employee_name AS assigned_employee,
            sc.detected_at
        FROM shrinkage_cases sc
        JOIN products p
            ON sc.product_id = p.product_id
        JOIN inventory_counts ic
            ON sc.count_id = ic.count_id
        JOIN locations l
            ON ic.location_id = l.location_id
        LEFT JOIN employees e
            ON sc.assigned_to = e.employee_id
        ORDER BY sc.detected_at DESC
    """

    cursor.execute(query)
    result = cursor.fetchall()
    cursor.close()

    return jsonify(result)

@app.route("/api/movements")
def get_inventory_movements():
    cursor = mysql.connection.cursor()

    query = """
        SELECT
            m.movement_id,
            d.document_number,
            m.movement_type,
            p.sku,
            p.product_name,
            l.location_name,
            m.quantity_delta,
            m.unit_cost,
            m.occurred_at
        FROM inventory_movements m
        JOIN stock_document_lines dl
            ON m.document_line_id = dl.document_line_id
        JOIN stock_documents d
            ON dl.document_id = d.document_id
        JOIN products p
            ON m.product_id = p.product_id
        JOIN locations l
            ON m.location_id = l.location_id
        ORDER BY m.occurred_at DESC, m.movement_id DESC
    """

    cursor.execute(query)
    result = cursor.fetchall()
    cursor.close()

    return jsonify(result)

@app.route("/api/low-stock")
def low_stock():
    cursor = mysql.connection.cursor()

    query = """
        SELECT
            l.location_name,
            p.sku,
            p.product_name,
            COALESCE(SUM(m.quantity_delta), 0) AS current_stock,
            20 AS minimum_stock,
            CASE
                WHEN COALESCE(SUM(m.quantity_delta), 0) <= 0
                    THEN 'OUT OF STOCK'
                ELSE 'LOW STOCK'
            END AS stock_status
        FROM locations l
        CROSS JOIN products p
        LEFT JOIN inventory_movements m
            ON m.location_id = l.location_id
            AND m.product_id = p.product_id
        WHERE l.is_active = TRUE
          AND p.is_active = TRUE
        GROUP BY
            l.location_id,
            l.location_name,
            p.product_id,
            p.sku,
            p.product_name
        HAVING COALESCE(SUM(m.quantity_delta), 0) < 20
        ORDER BY current_stock ASC
    """

    cursor.execute(query)
    result = cursor.fetchall()
    cursor.close()

    return jsonify(result)


@app.route("/api/detect-shrinkage", methods=["POST"])
def detect_shrinkage():
    data = request.get_json(silent=True) or {}

    count_id = data.get("count_id")
    product_id = data.get("product_id")
    counted_quantity = data.get("counted_quantity")

    if count_id is None or product_id is None or counted_quantity is None:
        return jsonify({
            "error": "count_id, product_id and counted_quantity are required"
        }), 400

    cursor = mysql.connection.cursor()

    try:
        counted_quantity = float(counted_quantity)

        if counted_quantity < 0:
            return jsonify({"error": "Counted quantity cannot be negative"}), 400

        # 1. Validate inventory count
        cursor.execute("""
            SELECT location_id, status, completed_at
            FROM inventory_counts
            WHERE count_id = %s
        """, (count_id,))

        count = cursor.fetchone()

        if not count:
            return jsonify({"error": "Inventory count not found"}), 404

        if count["status"] not in ("COMPLETED", "APPROVED"):
            return jsonify({
                "error": "Inventory count must be completed or approved"
            }), 400

        if not count["completed_at"]:
            return jsonify({
                "error": "Inventory count completion time is missing"
            }), 400

        # 2. Validate product
        cursor.execute("""
            SELECT unit_cost
            FROM products
            WHERE product_id = %s AND is_active = TRUE
        """, (product_id,))

        product = cursor.fetchone()

        if not product:
            return jsonify({"error": "Active product not found"}), 404

        # 3. Calculate expected stock as of count completion
        cursor.execute("""
            SELECT COALESCE(SUM(quantity_delta), 0) AS expected_quantity
            FROM inventory_movements
            WHERE location_id = %s
              AND product_id = %s
              AND occurred_at <= %s
        """, (
            count["location_id"],
            product_id,
            count["completed_at"]
        ))

        expected = float(cursor.fetchone()["expected_quantity"])
        variance = counted_quantity - expected

        if variance >= 0:
            return jsonify({
                "message": "No shrinkage detected",
                "expected_quantity": expected,
                "counted_quantity": counted_quantity,
                "variance": variance
            })

        # 4. Calculate estimated loss and severity
        estimated_loss = abs(variance) * float(product["unit_cost"])

        if estimated_loss >= 10000:
            severity = "CRITICAL"
        elif estimated_loss >= 5000:
            severity = "HIGH"
        elif estimated_loss >= 1000:
            severity = "MEDIUM"
        else:
            severity = "LOW"

        # 5. Check for an existing case
        cursor.execute("""
            SELECT case_id
            FROM shrinkage_cases
            WHERE count_id = %s AND product_id = %s
        """, (count_id, product_id))

        if cursor.fetchone():
            return jsonify({
                "error": "A shrinkage case already exists for this count and product"
            }), 409

        # 6. Create unique case number
        case_number = "SHR-" + uuid.uuid4().hex[:10].upper()

        cursor.execute("""
            INSERT INTO shrinkage_cases (
                case_number,
                count_id,
                product_id,
                severity,
                case_status,
                expected_quantity,
                counted_quantity,
                estimated_loss,
                detection_rule,
                assigned_to
            )
            VALUES (
                %s, %s, %s, %s, 'OPEN',
                %s, %s, %s,
                'NEGATIVE_STOCK_VARIANCE', 4
            )
        """, (
            case_number,
            count_id,
            product_id,
            severity,
            expected,
            counted_quantity,
            estimated_loss
        ))

        case_id = cursor.lastrowid

        # 7. Record audit event
        cursor.execute("""
            INSERT INTO case_events (
                case_id,
                event_type,
                event_by,
                event_notes,
                old_status,
                new_status
            )
            VALUES (%s, 'CREATED', 4, %s, NULL, 'OPEN')
        """, (
            case_id,
            f"Shrinkage detected. Expected: {expected}, "
            f"Counted: {counted_quantity}, "
            f"Estimated loss: Rs.{estimated_loss}"
        ))

        mysql.connection.commit()

        return jsonify({
            "message": "Shrinkage detected and case created successfully",
            "case_id": case_id,
            "case_number": case_number,
            "expected_quantity": expected,
            "counted_quantity": counted_quantity,
            "variance": variance,
            "estimated_loss": estimated_loss,
            "severity": severity
        }), 201

    except Exception as error:
        mysql.connection.rollback()
        return jsonify({"error": str(error)}), 500

    finally:
        cursor.close()



@app.route("/api/cases/<int:case_id>/status", methods=["PUT"])
def update_case_status(case_id):
    data = request.get_json(silent=True) or {}

    new_status = data.get("status")
    notes = (data.get("notes") or "").strip()

    try:
        event_by = int(data.get("event_by", 4))
    except (TypeError, ValueError):
        return jsonify({"error": "Invalid employee ID"}), 400

    valid_statuses = [
        "OPEN",
        "INVESTIGATING",
        "PENDING_RECOUNT",
        "RESOLVED",
        "CLOSED",
        "FALSE_POSITIVE"
    ]

    if new_status not in valid_statuses:
        return jsonify({"error": "Invalid case status"}), 400

    event_types = {
    "OPEN": "REOPENED",
    "INVESTIGATING": "NOTE",
    "PENDING_RECOUNT": "RECOUNT_REQUESTED",
    "RESOLVED": "RESOLVED",
    "CLOSED": "CLOSED",
    "FALSE_POSITIVE": "NOTE"
}
    cursor = mysql.connection.cursor()

    try:
        # Start transaction
        cursor.execute("START TRANSACTION")

        # Check employee
        cursor.execute("""
            SELECT employee_id
            FROM employees
            WHERE employee_id = %s
        """, (event_by,))

        employee = cursor.fetchone()

        if not employee:
            mysql.connection.rollback()
            return jsonify({"error": "Employee not found"}), 404

        # Lock the case while updating it
        cursor.execute("""
            SELECT case_status
            FROM shrinkage_cases
            WHERE case_id = %s
            FOR UPDATE
        """, (case_id,))

        case = cursor.fetchone()

        if not case:
            mysql.connection.rollback()
            return jsonify({"error": "Case not found"}), 404

        old_status = case["case_status"]

        if old_status == new_status:
            mysql.connection.rollback()
            return jsonify({
                "error": "Case is already in this status"
            }), 400

        terminal_statuses = (
            "RESOLVED",
            "CLOSED",
            "FALSE_POSITIVE"
        )

        if new_status in terminal_statuses:
            cursor.execute("""
                UPDATE shrinkage_cases
                SET case_status = %s,
                    resolution_notes = %s,
                    resolved_at = NOW(),
                    resolved_by = %s
                WHERE case_id = %s
            """, (new_status, notes, event_by, case_id))

        else:
            cursor.execute("""
                UPDATE shrinkage_cases
                SET case_status = %s,
                    resolution_notes = NULL,
                    resolved_at = NULL,
                    resolved_by = NULL
                WHERE case_id = %s
            """, (new_status, case_id))

        # Insert audit event
        cursor.execute("""
            INSERT INTO case_events (
                case_id,
                event_type,
                event_by,
                event_notes,
                old_status,
                new_status
            )
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (
            case_id,
            event_types[new_status],
            event_by,
            notes,
            old_status,
            new_status
        ))

        # Commit both changes together
        mysql.connection.commit()

        return jsonify({
            "message": "Case status updated successfully",
            "case_id": case_id,
            "old_status": old_status,
            "new_status": new_status,
            "event_by": event_by,
            "notes": notes
        })

    except Exception as error:
        mysql.connection.rollback()
        return jsonify({"error": str(error)}), 500

    finally:
        cursor.close()


@app.route("/api/cases/<int:case_id>/events")
def get_case_events(case_id):
    cursor = mysql.connection.cursor()

    query = """
        SELECT
            ce.case_event_id,
            ce.event_type,
            ce.event_notes,
            ce.old_status,
            ce.new_status,
            ce.event_at,
            e.employee_name AS performed_by
        FROM case_events ce
        LEFT JOIN employees e
            ON ce.event_by = e.employee_id
        WHERE ce.case_id = %s
        ORDER BY ce.event_at DESC, ce.case_event_id DESC
    """

    cursor.execute(query, (case_id,))
    result = cursor.fetchall()
    cursor.close()

    return jsonify(result)




if __name__ == "__main__":
    app.run(debug=True)