/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

SELECT aPeople.PersonID, aPeople.FullName
FROM Application.People aPeople
WHERE PersonId NOT IN (SELECT SalespersonPersonID FROM Sales.Invoices where InvoiceDate = '2015-07-04') 
and aPeople.IsSalesPerson = 1
ORDER BY PersonID;

SELECT aPeople.PersonID, aPeople.FullName
FROM Application.People aPeople
WHERE NOT EXISTS (
    SELECT 1
	FROM Sales.Invoices
	WHERE SalespersonPersonID = aPeople.PersonID AND InvoiceDate = '2015-07-04')
and aPeople.IsSalesPerson = 1	
ORDER BY aPeople.PersonID;

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

SELECT StockItemID, StockItemName, UnitPrice 
FROM Warehouse.StockItems
WHERE UnitPrice <= ALL (
	SELECT UnitPrice 
	FROM Warehouse.StockItems);

SELECT StockItemID, StockItemName, UnitPrice 
FROM Warehouse.StockItems
WHERE UnitPrice = (SELECT min(UnitPrice) FROM Warehouse.StockItems);

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/
SELECT sCustomers.CustomerID, sCustomers.CustomerName
FROM Sales.Customers AS sCustomers
JOIN 
(SELECT TOP 5 CustomerID, SUM(TransactionAmount) TransactionAmount
	FROM Sales.CustomerTransactions
	GROUP BY CustomerID	
	ORDER BY TransactionAmount DESC) as TT
ON TT.CustomerID = sCustomers.CustomerID
ORDER BY sCustomers.CustomerID;

-- CTE 	
;WITH TransCTE (CustomerID, TransactionAmount) AS 
(
	SELECT TOP 5 CustomerID, SUM(TransactionAmount) TransactionAmount
	FROM Sales.CustomerTransactions
	GROUP BY CustomerID	
	ORDER BY TransactionAmount DESC
)
SELECT sCustomers.CustomerID, sCustomers.CustomerName, T.TransactionAmount
FROM Sales.Customers AS sCustomers
	JOIN TransCTE AS T
		ON sCustomers.CustomerID  = T.CustomerID
ORDER BY sCustomers.CustomerID;

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/
Select distinct aCities.CityID, aCities.CityName, aPeople.FullName
from Sales.Invoices sInvoices
join (
		Select sInvoiceLines.InvoiceID
		from Sales.InvoiceLines sInvoiceLines
		where sInvoiceLines.StockItemID in (select top 3 StockItemID from Warehouse.StockItems order by UnitPrice desc)
	) TT on TT.InvoiceID = sInvoices.InvoiceID
join Application.People aPeople on aPeople.PersonID = sInvoices.PackedByPersonID
join Sales.Customers sCustomers on sCustomers.CustomerID = sInvoices.CustomerID
join Application.Cities aCities on aCities.CityID = sCustomers.DeliveryCityID

--CTE
;WITH InvoiceCTE (InvoiceID) AS 
(
	Select distinct sInvoiceLines.InvoiceID 
		from Sales.InvoiceLines sInvoiceLines
		where sInvoiceLines.StockItemID in (select top 3 StockItemID from Warehouse.StockItems order by UnitPrice desc)
)
Select distinct aCities.CityID, aCities.CityName, aPeople.FullName
from Sales.Invoices sInvoices
JOIN InvoiceCTE AS TT ON TT.InvoiceID = sInvoices.InvoiceID
join Application.People aPeople on aPeople.PersonID = sInvoices.PackedByPersonID
join Sales.Customers sCustomers on sCustomers.CustomerID = sInvoices.CustomerID
join Application.Cities aCities on aCities.CityID = sCustomers.DeliveryCityID

;
-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

-- выводит ид счета, дату счета, фио продавца, общую сумму счета, общую сумму заказа, в котором указана датой комплектации всего заказа 
-- в данном случае читаемость плохая, но запрос будет работат быстро, так как в селекте подзапросы выполняются по уже ограниченному количеству записей.
SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --
-- по времени также, читается проще
;WITH CTE (OrderId, InvoiceID, InvoiceDate, SalesPersonName, TotalSummByInvoice) AS
(SELECT Invoices.OrderId,
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	aPeople.FullName AS SalesPersonName,
	SUM(sInvoiceLines.Quantity*sInvoiceLines.UnitPrice) AS TotalSummByInvoice
	
FROM Sales.Invoices 
	JOIN Application.People aPeople on aPeople.PersonID = Invoices.SalespersonPersonID
	JOIN Sales.InvoiceLines sInvoiceLines on sInvoiceLines.InvoiceID = Invoices.InvoiceID
group by 	Invoices.InvoiceID, 	Invoices.InvoiceDate,	aPeople.FullName, Invoices.OrderId
having SUM(sInvoiceLines.Quantity*sInvoiceLines.UnitPrice) > 27000

)
SELECT InvoiceID,
	InvoiceDate,
	SalesPersonName,
	TotalSummByInvoice,
	SUM(sOrderLines.PickedQuantity*sOrderLines.UnitPrice) as TotalSummForPickedItems
FROM Sales.Orders sOrders 
	JOIN Sales.OrderLines sOrderLines on sOrders.OrderID =  sOrderLines.OrderID 
	JOIN CTE on CTE.orderid = sOrders.orderid
WHERE sOrders.PickingCompletedWhen IS NOT NULL
group by 	InvoiceID, InvoiceDate, SalesPersonName, TotalSummByInvoice
ORDER BY TotalSummByInvoice DESC