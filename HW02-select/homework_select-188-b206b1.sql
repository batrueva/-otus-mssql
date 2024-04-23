/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT StockItemID,
		 StockItemName
FROM Warehouse.StockItems
WHERE StockItemName LIKE '%urgent%'
		OR StockItemName LIKE 'Animal%' 

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT pS.SupplierID,
		 pS.SupplierName,
		 pPO.SupplierID
FROM Purchasing.Suppliers pS left outer
JOIN Purchasing.PurchaseOrders pPO
	ON pPO.SupplierID = pS.SupplierID
WHERE pPO.SupplierID is null

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

SELECT sOrders.OrderID,
		 format(sOrders.OrderDate,
		 'dd.MM.yyyy') AS _OrderDate, DATENAME(month, sOrders.OrderDate) AS _Month, DATEPART(quarter, sOrders.OrderDate) AS _quarter, cast((cast(DATEPART(month, sOrders.OrderDate) AS DECIMAL(5, 2))/4) AS DECIMAL(5, 2)), (case
	WHEN cast((cast(DATEPART(month, sOrders.OrderDate) AS DECIMAL(5, 2))/4) AS DECIMAL(5, 2)) <= 1 THEN
	1
	WHEN cast((cast(DATEPART(month, sOrders.OrderDate) AS DECIMAL(5, 2))/4) AS DECIMAL(5, 2)) <= 2 THEN
	2
	ELSE 3 end) AS _triath, sCustomers.CustomerName
FROM Sales.Customers sCustomers
LEFT JOIN Sales.Orders sOrders
	ON sOrders.CustomerID = sCustomers.CustomerID
LEFT JOIN Sales.OrderLines sOrderLines
	ON sOrderLines.OrderID = sOrders.OrderID
WHERE (sOrderLines.UnitPrice > 100
		OR sOrderLines.Quantity > 20)
		AND sOrders.PickingCompletedWhen is NOT null
ORDER BY  _quarter,
		 _triath,
		_OrderDate OFFSET 1000 ROWS FETCH FIRST 100 ROWS ONLY
--------------------------------------------------------------------------------------------
SELECT sOrders.OrderID,
		 format(sOrders.OrderDate,
		 'dd.MM.yyyy') AS _OrderDate, DATENAME(month, sOrders.OrderDate) AS _Month, DATEPART(quarter, sOrders.OrderDate) AS _quarter, cast((cast(DATEPART(month, sOrders.OrderDate) AS DECIMAL(5, 2))/4) AS DECIMAL(5, 2)), (case DATEPART(month, sOrders.OrderDate)
	WHEN 1 THEN
	1
	WHEN 2 THEN
	1
	WHEN 3 THEN
	1
	WHEN 4 THEN
	1
	WHEN 5 THEN
	2
	WHEN 6 THEN
	2
	WHEN 7 THEN
	2
	WHEN 8 THEN
	2
	ELSE 3 end) AS _triath, sCustomers.CustomerName
FROM Sales.Customers sCustomers
LEFT JOIN Sales.Orders sOrders
	ON sOrders.CustomerID = sCustomers.CustomerID
LEFT JOIN Sales.OrderLines sOrderLines
	ON sOrderLines.OrderID = sOrders.OrderID
WHERE (sOrderLines.UnitPrice > 100
		OR sOrderLines.Quantity > 20)
		AND sOrders.PickingCompletedWhen is NOT null
ORDER BY  _quarter,
		 _triath,
		_OrderDate OFFSET 1000 ROWS FETCH FIRST 100 ROWS ONLY
/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT aDeliveryMethods.DeliveryMethodName,
		 format(pPurchaseOrders.ExpectedDeliveryDate,
		 'dd.MM.yyyy') AS _ExpectedDeliveryDate, pSuppliers.SupplierName, aPeople.FullName
FROM Purchasing.Suppliers pSuppliers
LEFT JOIN Purchasing.PurchaseOrders pPurchaseOrders
	ON pPurchaseOrders.SupplierID = pSuppliers.SupplierID
LEFT JOIN Application.DeliveryMethods aDeliveryMethods
	ON aDeliveryMethods.DeliveryMethodID = pPurchaseOrders.DeliveryMethodID
LEFT JOIN Application.People aPeople
	ON aPeople.PersonID = pPurchaseOrders.ContactPersonID
WHERE pPurchaseOrders.ExpectedDeliveryDate
	BETWEEN '2013-01-01'
		AND '2013-01-31' --если datetime, то pPurchaseOrders.ExpectedDeliveryDate >= '2013-01-01'
		AND pPurchaseOrders.ExpectedDeliveryDate <= '2013-01-31'
		AND aDeliveryMethods.DeliveryMethodName IN ('Air Freight', 'Refrigerated Air Freight')
		AND pPurchaseOrders.IsOrderFinalized = 1
/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

SELECT top 10 sCustomers.CustomerName,
		 aPeople.FullName
FROM Sales.Orders sOrders
LEFT JOIN Sales.Customers sCustomers
	ON sCustomers.CustomerID = sOrders.CustomerID
LEFT JOIN Application.People aPeople
	ON aPeople.PersonID = sOrders.SalespersonPersonID
ORDER BY  sOrders.OrderDate desc
/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT sCustomers.CustomerID,
		 sCustomers.CustomerName,
		 sCustomers.PhoneNumber
FROM Sales.Orders sOrders
LEFT JOIN Sales.Customers sCustomers
	ON sCustomers.CustomerID = sOrders.CustomerID
LEFT JOIN Sales.OrderLines sOrderLines
	ON sOrderLines.OrderID = sOrders.OrderID
LEFT JOIN Warehouse.StockItems wStockItems
	ON wStockItems.StockItemID = sOrderLines.StockItemID
WHERE wStockItems.StockItemName = 'Chocolate frogs 250g'
ORDER BY  sCustomers.CustomerName