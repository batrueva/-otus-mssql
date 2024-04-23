/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/

-- Переменная, в которую считаем XML-файл
DECLARE @xmlDocument XML;

-- Считываем XML-файл в переменную
SELECT @xmlDocument = BulkColumn
FROM OPENROWSET
(BULK 'D:\Otus MS SQL Serve Dev\Lesson10\hw\StockItems.xml', 
 SINGLE_CLOB)
AS data;

-- Проверяем, что в @xmlDocument
SELECT @xmlDocument AS [@xmlDocument];

DECLARE @docHandle INT;
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument;

-- docHandle - это просто число
SELECT @docHandle AS docHandle;
--Сделать два варианта: с помощью OPENXML и через XQuery.
--1. с помощью OPENXML
SELECT *
FROM OPENXML(@docHandle, N'/StockItems/Item')
WITH ( 
	StockItemName NVARCHAR(100) '@Name'
	, SupplierID int 'SupplierID'
	, UnitPackageID int 'Package/UnitPackageID'
	, OuterPackageID int 'Package/OuterPackageID'
	, QuantityPerOuter int 'Package/QuantityPerOuter'
	, TypicalWeightPerUnit decimal(18,3) 'Package/TypicalWeightPerUnit'
	, LeadTimeDays int 'LeadTimeDays'
	, IsChillerStock bit 'IsChillerStock'
	, TaxRate decimal(18,3) 'TaxRate'
	, UnitPrice decimal(18,3) 'UnitPrice'
);
	MERGE  [Warehouse].[StockItems] AS target 
	USING (SELECT *
			FROM OPENXML(@docHandle, N'/StockItems/Item')
			WITH ( 
				StockItemName NVARCHAR(100) '@Name'
				, SupplierID int 'SupplierID'
				, UnitPackageID int 'Package/UnitPackageID'
				, OuterPackageID int 'Package/OuterPackageID'
				, QuantityPerOuter int 'Package/QuantityPerOuter'
				, TypicalWeightPerUnit decimal(18,3) 'Package/TypicalWeightPerUnit'
				, LeadTimeDays int 'LeadTimeDays'
				, IsChillerStock bit 'IsChillerStock'
				, TaxRate decimal(18,3) 'TaxRate'
				, UnitPrice decimal(18,3) 'UnitPrice'
			)
		) 		AS source (StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice) 
		ON
	 (target.StockItemName = source.StockItemName) 
	WHEN MATCHED 
		THEN UPDATE SET SupplierID = source.SupplierID,
						UnitPackageID = source.UnitPackageID,
						OuterPackageID = source.OuterPackageID,
						QuantityPerOuter = source.QuantityPerOuter,
						TypicalWeightPerUnit = source.TypicalWeightPerUnit,
						LeadTimeDays = source.LeadTimeDays,
						IsChillerStock = source.IsChillerStock,
						TaxRate = source.TaxRate,
						UnitPrice = source.UnitPrice,
						LastEditedBy = 1
	WHEN NOT MATCHED 
		THEN INSERT (StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice, LastEditedBy) 
			VALUES (source.StockItemName, source.SupplierID, source.UnitPackageID, source.OuterPackageID, source.QuantityPerOuter, source.TypicalWeightPerUnit, source.LeadTimeDays, source.IsChillerStock, source.TaxRate, source.UnitPrice, 1) 
	OUTPUT deleted.*, $action, inserted.*;

EXEC sp_xml_removedocument @docHandle;

---XQuery
DECLARE @x XML;
SET @x = (SELECT * FROM OPENROWSET (BULK 'D:\Otus MS SQL Serve Dev\Lesson10\hw\StockItems.xml', SINGLE_BLOB)  AS d);

SELECT  
  si.Item.value('(@Name)[1]', 'varchar(100)') AS [Name],
  si.Item.value('(SupplierID)[1]', 'int') AS [SupplierID],
  si.Item.value('(Package/UnitPackageID)[1]', 'int') AS [UnitPackageID],
  si.Item.value('(Package/OuterPackageID)[1]', 'int') AS [OuterPackageID],
  si.Item.value('(Package/QuantityPerOuter)[1]', 'int') AS [QuantityPerOuter],
  si.Item.value('(Package/TypicalWeightPerUnit)[1]', 'decimal(18,3)') AS [QuantityPerOuter],
  si.Item.value('(LeadTimeDays)[1]', 'int') AS [LeadTimeDays],
  si.Item.value('(IsChillerStock)[1]', 'bit') AS [IsChillerStock],
  si.Item.value('(TaxRate)[1]', 'decimal(18,3)') AS TaxRate,
  si.Item.value('(UnitPrice)[1]', 'decimal(18,3)') AS UnitPrice,
  si.Item.query('.')
FROM @x.nodes('/StockItems/Item') AS si(Item);
GO

DECLARE @x XML;
SET @x = (SELECT * FROM OPENROWSET (BULK 'D:\Otus MS SQL Serve Dev\Lesson10\hw\StockItems.xml', SINGLE_BLOB)  AS d);

	MERGE  [Warehouse].[StockItems] AS target 
	USING (SELECT  
			  si.Item.value('(@Name)[1]', 'varchar(100)') AS [Name],
			  si.Item.value('(SupplierID)[1]', 'int') AS [SupplierID],
			  si.Item.value('(Package/UnitPackageID)[1]', 'int') AS [UnitPackageID],
			  si.Item.value('(Package/OuterPackageID)[1]', 'int') AS [OuterPackageID],
			  si.Item.value('(Package/QuantityPerOuter)[1]', 'int') AS [QuantityPerOuter],
			  si.Item.value('(Package/TypicalWeightPerUnit)[1]', 'decimal(18,3)') AS [TypicalWeightPerUnit],
			  si.Item.value('(LeadTimeDays)[1]', 'int') AS [LeadTimeDays],
			  si.Item.value('(IsChillerStock)[1]', 'bit') AS [IsChillerStock],
			  si.Item.value('(TaxRate)[1]', 'decimal(18,3)') AS TaxRate,
			  si.Item.value('(UnitPrice)[1]', 'decimal(18,3)') AS UnitPrice
			FROM @x.nodes('/StockItems/Item') AS si(Item)
			) 
		AS source (StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice) 
		ON
	 (target.StockItemName = source.StockItemName) 
	WHEN MATCHED 
		THEN UPDATE SET SupplierID = source.SupplierID,
						UnitPackageID = source.UnitPackageID,
						OuterPackageID = source.OuterPackageID,
						QuantityPerOuter = source.QuantityPerOuter,
						TypicalWeightPerUnit = source.TypicalWeightPerUnit,
						LeadTimeDays = source.LeadTimeDays,
						IsChillerStock = source.IsChillerStock,
						TaxRate = source.TaxRate,
						UnitPrice = source.UnitPrice,
						LastEditedBy = 1
	WHEN NOT MATCHED 
		THEN INSERT (StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice, LastEditedBy) 
			VALUES (source.StockItemName, source.SupplierID, source.UnitPackageID, source.OuterPackageID, source.QuantityPerOuter, source.TypicalWeightPerUnit, source.LeadTimeDays, source.IsChillerStock, source.TaxRate, source.UnitPrice, 1) 
	OUTPUT deleted.*, $action, inserted.*;

/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

SELECT StockItemName AS [@Name]
, SupplierID AS [SupplierID]
, UnitPackageID AS [Package/UnitPackageID]
, OuterPackageID AS [Package/OuterPackageID]
, QuantityPerOuter AS [Package/QuantityPerOuter]
, TypicalWeightPerUnit AS [Package/TypicalWeightPerUnit]
, LeadTimeDays AS [LeadTimeDays]
, IsChillerStock AS [IsChillerStock]
, TaxRate AS [TaxRate]
, UnitPrice AS [UnitPrice]
FROM Warehouse.StockItems
FOR XML PATH('Item'), ROOT('StockItems');
GO

/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

   
  SELECT StockItemID
	, StockItemName
   , JSON_VALUE(CustomFields, '$.CountryOfManufacture') AS CountryOfManufacture
   , JSON_VALUE(CustomFields, '$.Tags[0]') AS FirstTag
	FROM [WideWorldImporters].[Warehouse].[StockItems]

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

  SELECT StockItemID
	, StockItemName
	,JSON_QUERY(CustomFields, '$.Tags') AS Tags
	FROM [WideWorldImporters].[Warehouse].[StockItems]
	CROSS APPLY OPENJSON(CustomFields, '$.Tags') tt
	where tt.value = 'Vintage'
