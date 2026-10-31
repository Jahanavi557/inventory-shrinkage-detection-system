\# Inventory Shrinkage Detection System



A web-based inventory monitoring and shrinkage detection system built using \*\*Python, Flask, MySQL, HTML, CSS, JavaScript, and Bootstrap\*\*.



\## Project Overview



This system helps businesses identify unusual inventory losses by comparing expected stock with physically counted stock. It tracks inventory movements, detects discrepancies, generates shrinkage cases, and maintains an audit history.



The application provides a centralized dashboard to monitor stock levels, investigate shrinkage cases, track inventory movements, and review audit activities across multiple locations.



\## Features



\- \*\*Inventory Monitoring:\*\* Monitor stock across multiple stores and warehouses.

\- \*\*Automatic Shrinkage Detection:\*\* Identify unusual inventory losses by comparing expected stock with physical counts.

\- \*\*Risk Classification:\*\* Classify shrinkage cases as Critical, High, Medium, or Low based on estimated loss.

\- \*\*Case Management:\*\* Create, investigate, update, resolve, close, and reopen shrinkage cases.

\- \*\*Audit History:\*\* Maintain a traceable history of case activities and status changes.

\- \*\*Inventory Movement Tracking:\*\* Track receipts, sales, transfers, adjustments, and returns.

\- \*\*Low-Stock Alerts:\*\* Identify products that have reached or fallen below their minimum stock levels.

\- \*\*Dashboard Analytics:\*\* Display estimated losses, case summaries, stock information, and inventory activity.



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



\### 8. Low-Stock Alerts



!\[Low Stock Alerts](static/images/low-stock-alert.png)



\### 9. Inventory Movements



!\[Inventory Movements](static/images/inventory-movements.png)



\### 10. Inventory Movement Details



!\[Inventory Movement Details](static/images/inventory-movements-details.png)



\### 11. Summary Details



!\[Summary Details](static/images/summary-details.png)



\## Technology Stack



| Category | Technologies |

|---|---|

| Backend | Python, Flask |

| Frontend | HTML5, CSS3, JavaScript, Bootstrap |

| Database | MySQL |

| Tools | VS Code, Git, GitHub |

| API Testing | Postman |



\## Project Structure



```text

inventory-shrinkage-detection-system/

├── database/

│   ├── schema.sql

│   ├── seed\_data.sql

│   └── verification\_queries.sql

├── static/

│   ├── css/

│   │   ├── bootstrap.min.css

│   │   └── style.css

│   ├── images/

│   │   ├── dashboard.png

│   │   ├── summary.png

│   │   ├── shrinkage-cases.png

│   │   ├── case-status.png

│   │   ├── case-detection-audit.png

│   │   ├── stock-overview.png

│   │   ├── stock-overview-details.png

│   │   ├── low-stock-alert.png

│   │   ├── inventory-movements.png

│   │   ├── inventory-movements-details.png

│   │   └── summary-details.png

│   └── js/

│       ├── bootstrap.bundle.min.js

│       └── dashboard.js

├── templates/

│   └── index.html

├── app.py

├── requirements.txt

├── .gitignore

└── README.md

```



\## Shrinkage Detection Logic



The system identifies potential inventory shrinkage by comparing expected stock with the physically counted stock.



\*\*1. Expected Stock Calculation\*\*



Expected stock is calculated using the recorded inventory movements, including receipts, sales, transfers, adjustments, and returns.



\*\*2. Physical Stock Comparison\*\*



The expected stock quantity is compared with the actual quantity entered during a physical inventory count.



\*\*3. Variance Calculation\*\*



`Stock Variance = Counted Quantity - Expected Quantity`



\- Negative variance indicates potential inventory shrinkage.

\- Zero variance indicates that the stock matches the expected quantity.

\- Positive variance indicates excess stock and does not generate a shrinkage case.



\*\*4. Estimated Loss Calculation\*\*



`Estimated Loss = Absolute Stock Variance × Product Unit Cost`



\*\*5. Risk Classification\*\*



Cases are classified according to estimated loss:



| Severity | Estimated Loss |

|---|---:|

| Critical | ₹10,000 and above |

| High | ₹5,000–₹9,999 |

| Medium | ₹1,000–₹4,999 |

| Low | Below ₹1,000 |



\## Case Management and Audit Tracking



The system supports a shrinkage case lifecycle:



\- \*\*Created:\*\* A new shrinkage case is generated.

\- \*\*Investigating:\*\* The case is under investigation.

\- \*\*Resolved:\*\* The discrepancy has been addressed.

\- \*\*Closed:\*\* The case investigation is completed.

\- \*\*Reopened:\*\* A previously closed case can be reopened for further investigation.



Case activities and status changes are recorded in the audit history to support traceability.



\## Installation and Setup



\### Prerequisites



\- Python 3.11 or later

\- MySQL Server

\- Git

\- Visual Studio Code (recommended)



\### 1. Clone the Repository



```bash

git clone https://github.com/Jahanavi557/inventory-shrinkage-detection-system.git

cd inventory-shrinkage-detection-system

```



\### 2. Create a Virtual Environment



```bash

python -m venv venv

```



\### 3. Activate the Virtual Environment



For Windows PowerShell:



```powershell

.\\venv\\Scripts\\Activate.ps1

```



\### 4. Install Dependencies



```bash

pip install -r requirements.txt

```



\### 5. Configure MySQL



\- Start your MySQL server.

\- Create the required database.

\- Configure your database credentials in the `.env` file.

\- Review `database/schema.sql` and `database/seed\_data.sql` before executing them.

\- Execute the SQL scripts in the correct order.



Do not upload your `.env` file or database passwords to GitHub.



\### 6. Run the Application



```bash

python app.py

```



\### 7. Open the Application



Visit the following address in your browser:



`http://127.0.0.1:5000/`



\## Database Tables



The application uses the following database entities:



| Table | Purpose |

|---|---|

| locations | Stores store and warehouse information |

| products | Stores product details and unit costs |

| suppliers | Maintains supplier information |

| roles | Stores employee roles |

| employees | Maintains employee information |

| shifts | Stores shift information |

| promotions | Maintains promotion details |

| stock\_documents | Stores inventory document records |

| stock\_document\_lines | Stores document line items |

| inventory\_movements | Tracks stock movement transactions |

| inventory\_counts | Stores physical stock count records |

| shrinkage\_cases | Stores detected shrinkage cases |

| case\_events | Maintains case activity and audit history |



\## API Endpoints



The application provides API endpoints for dashboard and inventory operations.



| Endpoint | Purpose |

|---|---|

| `/api/test-db` | Check database connectivity |

| `/api/dashboard/summary` | Retrieve dashboard summary |

| `/api/stock` | Retrieve stock information |

| `/api/cases` | Retrieve shrinkage cases |

| `/api/movements` | Retrieve inventory movements |

| `/api/low-stock` | Retrieve low-stock alerts |



\## Testing



The application has been tested for:



\- MySQL database connectivity.

\- Dashboard summary calculations.

\- Expected stock calculations.

\- Shrinkage case detection.

\- Input validation.

\- Duplicate case prevention.

\- Risk classification.

\- Case status transitions.

\- Audit history persistence.

\- Low-stock and out-of-stock alerts.

\- Inventory movement tracking.



\## Future Enhancements



\- User authentication and role-based access control.

\- Automated alerts for critical shrinkage cases.

\- Advanced analytics and visual reports.

\- Email notifications for inventory discrepancies.

\- Exportable inventory and shrinkage reports.



\## Author



\*\*Jahanavi Tanneeru\*\*



\- GitHub: \[Jahanavi557](https://github.com/Jahanavi557)

\- Repository: \[Inventory Shrinkage Detection System](https://github.com/Jahanavi557/inventory-shrinkage-detection-system)

