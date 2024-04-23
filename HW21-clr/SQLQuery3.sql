--Создаём таблицу для демонстрации массовой вставки
CREATE TABLE Files
(
id int identity,
FileName nvarchar(max),
[File] varbinary (max) default null,
CompressFile varbinary(max) default null
)
 
--Вставка только названий с файлами
INSERT INTO Files (FileName)
SELECT 'C:\CLR\FileCompressCLR.dll'
UNION ALL
SELECT 'C:\CLR\Winter.jpg'
UNION ALL
SELECT 'C:\CLR\Test.txt'
 select *from files

--Загружаем сами бинарники
UPDATE Files
SET FileName = 'contract.pdf',
[File]=dbo.LoadFile('D:\Otus MS SQL Serve Dev\Lesson21\contract.pdf'),
[CompressFile]=dbo.LoadCompressFile('D:\Otus MS SQL Serve Dev\Lesson21\contract.pdf')
where id = 1

SELECT FileName,
dbo.SaveFile(replace('D:\Otus MS SQL Serve Dev\Lesson21\contract.pdf', '.','1.'), [File]),
dbo.SaveDecompressFile(replace('D:\Otus MS SQL Serve Dev\Lesson21\contract.pdf', '.','2.'), CompressFile)
FROM Files

select *
FROM Files