--Включаем выполнение пользовательских сборок
SP_CONFIGURE 'clr enabled', 1
GO
RECONFIGURE
GO
 
--Создаём тестовую БД для демострации
CREATE DATABASE TestDB
GO
 /*
DROP FUNCTION IF EXISTS dbo.[LoadFile];
GO
DROP FUNCTION IF EXISTS dbo.[LoadCompressFile];
GO
DROP FUNCTION IF EXISTS dbo.[SaveDecompressFile];
GO
DROP FUNCTION IF EXISTS dbo.[SaveFile];
GO
DROP ASSEMBLY [FileCompressCLR]

 */
--Модули базы данных (например, пользовательские функции или хранимые процедуры),
--которые используют контекст олицетворения, могут обращаться к ресурсам,
--находящимся вне базы данных.
ALTER DATABASE TestDB SET TRUSTWORTHY ON
GO
 
--Переходим в нашу БД
USE TestDB
GO
 
--Регистрируем сборку
CREATE ASSEMBLY FileCompressCLR
FROM 'D:\Otus MS SQL Serve Dev\Lesson21\pdf\DemoProject.dll'
WITH PERMISSION_SET = UNSAFE;
GO
 
CREATE ASSEMBLY [System.Drawing]   
FROM 'D:\Otus MS SQL Serve Dev\Lesson21\pdf\System.Drawing.dll'  
WITH PERMISSION_SET = UNSAFE
GO
--Создаём функцию загрузки обычного файла
CREATE FUNCTION [LoadFile]
(
@FileName nvarchar(MAX)
)
RETURNS varbinary(MAX)
AS
EXTERNAL NAME [FileCompressCLR].[FileCompressCLR].[LoadFile];
GO
 
--Создаём функцию загрузки файла + его компрессия
CREATE FUNCTION [LoadCompressFile]
(
@FileName nvarchar(MAX)
)
RETURNS varbinary(MAX)
AS
EXTERNAL NAME [FileCompressCLR].[FileCompressCLR].[LoadCompressFile];
GO
 
--Создаём функцию выгрузки обычного файла
CREATE FUNCTION [SaveFile]
(
@FileName nvarchar(MAX),
@CompressedFile varbinary(MAX)
)
RETURNS nvarchar(10)
AS
EXTERNAL NAME [FileCompressCLR].[FileCompressCLR].[SaveFile];
GO
 
--Создаём функцию выгрузки сжатого файла
CREATE FUNCTION [SaveDecompressFile]
(
@FileName nvarchar(MAX),
@CompressedFile varbinary(MAX)
)
RETURNS nvarchar(10)
AS
EXTERNAL NAME [FileCompressCLR].[FileCompressCLR].[SaveDecompressFile];
GO