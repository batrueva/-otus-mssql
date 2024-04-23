/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

--Вариан итогов по примеру
Use AdventureWorks2019;

SELECT SalesYear, 
       ISNULL([1], 0) AS Jan, 
       ISNULL([2], 0) AS Feb, 
       ISNULL([3], 0) AS Mar, 
       ISNULL([4], 0) AS Apr, 
       ISNULL([5], 0) AS May, 
       ISNULL([6], 0) AS Jun, 
       ISNULL([7], 0) AS Jul, 
       ISNULL([8], 0) AS Aug, 
       ISNULL([9], 0) AS Sep, 
       ISNULL([10], 0) AS Oct, 
       ISNULL([11], 0) AS Nov, 
       ISNULL([12], 0) AS Dec, 
       (ISNULL([1], 0) + ISNULL([2], 0) + ISNULL([3], 0) + ISNULL([4], 0)  + ISNULL([5], 0) + ISNULL([6], 0) + ISNULL([7], 0) + ISNULL([8], 0) + ISNULL([9], 0) + ISNULL([10], 0) + ISNULL([11], 0) + ISNULL([12], 0)) SalesYTD
FROM
(   SELECT YEAR(SOH.OrderDate) AS SalesYear, 
           DATEPART(MONTH, SOH.OrderDate) Months,
          SOH.SubTotal AS TotalSales
    FROM sales.SalesOrderHeader SOH
         JOIN sales.SalesOrderDetail SOD ON SOH.SalesOrderId = SOD.SalesOrderId
 ) AS Data 
 PIVOT (SUM(TotalSales) 
 FOR Months IN([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])) AS pvt 
   order by SalesYear;

   SELECT SalesYear, 
	   ISNULL([0], 0) AS SalesYTD, 
       ISNULL([1], 0) AS Jan, 
       ISNULL([2], 0) AS Feb, 
       ISNULL([3], 0) AS Mar, 
       ISNULL([4], 0) AS Apr, 
       ISNULL([5], 0) AS May, 
       ISNULL([6], 0) AS Jun, 
       ISNULL([7], 0) AS Jul, 
       ISNULL([8], 0) AS Aug, 
       ISNULL([9], 0) AS Sep, 
       ISNULL([10], 0) AS Oct, 
       ISNULL([11], 0) AS Nov, 
       ISNULL([12], 0) AS Dec ,
       (ISNULL([1], 0) + ISNULL([2], 0) + ISNULL([3], 0) + ISNULL([4], 0)  + ISNULL([5], 0) + ISNULL([6], 0) + ISNULL([7], 0) + ISNULL([8], 0) + ISNULL([9], 0) + ISNULL([10], 0) + ISNULL([11], 0) + ISNULL([12], 0)) SalesYTD
FROM
(   SELECT YEAR(SOH.OrderDate) AS SalesYear, 
           DATEPART(MONTH, SOH.OrderDate) Months,
          SOH.SubTotal AS TotalSales
    FROM sales.SalesOrderHeader SOH
         JOIN sales.SalesOrderDetail SOD ON SOH.SalesOrderId = SOD.SalesOrderId
union all
SELECT YEAR(SOH.OrderDate) AS SalesYear, 
           0 as  Months,
          SUM(SOH.SubTotal) AS TotalSales
    FROM sales.SalesOrderHeader SOH
         JOIN sales.SalesOrderDetail SOD ON SOH.SalesOrderId = SOD.SalesOrderId
group by YEAR(SOH.OrderDate)
 ) AS Data 
 PIVOT (SUM(TotalSales) 
 FOR Months IN([0],[1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])) AS pvt 
   order by SalesYear;
---------------------------------------------------------------------------------------------------------
USE WideWorldImporters

/*
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/
SELECT InvoiceMonth, [Sylvanite, MT], [Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Jessie, ND]
FROM (
SELECT IM.InvoiceMonth,
	CN.CustomerName,
	count(sInvoices.InvoiceID) AS cnt_Invoices
FROM Sales.Invoices sInvoices
CROSS APPLY (SELECT format(CAST(DATEADD(mm,DATEDIFF(mm,0,sInvoices.InvoiceDate),0) AS DATE), 'dd.MM.yyyy') AS InvoiceMonth) AS IM
LEFT JOIN Sales.Customers sCustomers ON sCustomers.CustomerID = sInvoices.CustomerID
CROSS APPLY (SELECT substring(sCustomers.CustomerName, charindex('(', sCustomers.CustomerName) + 1, len(sCustomers.CustomerName) - charindex('(', sCustomers.CustomerName)-1) as CustomerName) as CN
WHERE sCustomers.CustomerID between 2 and 6
GROUP BY  IM.InvoiceMonth, CN.CustomerName
) AS Data
 PIVOT(SUM(cnt_Invoices) FOR CustomerName 
	IN( [Sylvanite, MT], [Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Jessie, ND])) 
	   AS pvt
ORDER BY InvoiceMonth;


/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/
SELECT CustomerName, AddressLine
FROM (
	Select sCustomers.CustomerName,
		sCustomers.DeliveryAddressLine1,
		sCustomers.DeliveryAddressLine2
	from Sales.Customers sCustomers
	where sCustomers.CustomerName like 'Tailspin Toys%'
	) as CustomersAddressLine
UNPIVOT (AddressLine FOR Name IN (DeliveryAddressLine1, DeliveryAddressLine2)) AS unpt;
/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

SELECT CountryID, CountryName, Code
FROM (
	Select aCountries.CountryID,
		aCountries.CountryName,
		aCountries.IsoAlpha3Code, 
		convert(nvarchar(3), aCountries.IsoNumericCode) as cIsoNumericCode
	from Application.Countries aCountries
	
	) as Countries
UNPIVOT (Code FOR IsoCode IN (IsoAlpha3Code, cIsoNumericCode)) AS unpt;

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

SELECT sCustomers.CustomerID, sCustomers.CustomerName, SI.StockItemID, SI.UnitPrice, SI.InvoiceDate
FROM Sales.Customers sCustomers
CROSS APPLY 
(SELECT TOP 2 wStockItems.StockItemID, sInvoiceLines.UnitPrice, sInvoices.InvoiceDate
	from Sales.Invoices sInvoices
	left join Sales.InvoiceLines sInvoiceLines on sInvoiceLines.InvoiceID = sInvoices.InvoiceID
	left join Warehouse.StockItems wStockItems on wStockItems.StockItemID = sInvoiceLines.StockItemID
	where sInvoices.CustomerID = sCustomers.CustomerCategoryID
	Order by sInvoiceLines.UnitPrice desc) AS SI
ORDER BY sCustomers.CustomerName;
