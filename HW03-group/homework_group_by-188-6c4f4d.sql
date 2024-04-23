/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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

USE WideWorldImporters;

/*
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT datepart(YYYY,
		 sInvoices.InvoiceDate) AS ySales,
		 datepart(MM,
		 sInvoices.InvoiceDate) AS mSales,
		 AVG(wStockItems.UnitPrice) AS avd_Price,
		 sum(sInvoiceLines.ExtendedPrice) AS sum_Price
FROM Sales.Invoices sInvoices
LEFT JOIN Sales.InvoiceLines sInvoiceLines
	ON sInvoiceLines.InvoiceID = sInvoices.InvoiceID
LEFT JOIN Warehouse.StockItems wStockItems
	ON wStockItems.StockItemID = sInvoiceLines.StockItemID
WHERE datepart(YYYY, sInvoices.InvoiceDate) = 2015
GROUP BY  datepart(YYYY, sInvoices.InvoiceDate), datepart(MM, sInvoices.InvoiceDate)
ORDER BY  ySales, mSales


/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
Сортировка по году и месяцу.

*/

SELECT datepart(YYYY,
		 sInvoices.InvoiceDate) AS ySales,
		 datepart(MM,
		 sInvoices.InvoiceDate) AS mSales,
		 sum(sInvoiceLines.ExtendedPrice) AS sum_Price
FROM Sales.Invoices sInvoices
LEFT JOIN Sales.InvoiceLines sInvoiceLines
	ON sInvoiceLines.InvoiceID = sInvoices.InvoiceID
WHERE datepart(YYYY, sInvoices.InvoiceDate) = 2015
GROUP BY  datepart(YYYY, sInvoices.InvoiceDate), datepart(MM, sInvoices.InvoiceDate)
HAVING sum(sInvoiceLines.ExtendedPrice) > 4600000
ORDER BY  ySales, mSales

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT datepart(YYYY,
		 sInvoices.InvoiceDate) AS ySales,
		 datepart(MM,
		 sInvoices.InvoiceDate) AS mSales,
		 wStockItems.StockItemName AS stock_name,
		 sum(sInvoiceLines.ExtendedPrice) AS sum_Price,
		 min(sInvoices.InvoiceDate) AS min_date,
		 sum(sInvoiceLines.Quantity) AS count_Price
FROM Sales.Invoices sInvoices
LEFT JOIN Sales.InvoiceLines sInvoiceLines
	ON sInvoiceLines.InvoiceID = sInvoices.InvoiceID
LEFT JOIN Warehouse.StockItems wStockItems
	ON wStockItems.StockItemID = sInvoiceLines.StockItemID 
GROUP BY  datepart(YYYY, sInvoices.InvoiceDate), datepart(MM, sInvoices.InvoiceDate), wStockItems.StockItemName
HAVING sum(sInvoiceLines.Quantity) < 50
ORDER BY  ySales, mSales

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
4. Написать второй запрос ("Отобразить все месяцы, где общая сумма продаж превысила 4 600 000") 
за период 2015 год так, чтобы месяц, в котором сумма продаж была меньше указанной суммы также отображался в результатах,
но в качестве суммы продаж было бы '-'.
Сортировка по году и месяцу.

Пример результата:
-----+-------+------------
Year | Month | SalesTotal
-----+-------+------------
2015 | 1     | -
2015 | 2     | -
2015 | 3     | -
2015 | 4     | 5073264.75
2015 | 5     | -
2015 | 6     | -
2015 | 7     | 5155672.00
2015 | 8     | -
2015 | 9     | 4662600.00
2015 | 10    | -
2015 | 11    | -
2015 | 12    | -

*/
SELECT sYear, sMonth, max(sum_Price)
FROM(
	SELECT sYear, sMonth , sum_Price
	FROM (VALUES
		(2015, 1, '-'),(2015, 2, '-'),(2015, 3, '-'),(2015, 4, '-'), (2015, 5, '-'), (2015, 6, '-'),
		(2015, 7, '-'),(2015, 8, '-'),(2015, 9, '-'),(2015, 10, '-'),(2015, 11, '-'),(2015, 12, '-')
	) AS cal (sYear, sMonth ,sum_Price)

	UNION ALL

	SELECT datepart(YYYY, sInvoices.InvoiceDate),
		 datepart(MM, sInvoices.InvoiceDate),
		 CAST(sum(sInvoiceLines.ExtendedPrice) AS NCHAR(10)) AS sum_Price 
	FROM Sales.Invoices sInvoices
	LEFT JOIN Sales.InvoiceLines sInvoiceLines
		ON sInvoiceLines.InvoiceID = sInvoices.InvoiceID
	WHERE datepart(YYYY, sInvoices.InvoiceDate) = 2015
	GROUP BY  datepart(YYYY, sInvoices.InvoiceDate), datepart(MM, sInvoices.InvoiceDate)
	HAVING sum(sInvoiceLines.ExtendedPrice) > 4600000
) res
GROUP BY  sYear, sMonth
ORDER BY  sYear, sMonth