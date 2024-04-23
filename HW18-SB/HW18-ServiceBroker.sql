--Create Message Types for Request and Reply messages
USE WideWorldImporters
--Типы сообщений
-- For Request
CREATE MESSAGE TYPE
[//WWI/SB/RequestMessage1]
VALIDATION=WELL_FORMED_XML;
-- For Reply
CREATE MESSAGE TYPE
[//WWI/SB/ReplyMessage1]
VALIDATION=WELL_FORMED_XML; 

GO
--Контракт
Create CONTRACT [//WWI/SB/Contract2]
      ([//WWI/SB/RequestMessage1]
         SENT BY INITIATOR,
       [//WWI/SB/ReplyMessage1]
         SENT BY TARGET
      );
GO
--очереди
CREATE QUEUE TargetQueueWWI1;

ALTER SERVICE [//WWI/SB/TargetService1]
       ON QUEUE TargetQueueWWI1
       (ADD CONTRACT [//WWI/SB/Contract2]);
GO


CREATE QUEUE InitiatorQueueWWI1;

ALTER SERVICE [//WWI/SB/InitiatorService1]
       ON QUEUE InitiatorQueueWWI1
       (ADD CONTRACT [//WWI/SB/Contract2]);
GO
-- настройки очередей
ALTER QUEUE [dbo].[InitiatorQueueWWI1] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF) 
	, ACTIVATION (   STATUS = ON ,
        PROCEDURE_NAME = Sales.ConfirmNewReport, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO
ALTER QUEUE [dbo].[TargetQueueWWI1] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF)
	, ACTIVATION (  STATUS = ON ,
        PROCEDURE_NAME = Sales.GetNewReport, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO

---Процедура Создание запроса-------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE Sales.CreateNewReport
	@CustId INT,
	@date_b date,
	@date_e date
AS
BEGIN
	SET NOCOUNT ON;

    --Sending a Request Message to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(4000);
	
	BEGIN TRAN 

	--Prepare the Message
	SELECT @RequestMessage = (SELECT [CustomerID] as CustomerID, @date_b as date_b, @date_e as date_e
							  FROM [Sales].[Customers] AS Cust
							  WHERE [CustomerID] = @CustId
							  FOR XML AUTO, root('RequestMessage')); 
	
	--Determine the Initiator Service, Target Service and the Contract 
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//WWI/SB/InitiatorService1]
	TO SERVICE
	'//WWI/SB/TargetService1'
	ON CONTRACT
	[//WWI/SB/Contract2]
	WITH ENCRYPTION=OFF; 

	--Send the Message
	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//WWI/SB/RequestMessage1]
	(@RequestMessage);
	
	SELECT @RequestMessage AS SentRequestMessage;
	select * FROM dbo.TargetQueueWWI1; 
	COMMIT TRAN 
END
GO
--Процедура обработки запроса----------------------------------------------------------------

CREATE PROCEDURE Sales.GetNewReport
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(4000),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
			@ReplyMessageName Sysname,
			@CustId INT,
			@date_b date,
			@date_e date,
			@xml XML; 
	
	BEGIN TRAN; 

	--Receive message from Initiator
	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	 FROM dbo.TargetQueueWWI1; 

	--SELECT @Message; --отладка

	SET @xml = CAST(@Message AS XML);

	SELECT @CustID = R.Cust.value('@CustomerID','INT'), @date_b = R.Cust.value('@date_b','date'), @date_e = R.Cust.value('@date_e','date')
	FROM @xml.nodes('/RequestMessage/Cust') as R(Cust);
	
	IF EXISTS (SELECT top 1 1 FROM Sales.Orders WHERE CustomerID = @CustID and OrderDate between @date_b and @date_e)
	BEGIN
		IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'tempCustReport') AND type in (N'U'))
		CREATE TABLE tempCustReport ( idCustomer int, date_b date, date_e date, cntOrders int);

		INSERT INTO dbo.tempCustReport
           (idCustomer
           ,date_b
           ,date_e
           ,cntOrders)
       SELECT @CustID
			, @date_b 
			, @date_e
			, count(OrderID)
		FROM Sales.Orders
		WHERE CustomerID = @CustID
			and OrderDate between @date_b and @date_e
	 
	END;
	
	--SELECT @Message AS ReceivedRequestMessage, @MessageType; --отладка
	
	-- Confirm and Send a reply
	IF @MessageType=N'//WWI/SB/RequestMessage1'
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>'; 
	
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/SB/ReplyMessage1]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle;
	END 
	
	--SELECT @ReplyMessage AS SentReplyMessage; --отладка

	COMMIT TRAN;
END

------------------------------------------------------------------------------------------
CREATE PROCEDURE Sales.ConfirmNewReport
AS
BEGIN
	--Receiving Reply Message from the Target.	
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER,
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 

		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorQueueWWI1; 
		
		END CONVERSATION @InitiatorReplyDlgHandle; 
		
		--SELECT @ReplyReceivedMessage AS ReceivedRepliedMessage; --отладка

	COMMIT TRAN; 
END