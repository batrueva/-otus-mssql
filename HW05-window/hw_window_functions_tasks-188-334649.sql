/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример: 
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/
set statistics time, io on;
--1 без оконной ф
WITH CTE (YY, MM, sSumma) AS (
	select Year(sInvoices.InvoiceDate) yy, Month(sInvoices.InvoiceDate) mm, sum(sInvoiceLines.ExtendedPrice) ss
	FROM Sales.Invoices sInvoices
		LEFT JOIN Sales.InvoiceLines sInvoiceLines
		ON sInvoiceLines.InvoiceID = sInvoices.InvoiceID
	where Year(sInvoices.InvoiceDate) =2015
	GROUP BY Year(sInvoices.InvoiceDate), Month(sInvoices.InvoiceDate)
	
)
SELECT	 sInvoices.InvoiceID as 'id продажи'
		 ,sInvoices.InvoiceDate AS 'Дата Продажи'
		 ,sCustomers.CustomerName as 'название клиента'
		 ,(select sum(sInvoiceLines.ExtendedPrice) 
			FROM Sales.InvoiceLines sInvoiceLines
				WHERE sInvoiceLines.InvoiceID = sInvoices.InvoiceID
		 ) AS 'Сумма продажи'
		 ,(Select SUM(CTE.sSumma) from cte WHERE CTE.yy = Year(sInvoices.InvoiceDate) and CTE.mm <= Month(sInvoices.InvoiceDate)) AS 'Сумма продажи нарастающим итогом'
FROM Sales.Invoices sInvoices
LEFT JOIN Sales.Customers sCustomers 
	ON sCustomers.CustomerID = sInvoices.CustomerID
WHERE datepart(YYYY, sInvoices.InvoiceDate) = 2015
ORDER BY  sInvoices.InvoiceDate,sCustomers.CustomerName;

--2 без оконной ф
SELECT	 sInvoices.InvoiceID as 'id продажи'
		 ,sInvoices.InvoiceDate AS 'Дата Продажи'
		 ,sCustomers.CustomerName as 'название клиента'
		 ,(select sum(sInvoiceLines.ExtendedPrice) 
			FROM Sales.InvoiceLines sInvoiceLines
				WHERE sInvoiceLines.InvoiceID = sInvoices.InvoiceID
		 ) AS 'Сумма продажи'
		 ,(select sum(sInvoiceLines.ExtendedPrice) 
			FROM Sales.Invoices sInvoices1
			LEFT JOIN Sales.InvoiceLines sInvoiceLines
				ON sInvoiceLines.InvoiceID = sInvoices1.InvoiceID
			WHERE datepart(YYYY, sInvoices1.InvoiceDate) = datepart(YYYY, sInvoices.InvoiceDate) 
				AND datepart(MM, sInvoices1.InvoiceDate) <= datepart(MM, sInvoices.InvoiceDate)
		 ) AS 'Сумма продажи нарастающим итогом'
FROM Sales.Invoices sInvoices
LEFT JOIN Sales.Customers sCustomers 
	ON sCustomers.CustomerID = sInvoices.CustomerID
WHERE datepart(YYYY, sInvoices.InvoiceDate) = 2015
ORDER BY  sInvoices.InvoiceDate,sCustomers.CustomerName;
/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
  
*/

--3 с оконной ф
SELECT	distinct 
		sInvoices.InvoiceID as 'id продажи'
		 ,sInvoices.InvoiceDate AS 'Дата Продажи'
		 ,sCustomers.CustomerName as 'название клиента'
		 ,sum(sInvoiceLines.ExtendedPrice) over (partition by sInvoices.InvoiceID) AS 'Сумма продажи'
		 ,sum(sInvoiceLines.ExtendedPrice) over (partition by datepart(YYYY, sInvoices.InvoiceDate) order by datepart(MM, sInvoices.InvoiceDate)) AS 'Сумма продажи нарастающим итогом'
FROM Sales.Invoices sInvoices
LEFT JOIN Sales.Customers sCustomers 
	ON sCustomers.CustomerID = sInvoices.CustomerID
LEFT JOIN Sales.InvoiceLines sInvoiceLines 
	ON sInvoiceLines.InvoiceID = sInvoices.InvoiceID
WHERE datepart(YYYY, sInvoices.InvoiceDate) = 2015
ORDER BY  sInvoices.InvoiceDate,sCustomers.CustomerName;

/*  Сравните производительность запросов 1 и 2 с помощью set statistics time, io on

1й запрос с CTE - самый медленный, 2й - с подзапросами - немного быстрее, 3й быстрее 1го в 86 раз))

(затронуто строк: 22250)
Таблица "InvoiceLines". Сканирований 314, логических операций чтения 1570942, физических операций чтения 3, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 4971, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Invoices". Сканирований 314, логических операций чтения 3579600, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Worktable". Сканирований 0, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Workfile". Сканирований 0, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Worktable". Сканирований 0, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Customers". Сканирований 1, логических операций чтения 42, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.

 Время работы SQL Server:
   Время ЦП = 52562 мс, затраченное время = 53541 мс.

(затронуто строк: 22250)
Таблица "InvoiceLines". Сканирований 314, логических операций чтения 1570942, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Invoices". Сканирований 314, логических операций чтения 3579600, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Worktable". Сканирований 0, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Workfile". Сканирований 0, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Worktable". Сканирований 0, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Customers". Сканирований 1, логических операций чтения 42, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.

 Время работы SQL Server:
   Время ЦП = 43313 мс, затраченное время = 44118 мс.

(затронуто строк: 22250)
Таблица "InvoiceLines". Сканирований 1, логических операций чтения 5003, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Invoices". Сканирований 1, логических операций чтения 11400, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Worktable". Сканирований 0, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Worktable". Сканирований 0, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Customers". Сканирований 1, логических операций чтения 42, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.

 Время работы SQL Server:
   Время ЦП = 234 мс, затраченное время = 618 мс.

Время выполнения: 2023-12-26T17:54:49.6156003+03:00
*/

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/
SELECT *
from (
SELECT row_number() OVER (partition by tbl.MM order by tbl.Count_MM desc) RN, tbl.*
FROM 
	(
	SELECT distinct datepart(YYYY, sInvoices.InvoiceDate) YY, datepart(MM, sInvoices.InvoiceDate) MM, sInvoiceLines.StockItemID,
		SUM(Quantity) OVER (PARTITION BY datepart(MM, sInvoices.InvoiceDate), sInvoiceLines.StockItemID) Count_MM 
	FROM Sales.Invoices as sInvoices
		JOIN Sales.InvoiceLines sInvoiceLines
			ON sInvoiceLines.InvoiceID = sInvoices.InvoiceID
	WHERE datepart(YYYY, sInvoices.InvoiceDate) = 2016 --and datepart(MM, sInvoices.InvoiceDate)=1 
	
	) AS tbl
join Warehouse.StockItems wStockItems on wStockItems.StockItemID = tbl.StockItemID
) as tbl1
WHERE RN <=2
order by MM



/*Функции одним запросом
 Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

SELECT StockItemID, StockItemName, ISNULL(Brand, 'No Brand'), UnitPrice,
ROW_NUMBER() OVER (PARTITION BY LEFT(StockItemName, 1) ORDER BY StockItemName) AS Rn, 
COUNT(*) OVER () AS Cnt,
COUNT(*) OVER (PARTITION BY LEFT(StockItemName, 1)) AS Cnt_name,
LEAD(StockItemID) OVER (ORDER BY StockItemName) as Follow, 
LAG(StockItemID) OVER (ORDER BY StockItemName) as Prev,
LAG(StockItemName, 2, 'No items') OVER (ORDER BY StockItemName) as Prev_2, TypicalWeightPerUnit,
NTILE(30) OVER (ORDER BY TypicalWeightPerUnit) AS GroupNumber
FROM [Warehouse].[StockItems] 
ORDER BY GroupNumber, TypicalWeightPerUnit

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

SELECT top(1) with ties 
	 sInvoices.OrderID, aPeople.PersonID, aPeople.FullName, sCustomers.CustomerID, sCustomers.CustomerName, sInvoices.InvoiceDate, trans.TransactionAmount

	FROM Sales.Invoices as sInvoices 
		JOIN Sales.CustomerTransactions as trans ON sInvoices.InvoiceID = trans.InvoiceID
		JOIN [Sales].[Customers] as sCustomers on sCustomers.CustomerID = sInvoices.CustomerID
		JOIN [Application].[People] as aPeople on aPeople.PersonID = sInvoices.SalespersonPersonID 
order by ROW_NUMBER() OVER (PARTITION BY aPeople.PersonID ORDER BY sInvoices.InvoiceDate DESC, trans.TransactionAmount DESC);

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

SELECT CustomerID, CustomerName, max(StockItemID), UnitPrice, Max(InvoiceDate)
from (
	SELECT  sInvoices.CustomerID, sCustomers.CustomerName, sInvoiceLines.StockItemID, sInvoiceLines.UnitPrice, sInvoices.InvoiceDate,
		DENSE_RANK() OVER (PARTITION BY sInvoices.CustomerID ORDER BY sInvoiceLines.UnitPrice DESC) as rang
	FROM Sales.Invoices as sInvoices
		JOIN Sales.InvoiceLines sInvoiceLines
			ON sInvoiceLines.InvoiceID = sInvoices.InvoiceID
		JOIN Sales.Customers as sCustomers
			ON sCustomers.CustomerID = sInvoices.CustomerID
	 
	
	) AS tbl
WHERE tbl.rang <=2
GROUP BY CustomerID, CustomerName, UnitPrice
ORDER BY CustomerID, CustomerName, UnitPrice desc


--Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 