CREATE DATABASE [Project_MSSQL1]
ON  PRIMARY 
( NAME = Project_MSSQL1, FILENAME = N'C:\Project_MSSQL\Project_MSSQL1.mdf' , 
	SIZE = 8MB , 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 65536KB )
 LOG ON 
( NAME = Project_MSSQL1_log, FILENAME = N'C:\Project_MSSQL\Project_MSSQL1_log.ldf' , 
	SIZE = 8MB , 
	MAXSIZE = 10GB , 
	FILEGROWTH = 65536KB )
GO
SET XACT_ABORT ON

BEGIN TRANSACTION NewBD

-- Физические лица
CREATE TABLE [Card] (
    [auto_card] int  NOT NULL ,
    [name] varchar(40)  NOT NULL ,
    [name_i] varchar(40)  NOT NULL ,
    [name_o] varchar(40)  NOT NULL ,
    [Full_Name] varchar(128)  NOT NULL ,
    [date_birth] datetime  NOT NULL ,
    [sex] tinyint  NOT NULL ,
    [SocNumber] varchar(15)  NOT NULL ,
    [INN] varchar(12)  NOT NULL ,
    [EMail] varchar(64)  NOT NULL ,
    [Passp_ser] varchar(10)  NOT NULL ,
    [Passp_num] varchar(16)  NOT NULL ,
    [Passp_date] datetime  NOT NULL ,
    [Adress1] varchar(255)  NOT NULL ,
    [Adress2] varchar(255)  NULL ,
    [mdate] datetime  NOT NULL ,
    [uname] varchar(128)  NOT NULL ,
    CONSTRAINT [PK_Card] PRIMARY KEY CLUSTERED (
        [auto_card] ASC
    ),
    CONSTRAINT [UK_Card_SocNumber] UNIQUE (
        [SocNumber]
    )
)

-- работники
-- одному физ. лицу может соотв. несколько работников 1 : N
-- одно физ. лицо может быть принято в разные фирмы
CREATE TABLE [People] (
    [pid] int  NOT NULL ,
    [auto_card] int  NOT NULL ,
    [id_firm] int  NOT NULL ,
    [in_date] datetime  NOT NULL ,
    [out_date] datetime  NOT NULL ,
    [ref_num] int  NOT NULL ,
    [mdate] datetime  NOT NULL ,
    [uname] varchar(128)  NOT NULL ,
    CONSTRAINT [PK_People] PRIMARY KEY CLUSTERED (
        [pid] ASC
    )
)

-- фирмы
CREATE TABLE [Setup] (
    [id_firm] int  NOT NULL ,
    [Name] varchar(255)  NOT NULL ,
    [INN] varchar(12)  NOT NULL ,
    [Phone] varchar(32)  NOT NULL ,
    [EMail] varchar(64)  NULL ,
    [Adress1] varchar(255)  NOT NULL ,
    [Adress2] varchar(255)  NULL ,
    [Director_pid] int  NOT NULL ,
    CONSTRAINT [PK_Setup] PRIMARY KEY CLUSTERED (
        [id_firm] ASC
    )
)

-- назначения сотрудников
-- у одного работника может быть несколько назначений
CREATE TABLE [pr_current] (
    [prid] int  NOT NULL ,
    [pid] int  NOT NULL ,
    [id_firm] int  NOT NULL ,
    [Cell_id] int  NOT NULL ,
    [Number_w] int  NOT NULL ,
    [ref_num] int  NOT NULL ,
    [date_start] datetime  NOT NULL ,
    [date_end] datetime  NOT NULL ,
    [coeff_1] numeric(19,4)  NOT NULL ,
    [coeff_2] numeric(19,4)  NOT NULL ,
    [mdate] datetime  NOT NULL ,
    [uname] varchar(128)  NOT NULL ,
	CONSTRAINT [PK_pr_current] PRIMARY KEY CLUSTERED (
    [prid] ASC
)
)

-- Структура подразделений
CREATE TABLE [Structs] (
    [struct_code] int  NOT NULL ,
    [id_firm] int  NOT NULL ,
    [struct_name] varchar(255)  NOT NULL ,
    [struct_parent] smallint  NOT NULL ,
    [struct_level] int  NOT NULL ,
    [struct_root] int  NOT NULL ,
    [curator_pid] int  NOT NULL ,
    [date_in] datetime  NOT NULL ,
    [date_out] datetime  NOT NULL ,
    CONSTRAINT [PK_Structs] PRIMARY KEY CLUSTERED (
        [struct_code] ASC
    )
)

-- профессии
CREATE TABLE [Appoints] (
    [app_code] int  NOT NULL ,
    [Name_app] varchar(255)  NOT NULL ,
    CONSTRAINT [PK_Appoints] PRIMARY KEY CLUSTERED (
        [app_code] ASC
    )
)

-- ячейки штатного расписания
CREATE TABLE [Cells] (
    [Cell_id] int  NOT NULL ,
    [Struct_code] int  NOT NULL ,
    [app_code] int  NOT NULL ,
    [Wage] numeric(19,4)  NOT NULL ,
    [Date_in] datetime  NOT NULL ,
    [date_out] datetime  NOT NULL ,
    [id_firm] int  NOT NULL ,
    [number_count] numeric(19,4)  NOT NULL ,
    [number_used] numeric(19,4)  NOT NULL ,
    [mdate] datetime  NOT NULL ,
    [uname] varchar(128)  NOT NULL ,
    CONSTRAINT [PK_Cells] PRIMARY KEY CLUSTERED (
        [Cell_id] ASC
    )
)

-- Лицевые счета
-- У одного сотрудника 1 ЛС по одной фирме
CREATE TABLE [Lic] (
    [id_lic] int  NOT NULL ,
    [pid] int  NOT NULL ,
    [prid] int  NOT NULL ,
    [tmonth] tinyint  NOT NULL ,
    [tyear] smallint  NOT NULL ,
    [cmonth] smallint  NOT NULL ,
    [code_pay] smallint  NOT NULL ,
    [summa] numeric(19,4)  NOT NULL ,
    [percent] numeric(19,8)  NOT NULL ,
    [days] numeric(9,4)  NOT NULL ,
    [hours] numeric(19,4)  NOT NULL ,
    [id_firm] int  NOT NULL ,
    [mdate] datetime  NOT NULL ,
    [uname] varchar(128)  NOT NULL ,
    CONSTRAINT [PK_Lic] PRIMARY KEY CLUSTERED (
        [id_lic] ASC
    )
)

-- Приказы
CREATE TABLE [PR_Orders] (
    [Ref_num] int  NOT NULL ,
    [Ref_Name] varchar(100)  NOT NULL ,
    [id_Firm] int  NOT NULL ,
    [Status] int  NOT NULL ,
    [date_start] datetime  NOT NULL ,
    [date_end] datetime  NOT NULL ,
    [mdate] datetime  NOT NULL ,
    [uname] varchar(128)  NOT NULL ,
    CONSTRAINT [PK_PR_Orders] PRIMARY KEY CLUSTERED (
        [Ref_num] ASC
    )
)

-- Отсутствия
CREATE TABLE [Pr_Leave] (
    [id_leave] int  NOT NULL ,
    [pid] int  NOT NULL ,
    [Type_leave] int  NOT NULL ,
    [code_pay] smallint  NOT NULL ,
    [Ref_num] int  NOT NULL ,
    [date_start] datetime  NOT NULL ,
    [date_end] datetime  NOT NULL ,
    [cmonth] smallint  NOT NULL ,
    [mdate] datetime  NOT NULL ,
    [uname] varchar(128)  NOT NULL ,
    CONSTRAINT [PK_Pr_Leave] PRIMARY KEY CLUSTERED (
        [id_leave] ASC
    )
)

ALTER TABLE [Card] ADD  CONSTRAINT [DF_Card_mdate]  DEFAULT (sysdatetime()) FOR [mdate]
GO

ALTER TABLE [Card] ADD  CONSTRAINT [DF_Card_uname]  DEFAULT (SESSION_USER) FOR [uname]
GO

ALTER TABLE [People] WITH CHECK ADD CONSTRAINT [FK_People_auto_card] FOREIGN KEY([auto_card])
REFERENCES [Card] ([auto_card])
GO

ALTER TABLE [People] ADD  CONSTRAINT [DF_People_mdate]  DEFAULT (sysdatetime()) FOR [mdate]
GO

ALTER TABLE [People] ADD  CONSTRAINT [DF_People_uname]  DEFAULT (SESSION_USER) FOR [uname]
GO

ALTER TABLE [People] CHECK CONSTRAINT [FK_People_auto_card]
GO

ALTER TABLE [People] WITH CHECK ADD CONSTRAINT [FK_People_id_firm] FOREIGN KEY([id_firm])
REFERENCES [Setup] ([id_firm])
GO

ALTER TABLE [People] CHECK CONSTRAINT [FK_People_id_firm]
GO

ALTER TABLE [People] WITH CHECK ADD CONSTRAINT [FK_People_ref_num] FOREIGN KEY([ref_num])
REFERENCES [PR_Orders] ([Ref_num])
GO

ALTER TABLE [People] CHECK CONSTRAINT [FK_People_ref_num]
GO


ALTER TABLE [Setup] WITH CHECK ADD CONSTRAINT [FK_Setup_Director_pid] FOREIGN KEY([Director_pid])
REFERENCES [People] ([pid])
GO

ALTER TABLE [Setup] CHECK CONSTRAINT [FK_Setup_Director_pid]
GO

ALTER TABLE [pr_current] WITH CHECK ADD CONSTRAINT [FK_pr_current_pid] FOREIGN KEY([pid])
REFERENCES [People] ([pid])
GO

ALTER TABLE [pr_current] CHECK CONSTRAINT [FK_pr_current_pid]
GO

ALTER TABLE [pr_current] WITH CHECK ADD CONSTRAINT [FK_pr_current_id_firm] FOREIGN KEY([id_firm])
REFERENCES [Setup] ([id_firm])
GO

ALTER TABLE [pr_current] CHECK CONSTRAINT [FK_pr_current_id_firm]
GO

ALTER TABLE [pr_current] WITH CHECK ADD CONSTRAINT [FK_pr_current_Cell_id] FOREIGN KEY([Cell_id])
REFERENCES [Cells] ([Cell_id])
GO

ALTER TABLE [pr_current] CHECK CONSTRAINT [FK_pr_current_Cell_id]
GO

ALTER TABLE [pr_current] WITH CHECK ADD CONSTRAINT [FK_pr_current_ref_num] FOREIGN KEY([ref_num])
REFERENCES [PR_Orders] ([Ref_num])
GO

ALTER TABLE [pr_current] CHECK CONSTRAINT [FK_pr_current_ref_num]
GO

ALTER TABLE [Pr_current] ADD  CONSTRAINT [DF_PR_current_mdate]  DEFAULT (sysdatetime()) FOR [mdate]
GO

ALTER TABLE [Pr_current] ADD  CONSTRAINT [DF_Pr_current_uname]  DEFAULT (SESSION_USER) FOR [uname]
GO

ALTER TABLE [Structs] WITH CHECK ADD CONSTRAINT [FK_Structs_id_firm] FOREIGN KEY([id_firm])
REFERENCES [Setup] ([id_firm])
GO

ALTER TABLE [Structs] CHECK CONSTRAINT [FK_Structs_id_firm]
GO

ALTER TABLE [Structs] WITH CHECK ADD CONSTRAINT [FK_Structs_curator_pid] FOREIGN KEY([curator_pid])
REFERENCES [People] ([pid])
GO

ALTER TABLE [Structs] CHECK CONSTRAINT [FK_Structs_curator_pid]
GO

ALTER TABLE [Cells] WITH CHECK ADD CONSTRAINT [FK_Cells_Struct_code] FOREIGN KEY([Struct_code])
REFERENCES [Structs] ([struct_code])
GO

ALTER TABLE [Cells] CHECK CONSTRAINT [FK_Cells_Struct_code]
GO

ALTER TABLE [Cells] WITH CHECK ADD CONSTRAINT [FK_Cells_app_code] FOREIGN KEY([app_code])
REFERENCES [Appoints] ([app_code])
GO

ALTER TABLE [Cells] CHECK CONSTRAINT [FK_Cells_app_code]
GO

ALTER TABLE [Cells] ADD  CONSTRAINT [DF_Cells_mdate]  DEFAULT (sysdatetime()) FOR [mdate]
GO

ALTER TABLE [Cells] ADD  CONSTRAINT [DF_Cells_uname]  DEFAULT (SESSION_USER) FOR [uname]
GO

ALTER TABLE [Lic] WITH CHECK ADD CONSTRAINT [FK_Lic_pid] FOREIGN KEY([pid])
REFERENCES [People] ([pid])
GO

ALTER TABLE [Lic] CHECK CONSTRAINT [FK_Lic_pid]
GO

ALTER TABLE [Lic] WITH CHECK ADD CONSTRAINT [FK_Lic_prid] FOREIGN KEY([prid])
REFERENCES [pr_current] ([prid])
GO

ALTER TABLE [Lic] CHECK CONSTRAINT [FK_Lic_prid]
GO

ALTER TABLE [Lic] WITH CHECK ADD CONSTRAINT [FK_Lic_id_firm] FOREIGN KEY([id_firm])
REFERENCES [Setup] ([id_firm])
GO

ALTER TABLE [Lic] CHECK CONSTRAINT [FK_Lic_id_firm]
GO

ALTER TABLE [Lic] ADD  CONSTRAINT [DF_Lic_mdate]  DEFAULT (sysdatetime()) FOR [mdate]
GO

ALTER TABLE [Lic] ADD  CONSTRAINT [DF_Lic_uname]  DEFAULT (SESSION_USER) FOR [uname]
GO

ALTER TABLE [Pr_Leave] WITH CHECK ADD CONSTRAINT [FK_Pr_Leave_pid] FOREIGN KEY([pid])
REFERENCES [People] ([pid])
GO

ALTER TABLE [Pr_Leave] CHECK CONSTRAINT [FK_Pr_Leave_pid]
GO

ALTER TABLE [Pr_Leave] WITH CHECK ADD CONSTRAINT [FK_Pr_Leave_Ref_num] FOREIGN KEY([Ref_num])
REFERENCES [PR_Orders] ([Ref_num])
GO

ALTER TABLE [Pr_Leave] CHECK CONSTRAINT [FK_Pr_Leave_Ref_num]
GO

ALTER TABLE [Pr_Leave] ADD  CONSTRAINT [DF_Pr_Leave_mdate]  DEFAULT (sysdatetime()) FOR [mdate]
GO

ALTER TABLE [Pr_Leave] ADD  CONSTRAINT [DF_Pr_Leave_uname]  DEFAULT (SESSION_USER) FOR [uname]
GO
--SESSION_USER
COMMIT TRANSACTION NewBD