/*****************************************************************************************************************
NAME:    My Script Name
PURPOSE: My script purpose...

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     05/23/2022   JJAUSSI       1. Built this script for EC IT440


RUNTIME: 
Xm Xs

NOTES: 
This is where I talk about what this script is, why I built it, and other stuff...
 
******************************************************************************************************************/

-- Q1: What should go here?
-- A1: Question goes on the previous line, intoduction to the answer goes on this line...

-- Q1 Business User question—Marginal complexity:
SELECT '$ ' + 
CAST(CAST(AVG(ListPrice) AS decimal(5,2)) AS VARCHAR(MAX)) [Average List Price] 
FROM Production.Product;

-- Q2 Business User question—Marginal complexity:
SELECT JobTitle [Job Title]
,COUNT(JobTitle) [Total Employees]
FROM HumanResources.Employee
WHERE JobTitle = 'Sales Representative'
GROUP BY JobTitle;

-- Q3 Business User question—Moderate complexity: We are reviewing accessory profitability. We define net revenue as list price minus standard cost. 
-- A3 All three helmets in the inventory have the same StandardCost with the same ListPrice.
SELECT TOP 1 NetRevenue
FROM (SELECT CAST((ListPrice - StandardCost) AS VARCHAR(MAX)) [NetRevenue]
	  FROM Production.Product
	  WHERE Name LIKE '%HELMET%') nr
ORDER BY NetRevenue;

-- Q4 Business User question—Moderate complexity: I’m analyzing regional performance. Which five cities generated the highest total sales revenue over the past year.
SELECT TOP 5 st.Name [Territory] 
,'$ ' + FORMAT(SUM(st.SalesLastYear), 'N2') [Total Revenue]
FROM Sales.SalesTerritory st
GROUP BY st.Name
ORDER BY [Total Revenue] DESC;

-- Q5 Business User question—Increased complexity: Given our goal to optimize inventory, can we analyze the lead times for our top 5 most frequently purchased components 
-- by quantity from the PurchaseOrderDetail and ProductVendor tables, over the last 12 months? Understanding supplier performance is crucial for managing our production pipeline effectively.
SELECT TOP 5 p.Name [Product Name]
,v.Name [Vendor]
,SUM(pod.OrderQty) [Total Purchased Qty]
,AVG(pv.AverageLeadTime) [Average Lead Time (days)]
FROM Purchasing.PurchaseOrderDetail pod
JOIN Purchasing.PurchaseOrderHeader poh ON pod.PurchaseOrderID = poh.PurchaseOrderID
JOIN Purchasing.ProductVendor pv ON pod.ProductID = pv.ProductID
JOIN Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID
JOIN Production.Product p ON pod.ProductID = p.ProductID
WHERE poh.OrderDate >= DATEADD(YEAR, -1, '2013-09-22')
GROUP BY p.Name, v.Name
ORDER BY [Total Purchased Qty] DESC;

-- Q6 Business User question—Increased complexity: We're looking to enhance our customer loyalty programs. 
-- Can we identify customers from the Customer table who have placed orders in three or more distinct sales territories based on SalesOrderHeader? 
-- These multi-territory customers might be ideal candidates for specialized loyalty initiatives.
SELECT [Customer Name] [Customer (Person or Store)]
,Territories
FROM (SELECT p.FirstName + ' ' + p.LastName [Customer Name]
,COUNT(DISTINCT soh.TerritoryID) [Territories]
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
GROUP BY p.FirstName, p.LastName
HAVING COUNT(DISTINCT soh.TerritoryID) >= 3) personsales

UNION

SELECT * FROM (SELECT s.Name [Customer Name]
,COUNT(DISTINCT soh.TerritoryID) [Territories]
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
GROUP BY s.Name
HAVING COUNT(DISTINCT soh.TerritoryID) >= 3) storesales
ORDER BY Territories DESC;

-- Q7 Metadata question— Can you list all tables that contain a column named ‘SalesOrderID’ using INFORMATION_SCHEMA.COLUMNS?
SELECT DISTINCT TABLE_NAME [Table]
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME = 'SalesOrderID'

-- Q8 Metadata question— Using INFORMATION_SCHEMA.TABLES, which tables belong to the Sales schema?
SELECT DISTINCT TABLE_NAME [Tables]
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'Sales'
AND TABLE_TYPE = 'BASE TABLE'