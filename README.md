# Microfinance-Loan-Portfolio-SQL-Analysis
# Microfinance Loan Portfolio & Funding Analysis (SQL Server)

##  Project Overview
This project performs an advanced SQL-based exploration of microfinance lending datasets to evaluate loan funding performance, geographic distribution, sector trends, and temporal growth patterns. Designed with a strong focus on financial inclusion metrics and portfolio performance.

##  Tech Stack & Advanced SQL Concepts Used
- **Database Management System:** Microsoft SQL Server (SSMS)
- **Advanced SQL Constructs:** 
  - Common Table Expressions (CTEs)
  - Window Functions (`RANK()`, `LAG()`, `SUM() OVER`)
  - Conditional Logic (`CASE WHEN`)
  - Aggregations & Grouping (`GROUP BY`, `HAVING`)
  - Data Quality & NULL Analysis

##  Key Business Insights Extracted
1. **Portfolio Scale & Distribution:** Evaluated global capital flows and identified high-volume lending sectors and target countries.
2. **Funding Efficiency:** Used multi-level CTEs to analyze and filter baseline markets by their overall funding success rate.
3. **Loan Tier Segmentation:** Categorized portfolio risk-and-size brackets (Small, Medium, Large) using `CASE WHEN` to determine which tiers drive the highest capital requests.
4. **Geographic Sector Leadership:** Applied partitioned ranking window functions (`RANK() OVER (PARTITION BY)`) to isolate top-performing industries per country.
5. **Temporal Growth & Momentum:** Tracked month-over-month funding velocity using `LAG()` and mapped cumulative financial milestones via running totals (`SUM() OVER`).

##  File Structure
- `Microfinance_Loan_Portfolio.sql`: Contains all exploratory, cleaning, and advanced analytical queries with documentation.
