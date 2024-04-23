/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

USE WideWorldImporters

/*

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
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
ORDER BY year(CAST(InvoiceMonth as date)), Month(CAST(InvoiceMonth as date)) ;
-------------------------------------------------------------------------------------------------

--из-за ошибки превышения максимальной длины строки, ограничила количество покупателей
DECLARE @dml AS NVARCHAR(MAX)
DECLARE @ColumnName AS NVARCHAR(MAX)

SELECT @ColumnName= ISNULL(@ColumnName + ',','') 
       + QUOTENAME(Customers.CustomerName)
FROM (SELECT distinct CN.CustomerName
	FROM Sales.Invoices sInvoices
	LEFT JOIN Sales.Customers sCustomers ON sCustomers.CustomerID = sInvoices.CustomerID
	CROSS APPLY (SELECT substring(sCustomers.CustomerName, charindex('(', sCustomers.CustomerName) + 1, len(sCustomers.CustomerName) - charindex('(', sCustomers.CustomerName)-1) as CustomerName) as CN
	GROUP BY  CN.CustomerName having  count(sInvoices.InvoiceID) > 100 ) AS Customers

SELECT @ColumnName as ColumnName 

SET @dml = 
  N'SELECT InvoiceMonth, ' +@ColumnName + ' FROM
  (
	SELECT IM.InvoiceMonth,
	CN.CustomerName,
	count(sInvoices.InvoiceID) AS cnt_Invoices
	FROM Sales.Invoices sInvoices
	CROSS APPLY (SELECT format(CAST(DATEADD(mm,DATEDIFF(mm,0,sInvoices.InvoiceDate),0) AS DATE), ''dd.MM.yyyy'') AS InvoiceMonth) AS IM
	LEFT JOIN Sales.Customers sCustomers ON sCustomers.CustomerID = sInvoices.CustomerID
	CROSS APPLY (SELECT substring(sCustomers.CustomerName, charindex(''('', sCustomers.CustomerName) + 1, len(sCustomers.CustomerName) - charindex(''('', sCustomers.CustomerName)-1) as CustomerName) as CN
	GROUP BY  IM.InvoiceMonth, CN.CustomerName 
	) AS Data
	 PIVOT(SUM(cnt_Invoices) FOR CustomerName 
		IN(' + @ColumnName + ')) AS PVTTable ORDER BY year(CAST(InvoiceMonth as date)), Month(CAST(InvoiceMonth as date));
'

EXEC sp_executesql @dml