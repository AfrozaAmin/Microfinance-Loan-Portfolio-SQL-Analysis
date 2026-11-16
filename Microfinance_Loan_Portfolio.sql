SELECT *
FROM Loans;

--This SQL query calculates a broad financial summary report from your loans database to give you a high-level overview of your lending activity. 
--It counts the total number of loans processed, counts how many unique countries and different business sectors are involved, and 
--calculates both the average size of a single loan and the grand total of all money requested across the entire dataset.

SELECT
    COUNT(*) AS Total_Loans,
    COUNT(DISTINCT country) AS Total_Countries,
    COUNT(DISTINCT sector) AS Total_Sectors,
    AVG(loan_amount) AS Average_Loan_Amount,
    SUM(loan_amount) AS Total_Loan_Requested
FROM Loans;


--This SQL query acts as a data quality check that hunts for missing information in your database. 
--It counts the total number of rows in your table and checks three specific columns—country, sector, and loan amount—to calculate the exact number of blank or missing values in each one, 
--helping you quickly see how clean or incomplete your data is.
SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END)
        AS Missing_Country,
    SUM(CASE WHEN sector IS NULL THEN 1 ELSE 0 END)
        AS Missing_Sector,
    SUM(CASE WHEN loan_amount IS NULL THEN 1 ELSE 0 END)
        AS Missing_Loan_Amount
FROM Loans;


--This SQL query creates a funding performance report that categorizes how well each individual loan met its financial goal. It displays the ID, country, sector, loan amount, and funded amount for every single loan, while generating a new custom label that flags whether the loan is Fully Funded, Partially Funded, 
--or Not Funded based on how much money it actually raised.
SELECT
    id,
    country,
    sector,
    loan_amount,
    funded_amount,

    CASE
        WHEN funded_amount >= loan_amount
            THEN 'Fully Funded'
        WHEN funded_amount > 0
            THEN 'Partially Funded'
        ELSE 'Not Funded'
    END AS Funding_Status

FROM Loans;






--This SQL query creates a loan size analysis report that groups your loans into three distinct brackets: Small Loans (under 500), Medium Loans (500 to 1,500), and Large Loans (over 1,500). For each of these three tiers, it calculates the total count of loans, the average loan size, and the combined dollar amount requested, 
--then sorts the entire list so the tier bringing in the most requested money appears at the very top.

SELECT
    CASE
        WHEN loan_amount < 500
            THEN 'Small Loan'
        WHEN loan_amount BETWEEN 500 AND 1500
            THEN 'Medium Loan'
        ELSE 'Large Loan'
    END AS Loan_Category,

    COUNT(*) AS Number_Of_Loans,
    AVG(loan_amount) AS Average_Loan,
    SUM(loan_amount) AS Total_Requested

FROM Loans
GROUP BY
    CASE
        WHEN loan_amount < 500 THEN 'Small Loan'
        WHEN loan_amount BETWEEN 500 AND 1500
            THEN 'Medium Loan'
        ELSE 'Large Loan'
    END
ORDER BY Total_Requested DESC;







--This SQL query creates a geographic performance report that ranks countries by how successfully they fund their loans. 
--It first groups the data by country to calculate the total number of loans, total money requested, total money funded, and the overall funding success percentage for each nation. Finally, it filters the results to only display countries that have a solid baseline of 100 or more loans, 
--sorting them from the highest funding success rate to the lowest.
WITH CountryAnalysis AS
(
    SELECT
        country,
        COUNT(*) AS Total_Loans,
        SUM(loan_amount) AS Total_Requested,
        SUM(funded_amount) AS Total_Funded,

        CAST(
            SUM(funded_amount) * 100.0 /
            NULLIF(SUM(loan_amount), 0)
            AS DECIMAL(10,2)
        ) AS Funding_Rate

    FROM Loans
    GROUP BY country
)

SELECT *
FROM CountryAnalysis
WHERE Total_Loans >= 100
ORDER BY Funding_Rate DESC;




--This SQL query creates a regional popularity report that identifies the top business sectors in each country. 
--It groups the data to count the total number of loans for every country and sector combination. Then, it uses a ranking tool to score the sectors within each individual nation, giving a rank of 1 to the most popular industry in that specific country, 
--a rank of 2 to the second most popular, and so on.
SELECT
    country,
    sector,
    COUNT(*) AS Total_Loans,

    RANK() OVER (
        PARTITION BY country
        ORDER BY COUNT(*) DESC
    ) AS Sector_Rank

FROM Loans
GROUP BY country, sector;






--This SQL query creates a loan variance report that evaluates how individual loan amounts compare to local national averages. 
--It pulls the ID, country, and loan amount for every single loan. At the same time, 
--it calculates the average loan size for that specific country and computes the exact dollar difference between the individual loan and its local country average, 
--instantly showing you which loans are unusually large or small for their region.

SELECT
    id,
    country,
    loan_amount,

    AVG(loan_amount) OVER (
        PARTITION BY country
    ) AS Country_Average,

    loan_amount -
    AVG(loan_amount) OVER (
        PARTITION BY country
    ) AS Difference_From_Average

FROM Loans;






--This SQL query creates a monthly growth and funding report that tracks lending trends over time. 
--It first groups the data by year and month to calculate the total number of loans, total money requested, and total money funded for each calendar month. 
--Finally, it uses a time-shifting tool to pull the total funding amount from the previous month and displays it right next to the current month's data, 
--allowing you to easily compare performance and see if funding is growing or shrinking month-over-month.


WITH MonthlyData AS
(
    SELECT
        YEAR(posted_time) AS Loan_Year,
        MONTH(posted_time) AS Loan_Month,
        COUNT(*) AS Total_Loans,
        SUM(loan_amount) AS Total_Requested,
        SUM(funded_amount) AS Total_Funded

    FROM Loans
    WHERE posted_time IS NOT NULL
    GROUP BY
        YEAR(posted_time),
        MONTH(posted_time)
)

SELECT
    *,
    LAG(Total_Funded) OVER (
        ORDER BY Loan_Year, Loan_Month
    ) AS Previous_Month_Funding

FROM MonthlyData
ORDER BY Loan_Year, Loan_Month;




--This SQL query creates a top-five industry leaderboard that highlights the most successful business sectors in your lending database. 
--It first groups all the loans by industry to calculate the total count of loans, the grand total of money requested, and the grand total of money 
--funded for every single sector. Then, it ranks all the sectors based on how much money they successfully raised and filters the final list to display 
--only the top 5 highest-funded sectors at the very top of your report.

	WITH SectorPerformance AS
(
    SELECT
        sector,
        COUNT(*) AS Total_Loans,
        SUM(loan_amount) AS Total_Requested,
        SUM(funded_amount) AS Total_Funded

    FROM Loans
    GROUP BY sector
),

RankedSectors AS
(
    SELECT *,
        RANK() OVER (
            ORDER BY Total_Funded DESC
        ) AS Sector_Rank

    FROM SectorPerformance
)

SELECT *
FROM RankedSectors
WHERE Sector_Rank <= 5;







--This SQL query creates a cumulative financial tracking report that maps out the growth of your funding over time. 
--It first organizes all your historical data by year and month to calculate the total money funded during each specific calendar month. 
--Then, it uses a running calculation tool to add up the monthly totals sequentially, generating a running total of all funding 
--from the very first month in your database up through the current row, 
--allowing you to see your all-time funding milestone grow month by month.

WITH MonthlyFunding AS
(
    SELECT
        YEAR(posted_time) AS Loan_Year,
        MONTH(posted_time) AS Loan_Month,
        SUM(funded_amount) AS Monthly_Funding

    FROM Loans
    WHERE posted_time IS NOT NULL
    GROUP BY
        YEAR(posted_time),
        MONTH(posted_time)
)

SELECT
    Loan_Year,
    Loan_Month,
    Monthly_Funding,

    SUM(Monthly_Funding) OVER (
        ORDER BY Loan_Year, Loan_Month
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS Running_Total_Funding

FROM MonthlyFunding;