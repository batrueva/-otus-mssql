use [Project_OTUS];

--создадим файловую группу
ALTER DATABASE [Project_OTUS] ADD FILEGROUP [LicArchiv]
GO
ALTER DATABASE [Project_OTUS] ADD FILEGROUP [Lic]
GO
--добавляем файл БД
ALTER DATABASE [Project_OTUS] ADD FILE 
( NAME = N'LicForMonth', FILENAME = N'D:\Otus MS SQL Serve Dev\Lesson33\LicForMonth.ndf' , 
SIZE = 1097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [LicArchiv] --Lic
GO
ALTER DATABASE [Project_OTUS] ADD FILE 
( NAME = N'Lic', FILENAME = N'D:\Otus MS SQL Serve Dev\Lesson33\Lic.ndf' , 
SIZE = 1097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [Lic] --Lic
GO
--создаем функцию партиционирования по годам начиная с начала ведения учета в базе (Lic)
CREATE PARTITION FUNCTION [fnYearPartition](int) AS RANGE RIGHT FOR VALUES
(2023*12+1);																																																									
GO
--создаем функцию партиционирования по годам начиная с начала ведения учета в базе (LicArhiv)
--добавляем пустую секцию справа - пригодится при организации «скользящего окна», Split и merge непустых секций – это всегда больно, по возможности нужно этого избегать.

CREATE PARTITION FUNCTION [fnYearPartitionArh](int) AS RANGE RIGHT FOR VALUES
(2021*12+1, 2022*12+1, 2023*12+1, 2024*12+1, 2025*12+1);																																																									
GO

-- партиционируем, используя созданную нами функцию
CREATE PARTITION SCHEME [schmYearPartition2] AS PARTITION [fnYearPartition] 
TO ([LicArchiv], [Lic])
GO
CREATE PARTITION SCHEME [schmYearPartition3] AS PARTITION [fnYearPartitionArh] 
ALL TO ([LicArchiv])
GO
-- на существующей таблице удалить кластерный индекс 
-- и создать новый кластерный индекс с ключом секционирования
-- посмотрим через свойства таблицы -> хранилище
ALTER TABLE [dbo].[Lic] ADD CONSTRAINT [PK_Lic] 
PRIMARY KEY CLUSTERED  ([lic_id], fmonth)
 ON [schmYearPartition2](fmonth);

--данные из таблицы Lic мы каждыq год архивируем – убираем старые данные и добавляем секцию для следующего года
-- 1. Добавим секцию для данных с 01.01.2025 
-- 2. Создаем архивную таблицу
-- 3. Переключим секцию с данными до 01.01.2024 в  архивную таблицу
-- 4. Избавимся от пустой секции
--октрываем новый период 2025
--Объявляем, что новая секция будет создана в файловой группе 
alter partition scheme schmYearPartition1
next used [LicArchiv];
--И меняем функцию секционирования, добавляя новую границу:
alter partition function [fnYearPartition]() split range (2023*12+1);

alter partition scheme schmYearPartition1
next used [Lic];
alter partition function [fnYearPartition]() split range (2025*12+1);
--2023 год скидываем в архив
alter partition scheme schmYearPartition1
next used [LicArchiv];
alter partition function [fnYearPartition]() merge range (2023*12+1);
--Для переключения (switch) секции в таблицу и обратно, нам требуется пустая таблица [LicArchiv],
--в которой созданы все те же ограничения и индексы, что и на нашей секционированной таблице.
--Таблица должна быть в той же файловой группе, что и секция, которую мы хотим туда «переключить».
--Архивная секция лежит в [LicArchiv], поэтому создаём таблицу и кластерный индекс там же:
CREATE TABLE [dbo].[LicArhiv](
	[lic_id] [int] IDENTITY(1,1) NOT NULL,
	[pid] [int] NOT NULL,
	[prid] [int] NOT NULL,
	[tmonth] [tinyint] NOT NULL,
	[tyear] [smallint] NOT NULL,
	[cmonth] [smallint] NOT NULL,
	[code_pay] [smallint] NOT NULL,
	[summa] [numeric](19, 4) NOT NULL,
	[percent] [numeric](19, 8) NOT NULL,
	[days] [numeric](9, 4) NOT NULL,
	[hours] [numeric](19, 4) NOT NULL,
	[firm_id] [int] NOT NULL,
	[mdate] [datetime] NOT NULL,
	[uname] [varchar](128) NOT NULL,
	[fmonth] [int] NOT NULL,
 CONSTRAINT [PK_LicArh] PRIMARY KEY CLUSTERED 
(
	[lic_id] ASC,
	[fmonth] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [schmYearPartition3](fmonth)
) ON [LicArchiv]
GO
/****** Object:  Index [PK_LicArh]    Script Date: 31.03.2024 12:39:09 ******/
ALTER TABLE [dbo].[LicArhiv] ADD  CONSTRAINT [PK_LicArh] PRIMARY KEY CLUSTERED 
(
	[lic_id] ASC,
	[fmonth] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [schmYearPartition3](fmonth)
GO
--пробуем выполнить переключение секции
alter table Lic switch partition 3 to [LicArhiv] partition 3;

--убираем лишние секции в Lic
alter partition scheme schmYearPartition2
next used [LicArchiv];
alter partition function [fnYearPartition]() merge range (2022*12+1);

--По факту для расчета зарплаты нам нужен текущий год и предыдущий(для расчета среднего) в оперативной таблице Lic. В начале каждого 
--следующего года мы можем скидывать в архив уже не нужный предыдущий год. Так как данные в закрытом периоде не подлежат редактированию,
--можно отдельно настроить бэкап архивной файловой группы и  не тянуть их постоянно.



