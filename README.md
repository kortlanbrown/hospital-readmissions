# Healthcare Readmission SQL Analysis
SQL project to identify high-risk ER utilization by flagging repeat emergency room visits within 30- and 90-day windows.

## 🔍 Problem
Healthcare teams need to identify potentially avoidable readmissions by detecting patients with repeated ER visits in short time periods.

## 🧠 Approach
- Loaded patient encounter and ER visit data
- Cleaned and standardized key fields (patient ID, visit date, encounter type)
- Built logic to flag:
  - 2+ ER visits in 30 days
  - 3+ ER visits in 90 days
- Generated summary outputs for care management use

## 📊 Results
- Created flags to easily identify high-risk participants
- Produced summary tables for reporting and analysis
- Enabled proactive intervention & performance monitoring

## 🛠️ Tools
SQL (PostgreSQL)

## 📁 Files in This Repo
- `sql/create_tables.sql` → builds database structure
- `sql/insert_data.sql` → loads sample data
- `sql/analysis_queries.sql` → flag and summary logic
- `/data` → sample dataset (no PHI)
- `/outputs` → example outputs / screenshots
