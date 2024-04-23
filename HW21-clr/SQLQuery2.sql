--�������� ���������� ���������������� ������
SP_CONFIGURE 'clr enabled', 1
GO
RECONFIGURE
GO
 
--������ �������� �� ��� �����������
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
--������ ���� ������ (��������, ���������������� ������� ��� �������� ���������),
--������� ���������� �������� �������������, ����� ���������� � ��������,
--����������� ��� ���� ������.
ALTER DATABASE TestDB SET TRUSTWORTHY ON
GO
 
--��������� � ���� ��
USE TestDB
GO
 
--������������ ������
CREATE ASSEMBLY FileCompressCLR
FROM 'D:\Otus MS SQL Serve Dev\Lesson21\pdf\DemoProject.dll'
WITH PERMISSION_SET = UNSAFE;
GO
 
CREATE ASSEMBLY [System.Drawing]   
FROM 'D:\Otus MS SQL Serve Dev\Lesson21\pdf\System.Drawing.dll'  
WITH PERMISSION_SET = UNSAFE
GO
--������ ������� �������� �������� �����
CREATE FUNCTION [LoadFile]
(
@FileName nvarchar(MAX)
)
RETURNS varbinary(MAX)
AS
EXTERNAL NAME [FileCompressCLR].[FileCompressCLR].[LoadFile];
GO
 
--������ ������� �������� ����� + ��� ����������
CREATE FUNCTION [LoadCompressFile]
(
@FileName nvarchar(MAX)
)
RETURNS varbinary(MAX)
AS
EXTERNAL NAME [FileCompressCLR].[FileCompressCLR].[LoadCompressFile];
GO
 
--������ ������� �������� �������� �����
CREATE FUNCTION [SaveFile]
(
@FileName nvarchar(MAX),
@CompressedFile varbinary(MAX)
)
RETURNS nvarchar(10)
AS
EXTERNAL NAME [FileCompressCLR].[FileCompressCLR].[SaveFile];
GO
 
--������ ������� �������� ������� �����
CREATE FUNCTION [SaveDecompressFile]
(
@FileName nvarchar(MAX),
@CompressedFile varbinary(MAX)
)
RETURNS nvarchar(10)
AS
EXTERNAL NAME [FileCompressCLR].[FileCompressCLR].[SaveDecompressFile];
GO