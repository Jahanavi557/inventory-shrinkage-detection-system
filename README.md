\# Inventory Shrinkage Detection System



A web-based inventory monitoring and shrinkage detection system built using \*\*Python, Flask, MySQL, HTML, CSS, JavaScript, and Bootstrap\*\*.



\## Project Overview



This system helps businesses identify unusual inventory losses by comparing expected stock with physically counted stock. It tracks inventory movements, detects discrepancies, generates shrinkage cases, and maintains an audit history.



\## Features



\- Inventory monitoring across multiple locations.

\- Automatic shrinkage detection using stock discrepancies.

\- Risk classification: Critical, High, Medium, and Low.

\- Case management and status tracking.

\- Case audit history and investigation tracking.

\- Inventory movement tracking: receipts, sales, transfers, adjustments, and returns.

\- Low-stock and out-of-stock alerts.

\- Dashboard with estimated losses and case summaries.





\## Application Screenshots



\### 1. Dashboard Overview

!\[Dashboard](static/images/dashboard.png)



\### 2. Summary

!\[Summary](static/images/summary.png)



\### 3. Shrinkage Case Management

!\[Shrinkage Cases](static/images/shrinkage-cases.png)



\### 4. Case Status Tracking

!\[Case Status](static/images/case-status.png)



\### 5. Shrinkage Detection and Audit History

!\[Case Detection and Audit](static/images/case-detection-audit.png)



\### 6. Stock Overview

!\[Stock Overview](static/images/stock-overview.png)



\### 7. Stock Overview Details

!\[Stock Overview Details](static/images/stock-overview-details.png)



\### 8. Low Stock Alerts

!\[Low Stock Alerts](static/images/low-stock-alert.png)



\### 9. Inventory Movements

!\[Inventory Movements](static/images/inventory-movements.png)



\### 10. Inventory Movement Details

!\[Inventory Movement Details](static/images/inventory-movements-details.png)



\### 11. Summary Details

!\[Summary Details](static/images/summary-details.png)





\## Technology Stack



\- \*\*Backend:\*\* Python, Flask

\- \*\*Frontend:\*\* HTML, CSS, JavaScript, Bootstrap

\- \*\*Database:\*\* MySQL

\- \*\*Tools:\*\* VS Code, Git, GitHub



\## Project Structure



```text

inventory-shrinkage-app/

├── database/

│   ├── schema.sql

│   ├── seed\_data.sql

│   └── verification\_queries.sql

├── static/

│   ├── css/

│   ├── images/

│   └── js/

├── templates/

│   └── index.html

├── app.py

├── requirements.txt

├── .gitignore

└── README.md

```



\## Shrinkage Detection Logic



The system calculates expected stock using inventory movement records and compares it with the physical inventory count.



\- Negative variance indicates potential inventory shrinkage.

\- Positive or zero variance does not generate a shrinkage case.

\- Estimated loss is calculated as:



`Estimated Loss = Absolute Stock Variance × Product Unit Cost`



Cases are classified based on estimated loss.



\## Installation and Setup



\### 1. Clone the repository



```bash

git clone https://github.com/Jahanavi557/inventory-shrinkage-detection-system.git

cd inventory-shrinkage-detection-system

```



\### 2. Create a virtual environment



```bash

python -m venv venv

```



\### 3. Activate the environment (Windows PowerShell)



```powershell

.\\venv\\Scripts\\Activate.ps1

```



\### 4. Install dependencies



```bash

pip install -r requirements.txt

```



\### 5. Configure MySQL



\- Create the MySQL database.

\- Configure database credentials in your `.env` file.

\- Review `database/schema.sql` and `database/seed\_data.sql` before executing them.

\- Execute the SQL scripts in the correct order.



\### 6. Run the application



```bash

python app.py

```



Open in your browser:



`http://127.0.0.1:5000/`



\## Database Tables



The database contains tables for:



\- Locations

\- Products

\- Suppliers

\- Roles and Employees

\- Shifts and Promotions

\- Stock Documents and Document Lines

\- Inventory Movements

\- Inventory Counts

\- Shrinkage Cases

\- Case Events



\## Testing



The application has been tested for:



\- Database connectivity

\- Dashboard summary calculations

\- Stock calculations

\- Shrinkage case detection

\- Input validation

\- Duplicate case prevention

\- Case status transitions

\- Audit history persistence

\- Low-stock alerts

\- Inventory movement tracking



\## Future Enhancements



\- User authentication and role-based access.

\- Automated shrinkage alerts.

\- Advanced analytics and visual reports.

\- Email notifications for critical discrepancies.



\## Author



\*\*Jahanavi Tanneeru\*\*



GitHub: \[Jahanavi557](https://github.com/Jahanavi557)

