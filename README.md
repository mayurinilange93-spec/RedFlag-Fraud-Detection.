# 🚩 RedFlag – Fraud Detection System

## 📌 Project Overview

RedFlag is a SQL-based fraud detection project developed as part of The Unlox Academy's Data Analytics and Data Science Minor Project.

The objective of this project is to identify suspicious transaction patterns in a simulated Indian fintech payment dataset containing approximately 200,000 transaction records across six months.

Using MySQL 8.0, this project detects 12 different types of potentially fraudulent activities through SQL queries, aggregations, conditional logic, Common Table Expressions (CTEs), and window functions.

## 🎯 Project Objectives

- Analyse large-scale financial transaction data.
- Identify suspicious user and merchant activities.
- Detect common financial fraud patterns.
- Apply SQL concepts to real-world fintech scenarios.
- Develop practical fraud detection and data analysis skills.

## 🕵️ Fraud Patterns Detected

This project covers the following 12 fraud detection patterns:

| No. | Fraud Pattern | Description |
|---|---|---|
| P1 | Velocity Fraud | Detects unusually high daily transaction activity. |
| P2 | Round-Amount Clustering | Identifies repeated round-value transactions. |
| P3 | Card Testing | Detects repeated small-value transactions. |
| P4 | Failed Transactions | Identifies users with repeated failed payments. |
| P5 | Odd-Hour Concentration | Detects suspicious activity during unusual hours. |
| P6 | Mule Accounts | Identifies suspicious credit transaction activity. |
| P7 | Refund Abuse | Detects unusually high refund percentages. |
| P8 | Merchant Collusion | Identifies merchants with concentrated transaction values. |
| P9 | Just-Under-Threshold Structuring | Detects repeated transactions of ₹9,999. |
| P10 | Dormant-Then-Active | Identifies accounts reactivated after long periods of inactivity. |
| P11 | Velocity Spike | Detects unusual increases in monthly transaction activity. |
| P12 | Geographic Impossibility | Identifies transactions occurring in different cities within 60 minutes. |

## 🛠️ Technologies Used

- **Database:** MySQL 8.0
- **SQL Environment:** MySQL Workbench
- **Version Control:** GitHub
- **Query Concepts:** SELECT, WHERE, GROUP BY, HAVING, ORDER BY, CASE WHEN, CTEs, aggregate functions and window functions.

## 📊 Dataset Information

- Dataset: Simulated Indian fintech transactions
- Total Transactions: Approximately 200,000
- Unique Users: Approximately 14,700
- Time Period: January 2024 – June 2024
- Database Name: `redflag`
- Main Table: `transactions`

The original dataset is provided separately by The Unlox Academy.

## 📁 Repository Structure


RedFlag-Fraud-Detection/
│
├── README.md
│
├── RedFlag_Mayuri.sql
│
└── screenshots/
    ├── P1_Velocity_Fraud.png
    ├── P2_Round_Amount.png
    ├── P3_Card_Testing.png
    └── P9_Structuring.png


## 📸 Project Screenshots

Screenshots of selected SQL queries and their output are available in the `screenshots` folder.

These demonstrate the execution of fraud detection queries and their corresponding results.

## 🚀 How to Run the Project

1. Install MySQL 8.0 and MySQL Workbench.
2. Import the original RedFlag transaction dataset.
3. Ensure that the `redflag` database is available.
4. Open `RedFlag_Mayuri.sql` in MySQL Workbench.
5. Execute the detection queries individually.
6. Review the Result Grid to analyse suspicious transactions and users.

## 📚 Key Learnings

Through this project, I gained practical experience in:

- Writing complex SQL queries.
- Analysing large transaction datasets.
- Using aggregate functions and conditional statements.
- Applying CTEs and window functions.
- Identifying suspicious financial transaction patterns.
- Understanding SQL-based fraud detection techniques.

## 👩‍💻 Author

**Mayuri Nilange.**

Data Analytics and Data Science Student

## 🙏 Acknowledgement

This project was completed as part of The Unlox Academy's Data Analytics and Data Science Minor Project.

---

*Built using MySQL 8.0 | SQL-Based Fraud Detection | 2024 Transaction Dataset*
