/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "18 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей разовой суммой покупки.
*/
USE WideWorldImporters;
IF OBJECT_ID (N'dbo.maxSumCustomer', N'FN') IS NOT NULL
DROP FUNCTION dbo.maxSumCustomer;
GO

CREATE FUNCTION maxSumCustomer
(
	
)
RETURNS nvarchar(100)
AS 
BEGIN
	-- Declare the return variable here
	DECLARE @ResultVar nvarchar(100)

	set @ResultVar = 
	(
	SELECT TOP 1 sCustomers.[CustomerName]
	FROM (
	select  sInvoices.CustomerID, SUM([ExtendedPrice]) summa
		from Sales.Invoices sInvoices
		left join Sales.InvoiceLines sInvoiceLines on sInvoiceLines.InvoiceID = sInvoices.InvoiceID
	GROUP BY sInvoices.CustomerID, sInvoiceLines.InvoiceID
	
	) as tResult
	left join Sales.Customers sCustomers on sCustomers.CustomerID =  tResult.CustomerID
	ORDER BY tResult.summa desc
	)
RETURN @ResultVar
END
GO

select [dbo].[maxSumCustomer]()
GO



/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE proc_get_Sum_CustId 
	@CustId int = NULL
	, @ResultVar decimal(19,2) = NULL output
/*WITH RECOMPILE*/ AS 

	SET NOCOUNT ON;
	IF @CustId IS NULL  
	BEGIN  
	   PRINT N'ОШИБКА: Неоходимо передать ид покупателя.'  
	   RETURN(1)  -- не обрабатываем дальше код. Команда Возврата
	END   
    -- Insert statements for procedure here
	set @ResultVar = 
	(select  SUM([ExtendedPrice]) summa
		from Sales.Invoices sInvoices
		left join Sales.InvoiceLines sInvoiceLines on sInvoiceLines.InvoiceID = sInvoices.InvoiceID
		WHERE sInvoices.CustomerID = @CustId
		
	
	)

GO
DECLARE @Result decimal(19,2);
exec dbo.proc_get_Sum_CustId 149, @Result output WITH RECOMPILE
select @Result;
/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].func_get_Sum_CustId
(
	@CustId int
)
RETURNS decimal(19,2)
AS 
BEGIN
	-- Declare the return variable here
	DECLARE @ResultVar decimal(19,2)

	set @ResultVar = 
	(
	select  SUM([ExtendedPrice]) summa
		from Sales.Invoices sInvoices
		left HASH join Sales.InvoiceLines sInvoiceLines on sInvoiceLines.InvoiceID = sInvoices.InvoiceID
		WHERE sInvoices.CustomerID = @CustId
	
	)
RETURN @ResultVar
END



DBCC FREEPROCCACHE;
GO
exec [dbo].[usp_ShowCache]
Go
set statistics io, time on
select [dbo].func_get_Sum_CustId(149)
GO


DECLARE @Result decimal(19,2);
exec dbo.proc_get_Sum_CustId 149, @Result output --with recompile
select @Result;
GO

/*
Когда SQL Server выполняет процедуры, значения всех используемых при компиляции параметров включаются в формируемый план запроса.
Если эти значения типичны для последующих вызовов процедуры, то компиляция и выполнение хранимой процедуры с этим планом запроса происходит быстрее.
В моем случае процедура выпоняется дольше, т.к. план запроса отличается от плана функции(скрин 3 и 4, 5). Производительность процедуры хуже(скрин 2) Если сделать план одинаковый с помощью хинта HESH в функции, то производительность примерно одинаковая.
По времени процедура выигрывает: скрин 6

*/

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

USE WideWorldImporters; 
IF OBJECT_ID (N'dbo.fGetOrderLines', N'IF') IS NOT NULL
    DROP FUNCTION dbo.fGetOrderLines;
GO
CREATE FUNCTION dbo.fGetOrderLines(@OrderID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT sOrderLines.[StockItemID], wStockItems.StockItemName,  sOrderLines.[Quantity], sOrderLines.[UnitPrice]
    FROM [Sales].[OrderLines] sOrderLines
	LEFT JOIN [Warehouse].[StockItems] wStockItems on wStockItems.StockItemID = sOrderLines.StockItemID
    WHERE sOrderLines.[OrderID] = @OrderID
);

--USE CROSS APPLY
DECLARE @OrderID INT = 100;
SELECT * FROM dbo.fGetOrderLines(@OrderID);

--Для каждой провинции вывести список городов
SELECT *
FROM [Sales].[Orders] sOrders
CROSS APPLY dbo.fGetOrderLines(sOrders.OrderID) sOrderLines
order by sOrderLines.StockItemName;

