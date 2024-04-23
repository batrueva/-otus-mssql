/*************************************************************************************************************************************************/
-- Физические лица [Card] 
--
--
/*************************************************************************************************************************************************/
CREATE TABLE [Card] (
    [auto_card] int  IDENTITY(1,1) NOT NULL ,
    [name] varchar(40)  NOT NULL ,
    [name_i] varchar(40)  NOT NULL ,
    [name_o] varchar(40)  NULL ,
    [Full_Name]  as (((([name] + ' ') +  [name_i]) + ' ')+[name_o]),
    [date_birth] date  NOT NULL ,
    [sex] tinyint  NOT NULL ,
    [SocNumber] varchar(15)  NOT NULL ,
    [INN] varchar(12)  NOT NULL ,
    [EMail] varchar(64)  NOT NULL ,
    [Passp_ser] varchar(10)  NOT NULL ,
    [Passp_num] varchar(16)  NOT NULL ,
    [Passp_date] date  NOT NULL ,
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

/*************************************************************************************************************************************************/
--[Card] index
/*************************************************************************************************************************************************/
/****** Object:  Index [IDX_Card__SocNumber]    Script Date: 12.01.2024 16:28:28 ******/
CREATE NONCLUSTERED INDEX [IDX_Card__SocNumber] ON [dbo].[Card]
(
	[SocNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [IDX_Card__FIO]    Script Date: 12.01.2024 16:27:01 ******/
CREATE NONCLUSTERED INDEX [IDX_Card__FIO] ON [dbo].[Card]
(
	[Name] ASC,
	[Name_i] ASC,
	[Name_o] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/*************************************************************************************************************************************************/
-- работники [People]
-- одному физ. лицу может соотв. несколько работников 1 : N
-- одно физ. лицо может быть принято в разные фирмы
/*************************************************************************************************************************************************/
CREATE TABLE [People] (
    [pid] int IDENTITY(1,1) NOT NULL ,
    [auto_card] int  NOT NULL ,
    [firm_id] int  NOT NULL ,
    [date_in] date  NOT NULL ,
    [date_out] date  NOT NULL ,
    [Order_id] int  NOT NULL ,
    [mdate] datetime  NOT NULL ,
    [uname] varchar(128)  NOT NULL ,
    CONSTRAINT [PK_People] PRIMARY KEY CLUSTERED (
        [pid] ASC
    )
)
ALTER TABLE [People] WITH CHECK ADD CONSTRAINT [FK_People_auto_card] FOREIGN KEY([auto_card])
REFERENCES [Card] ([auto_card])

ALTER TABLE [People] CHECK CONSTRAINT [FK_People_auto_card]

ALTER TABLE [People] WITH CHECK ADD CONSTRAINT [FK_People_firm_id] FOREIGN KEY([firm_id])
REFERENCES [Firms] ([firm_id])

ALTER TABLE [People] CHECK CONSTRAINT [FK_People_firm_id]

ALTER TABLE [People] WITH CHECK ADD CONSTRAINT [FK_People_Order_id] FOREIGN KEY([Order_id])
REFERENCES [Orders] ([Order_id])

ALTER TABLE [People] CHECK CONSTRAINT [FK_People_Order_id]
/*************************************************************************************************************************************************/
--[People] index
/*************************************************************************************************************************************************/
/****** Object:  Index [IDX_People__Auto_Card]    Script Date: 12.01.2024 16:35:34 ******/
CREATE NONCLUSTERED INDEX [IDX_People__Auto_Card] ON [dbo].[people]
(
	[Auto_Card] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IDX_People__Auto_Card]    Script Date: 12.01.2024 16:35:34 ******/
CREATE NONCLUSTERED INDEX [IDX_People__pid1] ON [dbo].[people]
(
	[pid] ASC,
	[date_in] ASC,
	[date_out] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/*************************************************************************************************************************************************/
-- TABLE [Firms]
-- фирмы
--
/*************************************************************************************************************************************************/
CREATE TABLE [Firms] (
    [firm_id] int IDENTITY(1,1) NOT NULL ,
    [Name] varchar(255)  NOT NULL ,
    [INN] varchar(12)  NOT NULL ,
    [Phone] varchar(32)  NOT NULL ,
    [EMail] varchar(64)  NULL ,
    [Adress1] varchar(255)  NOT NULL ,
    [Adress2] varchar(255)  NULL ,
    CONSTRAINT [PK_Firms] PRIMARY KEY CLUSTERED (
        [firm_id] ASC
    )
)
/*************************************************************************************************************************************************/
--[Firms] INDEX
-- при условии ведения нескольких фирм(обособленных подразделений)
/*************************************************************************************************************************************************/
CREATE NONCLUSTERED INDEX [IDX_Setup__INN] ON [dbo].[Firms]
(
	[INN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/*************************************************************************************************************************************************/
--TABLE [pr_current]
-- назначения сотрудников
-- у одного работника может быть несколько назначений
/*************************************************************************************************************************************************/
CREATE TABLE [pr_current] (
    [prid] int IDENTITY(1,1) NOT NULL ,
    [pid] int  NOT NULL ,
    [firm_id] int  NOT NULL ,
    [Cell_id] int  NOT NULL ,
    [Number_w] int  NOT NULL ,
    [Order_id] int  NOT NULL ,
    [date_start] date  NOT NULL ,
    [date_end] date  NOT NULL ,
    [coeff_1] numeric(19,4)  NOT NULL ,
    [coeff_2] numeric(19,4)  NOT NULL ,
    [mdate] datetime  NOT NULL ,
    [uname] varchar(128)  NOT NULL ,
	CONSTRAINT [PK_pr_current] PRIMARY KEY CLUSTERED (
    [prid] ASC
)
)
ALTER TABLE [pr_current] WITH CHECK ADD CONSTRAINT [FK_pr_current_pid] FOREIGN KEY([pid])
REFERENCES [People] ([pid])

ALTER TABLE [pr_current] CHECK CONSTRAINT [FK_pr_current_pid]

ALTER TABLE [pr_current] WITH CHECK ADD CONSTRAINT [FK_pr_current_firm_id] FOREIGN KEY([firm_id])
REFERENCES [Firms] ([firm_id])

ALTER TABLE [pr_current] CHECK CONSTRAINT [FK_pr_current_firm_id]

ALTER TABLE [pr_current] WITH CHECK ADD CONSTRAINT [FK_pr_current_Cell_id] FOREIGN KEY([Cell_id])
REFERENCES [Cells] ([Cell_id])

ALTER TABLE [pr_current] CHECK CONSTRAINT [FK_pr_current_Cell_id]

ALTER TABLE [pr_current] WITH CHECK ADD CONSTRAINT [FK_pr_current_Order_id] FOREIGN KEY([Order_id])
REFERENCES [Orders] ([Order_id])

ALTER TABLE [pr_current] CHECK CONSTRAINT [FK_pr_current_Order_id]

/***[pr_current] INDEX******************************************************************************************************************************************/
/****** Object:  Index [IDX_Pr_current__Order_id]    Script Date: 12.01.2024 17:35:54 ******/
CREATE NONCLUSTERED INDEX [IDX_Pr_current__Order_id] ON [dbo].[PR_CURRENT]
(
	[Order_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Pr_current__pid3]    Script Date: 12.01.2024 17:35:48 ******/
CREATE NONCLUSTERED INDEX [IDX_Pr_current__pid3] ON [dbo].[PR_CURRENT]
(
	[pId] ASC,
	[Date_start] ASC,
	[Date_end] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [IDX_Pr_current__Firm_id]    Script Date: 12.01.2024 17:34:59 ******/
CREATE NONCLUSTERED INDEX [IDX_Pr_current__Firm_id] ON [dbo].[PR_CURRENT]
(
	[Firm_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [IDX_Pr_current__Cell_id]    Script Date: 12.01.2024 17:34:25 ******/
CREATE NONCLUSTERED INDEX [IDX_Pr_current__Cell_id] ON [dbo].[PR_CURRENT]
(
	[Cell_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/*************************************************************************************************************************************************/
-- TABLE [Structs]
-- Структура подразделений
/*************************************************************************************************************************************************/
CREATE TABLE [Structs] (
    [struct_code] int IDENTITY(1,1) NOT NULL ,
    [firm_id] int  NOT NULL ,
    [struct_name] varchar(255)  NOT NULL ,
    [struct_parent] smallint  NOT NULL ,
    [struct_level] int  NOT NULL ,
    [struct_root] int  NOT NULL ,
    [curator_pid] int  NOT NULL ,
    [date_in] date  NOT NULL ,
    [date_out] date  NOT NULL ,
    CONSTRAINT [PK_Structs] PRIMARY KEY CLUSTERED (
        [struct_code] ASC
    )
)
ALTER TABLE [Structs] WITH CHECK ADD CONSTRAINT [FK_Structs_firm_id] FOREIGN KEY([firm_id])
REFERENCES [Firms] ([firm_id])

ALTER TABLE [Structs] CHECK CONSTRAINT [FK_Structs_firm_id]

ALTER TABLE [Structs] WITH CHECK ADD CONSTRAINT [FK_Structs_curator_pid] FOREIGN KEY([curator_pid])
REFERENCES [People] ([pid])

ALTER TABLE [Structs] CHECK CONSTRAINT [FK_Structs_curator_pid]

/***[Structs] INDEX******************************************************************************************************************************************/

/****** Object:  Index [IDX_Structs__02]    Script Date: 13.03.2024 10:04:31 ******/
CREATE NONCLUSTERED INDEX [IDX_Structs__02] ON [dbo].[StructS]
(
	[Struct_Code] ASC,
	[Struct_Parent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Structs__01]    Script Date: 13.03.2024 10:04:25 ******/
CREATE NONCLUSTERED INDEX [IDX_Structs__01] ON [dbo].[StructS]
(
	[Firm_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [IDX_structs__struct_lev]    Script Date: 13.03.2024 10:04:52 ******/
CREATE NONCLUSTERED INDEX [IDX_structs__struct_level] ON [dbo].[StructS]
(
	[Struct_Level] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [IDX_Structs_code_name]    Script Date: 13.03.2024 10:05:09 ******/
CREATE NONCLUSTERED INDEX [IDX_Structs_code_name] ON [dbo].[StructS]
(
	[Struct_Code] ASC,
	[Struct_Name] ASC,
	[date_in] ASC,
	[date_out] ASC,
	[Struct_root] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/*************************************************************************************************************************************************/
--TABLE [Appoints]
--
-- профессии
/*************************************************************************************************************************************************/
CREATE TABLE [Appoints] (
    [app_code] int IDENTITY(1,1) NOT NULL ,
    [name_app] varchar(255)  NOT NULL ,
    CONSTRAINT [PK_Appoints] PRIMARY KEY CLUSTERED (
        [app_code] ASC
    )
)
/**[Appoints] INDEX*******************************************************************************************************************************/

/****** Object:  Index [IDX_Appointments__Name_appoint]    Script Date: 12.01.2024 17:17:30 ******/
CREATE NONCLUSTERED INDEX [IDX_Appoints__name_app] ON [dbo].[Appoints]
(
	[name_app] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/*************************************************************************************************************************************************/
-- TABLE [Cells]
-- ячейки штатного расписания
/*************************************************************************************************************************************************/
CREATE TABLE [Cells] (
    [Cell_id] int IDENTITY(1,1) NOT NULL ,
    [Struct_code] int  NOT NULL ,
    [app_code] int  NOT NULL ,
    [Wage] numeric(19,4)  NOT NULL ,
    [Date_in] date  NOT NULL ,
    [date_out] date  NOT NULL ,
    [firm_id] int  NOT NULL ,
    [number_count] numeric(19,4)  NOT NULL ,
    [number_used] numeric(19,4)  NOT NULL ,
    [mdate] datetime  NOT NULL ,
    [uname] varchar(128)  NOT NULL ,
    CONSTRAINT [PK_Cells] PRIMARY KEY CLUSTERED (
        [Cell_id] ASC
    )
)
ALTER TABLE [Cells] WITH CHECK ADD CONSTRAINT [FK_Cells_Struct_code] FOREIGN KEY([Struct_code])
REFERENCES [Structs] ([struct_code])

ALTER TABLE [Cells] CHECK CONSTRAINT [FK_Cells_Struct_code]

ALTER TABLE [Cells] WITH CHECK ADD CONSTRAINT [FK_Cells_app_code] FOREIGN KEY([app_code])
REFERENCES [Appoints] ([app_code])

ALTER TABLE [Cells] CHECK CONSTRAINT [FK_Cells_app_code]

/**[Cells] INDEX**********************************************************************************************************************************/

/****** Object:  Index [IDX_cells__struct_code]    Script Date: 12.01.2024 17:13:57 ******/
CREATE NONCLUSTERED INDEX [IDX_cells__struct_code] ON [dbo].[Cells]
(
	[Struct_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [IDX_cells__id_firm]    Script Date: 12.01.2024 17:12:39 ******/
CREATE NONCLUSTERED INDEX [IDX_cells__firm_id] ON [dbo].[Cells]
(
	[firm_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [IDX_cells__date_out]    Script Date: 12.01.2024 17:12:20 ******/
CREATE NONCLUSTERED INDEX [IDX_cells__date_out] ON [dbo].[Cells]
(
	[Date_Out] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [IDX_cells__Date_in]    Script Date: 12.01.2024 17:12:16 ******/
CREATE NONCLUSTERED INDEX [IDX_cells__Date_in] ON [dbo].[Cells]
(
	[Date_in] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [IDX_cells__App_code]    Script Date: 12.01.2024 17:11:57 ******/
CREATE NONCLUSTERED INDEX [IDX_cells__App_code] ON [dbo].[Cells]
(
	[App_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/*************************************************************************************************************************************************/
-- TABLE [Lic]
-- Лицевые счета
-- У одного сотрудника 1 ЛС по одной фирме
/*************************************************************************************************************************************************/
CREATE TABLE [Lic] (
    [lic_id] int IDENTITY(1,1) NOT NULL ,
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
    [firm_id] int  NOT NULL ,
    [mdate] datetime  NOT NULL ,
    [uname] varchar(128)  NOT NULL ,
    CONSTRAINT [PK_Lic] PRIMARY KEY CLUSTERED (
        [lic_id] ASC
    )
)
ALTER TABLE [Lic] WITH CHECK ADD CONSTRAINT [FK_Lic_pid] FOREIGN KEY([pid])
REFERENCES [People] ([pid])

ALTER TABLE [Lic] CHECK CONSTRAINT [FK_Lic_pid]

ALTER TABLE [Lic] WITH CHECK ADD CONSTRAINT [FK_Lic_prid] FOREIGN KEY([prid])
REFERENCES [pr_current] ([prid])

ALTER TABLE [Lic] CHECK CONSTRAINT [FK_Lic_prid]

ALTER TABLE [Lic] WITH CHECK ADD CONSTRAINT [FK_Lic_firm_id] FOREIGN KEY([firm_id])
REFERENCES [Firms] ([firm_id])

ALTER TABLE [Lic] CHECK CONSTRAINT [FK_Lic_firm_id]

ALTER TABLE [Lic] WITH CHECK ADD CONSTRAINT [FK_Lic_Code_pay] FOREIGN KEY([code_pay])
REFERENCES [Typ_pay] ([code_pay])

ALTER TABLE [Lic] CHECK CONSTRAINT [FK_Lic_Code_pay]
/**[Lic] INDEX*******************************************************************************************************************************/
/****** Object:  Index [IDX_lic_1]    Script Date: 10.03.2024 20:32:15 ******/
CREATE NONCLUSTERED INDEX [IDX_lic_1] ON [dbo].[Lic]
(
	[code_pay] ASC,
	[pid] ASC,
	[summa] ASC,
	[cmonth] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_lic_3]    Script Date: 10.03.2024 20:33:37 ******/
CREATE NONCLUSTERED INDEX [IDX_Lic_3] ON [dbo].[Lic]
(
	[firm_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


/********************************************************************************************************************************************/
-- TABLE [ORDERS]
-- Приказы
/*******************************************************************************************************************************************/
CREATE TABLE [ORDERS] (
    [Order_id] int IDENTITY(1,1) NOT NULL ,
    [Order_name] varchar(100)  NOT NULL ,
    [firm_id] int  NOT NULL ,
    [Status_code] int  NOT NULL ,
    [date_start] date  NOT NULL ,
    [date_end] date  NOT NULL ,
    [mdate] datetime  NOT NULL ,
    [uname] varchar(128)  NOT NULL ,
    CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED (
        [Order_id] ASC
    )
)
/**[Orders] INDEX******************************************************************************************************************************/
--при условии ведения нескольких фирм/ОП в одной базе
/****** Object:  Index [IDX_PR_ORDERS__firm_id]    Script Date: 12.01.2024 18:02:51 ******/
CREATE NONCLUSTERED INDEX [IDX_PR_ORDERS__firm_id] ON [dbo].[ORDERS]
(
	[firm_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/*************************************************************************************************************************************************/
-- TABLE [Leaves]
-- Отсутствия
/*************************************************************************************************************************************************/
CREATE TABLE [Leaves] (
    [Leave_id] int IDENTITY(1,1) NOT NULL ,
    [pid] int  NOT NULL ,
    [Type_leave] int  NOT NULL ,
    [code_pay] smallint  NOT NULL ,
    [Order_id] int  NOT NULL ,
    [date_start] date  NOT NULL ,
    [date_end] date  NOT NULL ,
    [cmonth] smallint  NOT NULL ,
    [mdate] datetime  NOT NULL ,
    [uname] varchar(128)  NOT NULL ,
    CONSTRAINT [PK_Leaves] PRIMARY KEY CLUSTERED (
        [Leave_id] ASC
    )
)
ALTER TABLE [Leaves] WITH CHECK ADD CONSTRAINT [FK_Leaves_pid] FOREIGN KEY([pid])
REFERENCES [People] ([pid])

ALTER TABLE [Leaves] CHECK CONSTRAINT [FK_Leaves_pid]

ALTER TABLE [Leaves] WITH CHECK ADD CONSTRAINT [FK_Leaves_code_pay] FOREIGN KEY([code_pay])
REFERENCES [Typ_pay] ([code_pay])

ALTER TABLE [Leaves] CHECK CONSTRAINT [FK_Leaves_code_pay]

ALTER TABLE [Leaves] WITH CHECK ADD CONSTRAINT [FK_Leaves_Order_id] FOREIGN KEY([Order_id])
REFERENCES [Orders] ([Order_id])

ALTER TABLE [Leaves] CHECK CONSTRAINT [FK_Leaves_Order_id]

ALTER TABLE [Leaves] ADD  CONSTRAINT [DF_Leaves_mdate]  DEFAULT (sysdatetime()) FOR [mdate]
GO

ALTER TABLE [Leaves] ADD  CONSTRAINT [DF_Leaves_uname]  DEFAULT (SESSION_USER) FOR [uname]
GO
/**[Leaves] INDEX******************************************************************************************************************************/
/****** Object:  Index [IDX_Leaves_1]    Script Date: 12.01.2024 17:45:46 ******/
CREATE NONCLUSTERED INDEX [IDX_leaves_1] ON [dbo].[Leaves]
(
	[pId] ASC,
	[date_start] ASC,
	[date_end] ASC,
	[cMonth] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [IDX_Leaves__Order_id]    Script Date: 12.01.2024 17:45:34 ******/
CREATE NONCLUSTERED INDEX [IDX_Leaves__Order_id] ON [dbo].[Leaves]
(
	[Order_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [IDX_Leaves__pId]    Script Date: 12.01.2024 17:45:27 ******/
CREATE NONCLUSTERED INDEX [IDX_Leaves__pId] ON [dbo].[Leaves]
(
	[pId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [IDX_Leaves__Type_Leave]    Script Date: 12.01.2024 17:44:40 ******/
CREATE NONCLUSTERED INDEX [IDX_Leaves__Type_Leave] ON [dbo].[Leaves]
(
	[Type_Leave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/*************************************************************************************************************************************************/
-- TABLE [Typ_pay]
-- Типы начисений/удержаний
CREATE TABLE [Typ_pay] (
    [Code_pay] smallint IDENTITY(1,1) NOT NULL ,
    [Name_pay] varchar(100)  NOT NULL ,
     CONSTRAINT [PK_Typ_pay] PRIMARY KEY CLUSTERED (
        [Code_pay] ASC
    )
)
/**[Typ_pay] INDEX*******************************************************************************************************************************/

/*************************************************************************************************************************************************/






