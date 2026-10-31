
// ==========================================
// LOAD INVENTORY COUNTS
// ==========================================

async function loadCounts() {
    const response = await fetch("/api/counts");

    if (!response.ok) {
        throw new Error("Failed to load inventory counts");
    }

    const counts = await response.json();

    const dropdown = document.getElementById("countId");

    dropdown.innerHTML = '<option value="">Select Inventory Count</option>';

    counts.forEach(count => {
        dropdown.innerHTML += `
            <option value="${count.count_id}">
                ${escapeHtml(count.count_number)}
            </option>
        `;
    });
}


// ==========================================
// LOAD PRODUCTS
// ==========================================

async function loadProducts() {
    const response = await fetch("/api/products");

    if (!response.ok) {
        throw new Error("Failed to load products");
    }

    const products = await response.json();

    const dropdown = document.getElementById("productId");

    dropdown.innerHTML = '<option value="">Select Product</option>';

    products.forEach(product => {
        dropdown.innerHTML += `
            <option value="${product.product_id}">
                ${escapeHtml(product.product_name)}
            </option>
        `;
    });
}


// ==========================================
// DATE FORMATTING
// ==========================================

function formatDate(value) {
    if (!value) return "-";

    const dateString = String(value).trim();
    let date;

    if (/^\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}/.test(dateString)) {
        date = new Date(dateString.replace(" ", "T"));
    } else {
        const parsedDate = new Date(dateString);

        if (isNaN(parsedDate.getTime())) {
            return "-";
        }

        date = new Date(
            parsedDate.getUTCFullYear(),
            parsedDate.getUTCMonth(),
            parsedDate.getUTCDate(),
            parsedDate.getUTCHours(),
            parsedDate.getUTCMinutes(),
            parsedDate.getUTCSeconds()
        );
    }

    if (isNaN(date.getTime())) return "-";

    return date.toLocaleString("en-IN");
}


// ==========================================
// LOAD DASHBOARD SUMMARY
// ==========================================

async function loadDashboard() {
    try {
        const response = await fetch("/api/dashboard/summary");
        const data = await response.json();

        if (!response.ok) {
            throw new Error(data.error || "Failed to load dashboard");
        }

        document.getElementById("totalCases").textContent =
            data.total_cases ?? 0;

        document.getElementById("totalLoss").textContent =
            "₹" + Number(data.total_estimated_loss || 0)
                .toLocaleString("en-IN");

        document.getElementById("highCases").textContent =
    data.high_risk_cases ?? 0;

        document.getElementById("openCases").textContent =
            data.open_cases ?? 0;

        const totalCases = Number(data.total_cases || 0);
        const resolvedCases = Number(data.resolved_cases || 0);

        document.getElementById("resolvedCases").textContent =
            resolvedCases;

        const resolutionRate = totalCases > 0
            ? ((resolvedCases / totalCases) * 100).toFixed(1)
            : "0.0";

        document.getElementById("resolutionRate").textContent =
            resolutionRate + "%";

        // Case Severity Breakdown

        document.getElementById("criticalBreakdown").textContent =
            data.critical_cases ?? 0;

        document.getElementById("highBreakdown").textContent =
            data.high_cases ?? 0;

        document.getElementById("mediumBreakdown").textContent =
            data.medium_cases ?? 0;

        document.getElementById("lowBreakdown").textContent =
            data.low_cases ?? 0;

        // Case Status Breakdown

        document.getElementById("openBreakdown").textContent =
            data.open_cases ?? 0;

        document.getElementById("investigatingBreakdown").textContent =
            data.investigating_cases ?? 0;

        document.getElementById("pendingRecountBreakdown").textContent =
            data.pending_recount_cases ?? 0;

        document.getElementById("resolvedBreakdown").textContent =
            data.resolved_cases ?? 0;

        document.getElementById("closedBreakdown").textContent =
            data.closed_cases ?? 0;

        document.getElementById("falsePositiveBreakdown").textContent =
            data.false_positive_cases ?? 0;

    } catch (error) {
        console.error("Dashboard loading error:", error);
    }
}


// ==========================================
// LOAD SHRINKAGE CASES
// ==========================================

async function loadCases() {
    const response = await fetch("/api/cases");

    if (!response.ok) {
        throw new Error("Failed to load shrinkage cases");
    }

    const data = await response.json();

    let html = `
        <div class="table-responsive">
        <table class="table table-bordered table-hover">
        <thead>
            <tr>
                <th>Case Number</th>
                <th>Product</th>
                <th>Location</th>
                <th>Expected</th>
                <th>Counted</th>
                <th>Variance</th>
                <th>Loss</th>
                <th>Severity</th>
                <th>Status</th>
                <th>Update Status</th>
            </tr>
        </thead>
        <tbody>
    `;

    data.forEach(item => {
        html += `
            <tr>
                <td>${escapeHtml(item.case_number)}</td>
                <td>${escapeHtml(item.product_name)}</td>
                <td>${escapeHtml(item.location_name)}</td>
                <td>${item.expected_quantity}</td>
                <td>${item.counted_quantity}</td>
                <td>${item.variance_quantity}</td>
                <td>₹${Number(item.estimated_loss).toLocaleString("en-IN")}</td>
                <td>${escapeHtml(item.severity)}</td>
                <td>${escapeHtml(item.case_status)}</td>

                <td>
                    <select
                        id="status-${item.case_id}"
                        class="form-select"
                    >
                        <option value="OPEN"
                            ${item.case_status === "OPEN" ? "selected" : ""}>
                            OPEN
                        </option>

                        <option value="INVESTIGATING"
                            ${item.case_status === "INVESTIGATING" ? "selected" : ""}>
                            INVESTIGATING
                        </option>

                        <option value="PENDING_RECOUNT"
                            ${item.case_status === "PENDING_RECOUNT" ? "selected" : ""}>
                            PENDING RECOUNT
                        </option>

                        <option value="RESOLVED"
                            ${item.case_status === "RESOLVED" ? "selected" : ""}>
                            RESOLVED
                        </option>

                        <option value="CLOSED"
                            ${item.case_status === "CLOSED" ? "selected" : ""}>
                            CLOSED
                        </option>

                        <option value="FALSE_POSITIVE"
                            ${item.case_status === "FALSE_POSITIVE" ? "selected" : ""}>
                            FALSE POSITIVE
                        </option>
                    </select>

                    <button
                        type="button"
                        class="btn btn-sm btn-primary mt-2"
                        data-case-id="${item.case_id}">
                        Update
                    </button>
                </td>
            </tr>
        `;
    });

    html += `
        </tbody>
        </table>
        </div>
    `;

    document.getElementById("casesTable").innerHTML = html;
}


// ==========================================
// LOAD STOCK OVERVIEW
// ==========================================

async function loadStock() {
    const response = await fetch("/api/stock");

    if (!response.ok) {
        throw new Error("Failed to load stock");
    }

    const data = await response.json();

    let html = `
        <div class="table-responsive">
        <table class="table table-bordered table-hover">
        <thead>
            <tr>
                <th>Location</th>
                <th>SKU</th>
                <th>Product</th>
                <th>Stock</th>
                <th>Unit Cost</th>
                <th>Stock Value</th>
            </tr>
        </thead>
        <tbody>
    `;

    data.forEach(item => {
        html += `
            <tr>
                <td>${escapeHtml(item.location_name)}</td>
                <td>${escapeHtml(item.sku)}</td>
                <td>${escapeHtml(item.product_name)}</td>
                <td>${item.current_stock}</td>
                <td>₹${item.unit_cost}</td>
                <td>₹${item.stock_value}</td>
            </tr>
        `;
    });

    html += "</tbody></table></div>";

    document.getElementById("stockTable").innerHTML = html;
}


// ==========================================
// LOAD LOW STOCK ALERTS
// ==========================================

async function loadLowStock() {
    const response = await fetch("/api/low-stock");

    if (!response.ok) {
        throw new Error("Failed to load low stock alerts");
    }

    const data = await response.json();

    let html = `
        <div class="table-responsive">
        <table class="table table-bordered table-hover">
        <thead>
            <tr>
                <th>Location</th>
                <th>SKU</th>
                <th>Product</th>
                <th>Current Stock</th>
                <th>Minimum Stock</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
    `;

    data.forEach(item => {
        html += `
            <tr>
                <td>${escapeHtml(item.location_name)}</td>
                <td>${escapeHtml(item.sku)}</td>
                <td>${escapeHtml(item.product_name)}</td>
                <td>${item.current_stock}</td>
                <td>${item.minimum_stock}</td>
                <td>${escapeHtml(item.stock_status)}</td>
            </tr>
        `;
    });

    html += "</tbody></table></div>";

    document.getElementById("lowStockTable").innerHTML = html;
}


// ==========================================
// LOAD INVENTORY MOVEMENTS
// ==========================================

async function loadMovements() {
    const response = await fetch("/api/movements");

    if (!response.ok) {
        throw new Error("Failed to load inventory movements");
    }

    const data = await response.json();

    let html = `
        <div class="table-responsive">
        <table class="table table-bordered table-hover">
        <thead>
            <tr>
                <th>Document</th>
                <th>Movement</th>
                <th>Product</th>
                <th>Location</th>
                <th>Quantity Change</th>
                <th>Date</th>
            </tr>
        </thead>
        <tbody>
    `;

    data.forEach(item => {
        const formattedDate = formatDate(item.occurred_at);

        html += `
            <tr>
                <td>${escapeHtml(item.document_number)}</td>
                <td>${escapeHtml(item.movement_type)}</td>
                <td>${escapeHtml(item.product_name)}</td>
                <td>${escapeHtml(item.location_name)}</td>
                <td>${Number(item.quantity_delta).toFixed(2)}</td>
                <td>${escapeHtml(formattedDate)}</td>
            </tr>
        `;
    });

    html += "</tbody></table></div>";

    document.getElementById("movementTable").innerHTML = html;
}


// ==========================================
// LOAD CASE AUDIT HISTORY
// ==========================================

async function loadCaseEvents() {
    const caseId = document.getElementById("auditCaseId").value;
    const container = document.getElementById("caseEventsTable");

    if (!caseId) {
        container.textContent = "Select a case to view audit history.";
        return;
    }

    try {
        const response = await fetch(`/api/cases/${caseId}/events`);

        if (!response.ok) {
            throw new Error("Failed to load audit history");
        }

        const events = await response.json();

        if (events.length === 0) {
            container.textContent = "No audit events found.";
            return;
        }

        let html = `
            <div class="table-responsive">
            <table class="table table-bordered table-hover">
                <thead>
                    <tr>
                        <th>Event</th>
                        <th>Performed By</th>
                        <th>Old Status</th>
                        <th>New Status</th>
                        <th>Notes</th>
                        <th>Date</th>
                    </tr>
                </thead>
                <tbody>
        `;

        events.forEach(event => {
            const formattedDate = formatDate(event.event_at);

            html += `
                <tr>
                    <td>${escapeHtml(event.event_type)}</td>
                    <td>${escapeHtml(event.performed_by || "N/A")}</td>
                    <td>${escapeHtml(event.old_status || "-")}</td>
                    <td>${escapeHtml(event.new_status || "-")}</td>
                    <td>${escapeHtml(event.event_notes || "-")}</td>
                    <td>${escapeHtml(formattedDate)}</td>
                </tr>
            `;
        });

        html += "</tbody></table></div>";

        container.innerHTML = html;

    } catch (error) {
        container.textContent = "Unable to load audit history.";
        console.error("Audit history error:", error);
    }
}


// ==========================================
// LOAD CASES INTO AUDIT DROPDOWN
// ==========================================

async function loadAuditCases() {
    const response = await fetch("/api/cases");

    if (!response.ok) {
        throw new Error("Failed to load audit cases");
    }

    const cases = await response.json();

    const dropdown = document.getElementById("auditCaseId");

    const previousValue = dropdown.value;

    dropdown.innerHTML = '<option value="">Select Case</option>';

    cases.forEach(item => {
        dropdown.innerHTML += `
            <option value="${item.case_id}">
                ${escapeHtml(item.case_number)}
            </option>
        `;
    });

    if (cases.length > 0) {
        const caseStillExists = cases.some(
            item => String(item.case_id) === previousValue
        );

        dropdown.value = caseStillExists
            ? previousValue
            : cases[0].case_id;

        await loadCaseEvents();
    } else {
        document.getElementById("caseEventsTable").textContent =
            "No cases available.";
    }
}


// ==========================================
// DETECT SHRINKAGE
// ==========================================

async function detectShrinkage(event) {
    event.preventDefault();

    const countId = document.getElementById("countId").value;
    const productId = document.getElementById("productId").value;
    const countedQuantity =
        document.getElementById("countedQuantity").value;

    const resultDiv = document.getElementById("detectionResult");

    if (!countId || !productId || countedQuantity === "") {
        resultDiv.innerHTML = `
            <div class="alert alert-warning">
                Please fill in all required fields.
            </div>
        `;
        return;
    }

    try {
        const response = await fetch("/api/detect-shrinkage", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                count_id: Number(countId),
                product_id: Number(productId),
                counted_quantity: Number(countedQuantity)
            })
        });

        const data = await response.json();

        if (!response.ok) {
            resultDiv.innerHTML = `
                <div class="alert alert-danger">
                    ${escapeHtml(data.error || "Something went wrong")}
                </div>
            `;
            return;
        }

        resultDiv.innerHTML = `
            <div class="alert alert-success">
                ${escapeHtml(data.message)}
                <br>Expected Quantity: ${data.expected_quantity}
                <br>Counted Quantity: ${data.counted_quantity}
                <br>Variance: ${data.variance}
                ${data.case_id
                    ? `<br>Case ID: ${data.case_id}`
                    : ""}
                ${data.severity
                    ? `<br>Severity: ${escapeHtml(data.severity)}`
                    : ""}
            </div>
        `;

        if (response.status === 201) {
            await loadAllData();
            await loadAuditCases();

            document.getElementById("auditCaseId").value =
                data.case_id;

            await loadCaseEvents();
        }

    } catch (error) {
        console.error("Shrinkage detection error:", error);

        resultDiv.innerHTML = `
            <div class="alert alert-danger">
                Unable to connect to the server.
            </div>
        `;
    }
}


// ==========================================
// ESCAPE HTML
// ==========================================

function escapeHtml(value) {
    return String(value ?? "").replace(/[&<>"']/g, character => ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#39;"
    })[character]);
}


// ==========================================
// UPDATE SHRINKAGE CASE STATUS
// ==========================================

async function updateCaseStatus(caseId) {
    const statusDropdown =
        document.getElementById(`status-${caseId}`);

    if (!statusDropdown) {
        return;
    }

    const newStatus = statusDropdown.value;

    const notes = prompt("Enter a note about this status update:");

    if (notes === null) {
        return;
    }

    try {
        const response = await fetch(`/api/cases/${caseId}/status`, {
            method: "PUT",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                status: newStatus,
                event_by: 4,
                notes: notes
            })
        });

        const result = await response.json();

        if (!response.ok) {
            alert(result.error || "Unable to update case status.");
            return;
        }

        alert("Case status updated successfully!");

        await loadCases();
        await loadDashboard();
        await loadAuditCases();

    } catch (error) {
        console.error("Status update error:", error);

        alert("Something went wrong while updating the status.");
    }
}


// ==========================================
// LOAD ALL DASHBOARD DATA
// ==========================================

async function loadAllData() {
    await Promise.all([
        loadDashboard(),
        loadCases(),
        loadStock(),
        loadLowStock(),
        loadMovements()
    ]);
}


// ==========================================
// INITIALIZE DASHBOARD
// ==========================================

async function initializeDashboard() {
    try {
        await Promise.all([
            loadCounts(),
            loadProducts(),
            loadAuditCases()
        ]);

        await loadAllData();

    } catch (error) {
        console.error("Dashboard initialization error:", error);
    }
}


// ==========================================
// EVENT LISTENERS
// ==========================================

document.addEventListener("DOMContentLoaded", () => {

    // Detect Shrinkage Form
    const detectForm =
        document.getElementById("detectShrinkageForm");

    detectForm.addEventListener("submit", detectShrinkage);


    // Audit History Dropdown
    const auditDropdown =
        document.getElementById("auditCaseId");

    auditDropdown.addEventListener("change", loadCaseEvents);


    // Update Case Status Buttons
    const casesContainer =
        document.getElementById("casesTable");

    casesContainer.addEventListener("click", event => {

        const button = event.target.closest(
            "button[data-case-id]"
        );

        if (!button) {
            return;
        }

        const caseId = Number(button.dataset.caseId);

        updateCaseStatus(caseId);
    });


    // Initialize Dashboard
    initializeDashboard();

});


