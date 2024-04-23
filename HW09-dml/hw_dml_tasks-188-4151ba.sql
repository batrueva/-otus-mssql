/*Занятие "09 - Операторы изменения данных". 

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/
USE WideWorldImporters
GO

INSERT INTO Sales.Customers
           (
           CustomerName 
           ,BillToCustomerID
           ,CustomerCategoryID
           ,BuyingGroupID
           ,PrimaryContactPersonID
           ,AlternateContactPersonID
           ,DeliveryMethodID
           ,DeliveryCityID
           ,PostalCityID
           ,CreditLimit
           ,AccountOpenedDate
           ,StandardDiscountPercentage
           ,IsStatementSent
           ,IsOnCreditHold
           ,PaymentDays
           ,PhoneNumber
           ,FaxNumber
           ,DeliveryRun
           ,RunPosition
           ,WebsiteURL
           ,DeliveryAddressLine1
           ,DeliveryAddressLine2
           ,DeliveryPostalCode
           ,PostalAddressLine1
           ,PostalAddressLine2
           ,PostalPostalCode
           ,LastEditedBy
		   )
     VALUES

('2023 Tailspin Toys (Head Office)',		1,	3,	1,	1001,	1002,	3,	19586,	19586,	NULL,	'2013-01-01',	0.000,	0,	0,	7,	'(308) 555-0100',	'(308) 555-0101','', '','http://www.tailspintoys.com',				'Shop 38',	'1877 Mittal Road',		'90410',	'PO Box 8975',	'Ribeiroville',	'90410', 	1),
('2023 Tailspin Toys (Sylvanite, MT)',		1,	3,	1,	1003,	1004,	3,	33475,	33475,	NULL,	'2013-01-01',	0.000,	0,	0,	7,	'(406) 555-0100',	'(406) 555-0101','', '','http://www.tailspintoys.com/Sylvanite',	'Shop 245',	'705 Dita Lane',		'90216',	'PO Box 259',	'Jogiville',	'90216',	1),
('2023 Tailspin Toys (Peeples Valley, AZ)',	1,	3,	1,	1005,	1006,	3,	26483,	26483,	NULL,	'2013-01-01',	0.000,	0,	0,	7,	'(480) 555-0100',	'(480) 555-0101','', '','http://www.tailspintoys.com/PeeplesValley','Unit 217',	'1970 Khandke Road',	'90205',	'PO Box 3648',	'Lucescuville',	'90205',	1),	
('2023 Tailspin Toys (Medicine Lodge, KS)',	1,	3,	1,	1007,	1008,	3,	21692,	21692,	NULL,	'2013-01-01',	0.000,	0,	0,	7,	'(316) 555-0100',	'(316) 555-0101','', '','http://www.tailspintoys.com/MedicineLodge','Suite 164','967 Riutta Boulevard',	'90152',	'PO Box 5065',	'Maciasville',	'90152',	1),	
('2023 Tailspin Toys (Gasport, NY)',		1,	3,	1,	1009,	1010,	3,	12748,	12748,	NULL,	'2013-01-01',	0.000,	0,	0,	7,	'(212) 555-0100',	'(212) 555-0101','', '','http://www.tailspintoys.com/Gasport',		'Unit 176',	'1674 Skujins Boulevard','90261',	'PO Box 6294',	'Kellnerovaville','90261',	1)
GO
select *
from Sales.Customers where CustomerName like '%2023%';

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE FROM Sales.Customers
WHERE CustomerName = '2023 Tailspin Toys (Gasport, NY)';


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE Sales.Customers
SET CustomerCategoryID = 4
WHERE CustomerName = '2023 Tailspin Toys (Medicine Lodge, KS)'

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

MERGE Sales.Customers AS target 
	USING (SELECT replace(CustomerName, '2023', '2024') as CN_2024 
	       ,BillToCustomerID
           ,CustomerCategoryID
           ,BuyingGroupID
           ,PrimaryContactPersonID
           ,AlternateContactPersonID
           ,DeliveryMethodID
           ,DeliveryCityID
           ,PostalCityID
           ,CreditLimit
           ,getdate() as AccountOpenedDate
           ,10.000 as StandardDiscountPercentage
           ,IsStatementSent
           ,IsOnCreditHold
           ,PaymentDays
           ,PhoneNumber
           ,FaxNumber
           ,DeliveryRun
           ,RunPosition
           ,WebsiteURL
           ,DeliveryAddressLine1
           ,DeliveryAddressLine2
           ,DeliveryPostalCode
           ,PostalAddressLine1
           ,PostalAddressLine2
           ,PostalPostalCode
           ,LastEditedBy
		FROM Sales.Customers 
		WHERE  CustomerName like '2023%'
		union all
		SELECT CustomerName
	       ,BillToCustomerID +1
           ,CustomerCategoryID+1
           ,BuyingGroupID+1
           ,PrimaryContactPersonID
           ,AlternateContactPersonID
           ,DeliveryMethodID
           ,DeliveryCityID
           ,PostalCityID
           ,CreditLimit
           ,AccountOpenedDate
           ,15.000 as StandardDiscountPercentage
           ,IsStatementSent
           ,IsOnCreditHold
           ,PaymentDays
           ,PhoneNumber
           ,FaxNumber
           ,DeliveryRun
           ,RunPosition
           ,WebsiteURL
           ,DeliveryAddressLine1
           ,DeliveryAddressLine2
           ,DeliveryPostalCode
           ,PostalAddressLine1
           ,PostalAddressLine2
           ,PostalPostalCode
           ,LastEditedBy
		FROM Sales.Customers 
			WHERE  CustomerName like '2023%'			
		) 
		AS source (CN_2024 
           ,BillToCustomerID
           ,CustomerCategoryID
           ,BuyingGroupID
           ,PrimaryContactPersonID
           ,AlternateContactPersonID
           ,DeliveryMethodID
           ,DeliveryCityID
           ,PostalCityID
           ,CreditLimit
           ,AccountOpenedDate
           ,StandardDiscountPercentage
           ,IsStatementSent
           ,IsOnCreditHold
           ,PaymentDays
           ,PhoneNumber
           ,FaxNumber
           ,DeliveryRun
           ,RunPosition
           ,WebsiteURL
           ,DeliveryAddressLine1
           ,DeliveryAddressLine2
           ,DeliveryPostalCode
           ,PostalAddressLine1
           ,PostalAddressLine2
           ,PostalPostalCode
           ,LastEditedBy) 
		ON
	 (target.CustomerName = source.CN_2024) 
	WHEN MATCHED 
		THEN UPDATE SET BillToCustomerID = source.BillToCustomerID,
						CustomerCategoryID = source.CustomerCategoryID,
						BuyingGroupID = source.BuyingGroupID,
						StandardDiscountPercentage = source.StandardDiscountPercentage
	WHEN NOT MATCHED 
		THEN INSERT ( CustomerName 
           ,BillToCustomerID
           ,CustomerCategoryID
           ,BuyingGroupID
           ,PrimaryContactPersonID
           ,AlternateContactPersonID
           ,DeliveryMethodID
           ,DeliveryCityID
           ,PostalCityID
           ,CreditLimit
           ,AccountOpenedDate
           ,StandardDiscountPercentage
           ,IsStatementSent
           ,IsOnCreditHold
           ,PaymentDays
           ,PhoneNumber
           ,FaxNumber
           ,DeliveryRun
           ,RunPosition
           ,WebsiteURL
           ,DeliveryAddressLine1
           ,DeliveryAddressLine2
           ,DeliveryPostalCode
           ,PostalAddressLine1
           ,PostalAddressLine2
           ,PostalPostalCode
           ,LastEditedBy) 
			VALUES (source.CN_2024
           ,source.BillToCustomerID
           ,source.CustomerCategoryID
           ,source.BuyingGroupID
           ,source.PrimaryContactPersonID
           ,source.AlternateContactPersonID
           ,source.DeliveryMethodID
           ,source.DeliveryCityID
           ,source.PostalCityID
           ,source.CreditLimit
           ,source.AccountOpenedDate
           ,source.StandardDiscountPercentage
           ,source.IsStatementSent
           ,source.IsOnCreditHold
           ,source.PaymentDays
           ,source.PhoneNumber
           ,source.FaxNumber
           ,source.DeliveryRun
           ,source.RunPosition
           ,source.WebsiteURL
           ,source.DeliveryAddressLine1
           ,source.DeliveryAddressLine2
           ,source.DeliveryPostalCode
           ,source.PostalAddressLine1
           ,source.PostalAddressLine2
           ,source.PostalPostalCode
           ,source.LastEditedBy) 
	OUTPUT deleted.*, $action, inserted.*;

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

SELECT @@SERVERNAME

exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.OrderLines" out  "D:\Otus MS SQL Serve Dev\Lesson9\OrderLines1.txt" -T -w -t"@&$1&" -S DESKTOP-0P3RUG1\SQL2022'
-----------
drop table if exists [Sales].[OrderLines_demo]

CREATE TABLE [Sales].[OrderLines_demo](
	[OrderLineID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[PackageTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[PickedQuantity] [int] NOT NULL,
	[PickingCompletedWhen] [datetime2](7) NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Sales_OrderLines_demo] PRIMARY KEY CLUSTERED 
(
	[OrderLineID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [USERDATA]
) ON [USERDATA]
GO
----
BULK INSERT [WideWorldImporters].[Sales].[OrderLines_demo]
  FROM "D:\Otus MS SQL Serve Dev\Lesson9\OrderLines1.txt"
   WITH 
	(
	BATCHSIZE = 1000, 
	DATAFILETYPE = 'widechar',
	FIELDTERMINATOR = '@&$1&',
	ROWTERMINATOR ='\n',
	KEEPNULLS,
	TABLOCK        
	);



select Count(*) from [Sales].[OrderLines_demo];

TRUNCATE TABLE [Sales].[OrderLines_demo];