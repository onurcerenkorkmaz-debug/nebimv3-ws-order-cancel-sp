


```sql
/*
    Name        : dbo.sp_CancelSpecificOrder_WS
    Purpose     : Cancel WS order lines and clear remaining qty from stReserve and stOrder
    Author      : Onur Ceren Korkmaz
    Created     : 2026-01-06
*/

 

ALTER PROCEDURE [dbo].[sp_CancelSpecificOrder_WS] 
	@OrderNumber nvarchar(50),
	@CompanyId int=2
AS
BEGIN TRY
	BEGIN TRAN UpdatetrOrderLine

	DECLARE @CancelQty float = 0
	DECLARE @OrderLineID uniqueidentifier
	
	-- CURSOR: Verilen OrderNumber ve ProcessCode='WS' kriterine uyanları seçer
	DECLARE cursorID CURSOR FOR	
	SELECT 
		stOrder.OrderLineID
	FROM stOrder WITH(NOLOCK)
	INNER JOIN AllOrderLines WITH(NOLOCK)
		ON stOrder.OrderLineID = AllOrderLines.OrderLineID 
		AND AllOrderLines.ProcessCode = 'WS' -- Sadece WS olanlar
		AND AllOrderLines.OrderNumber = @OrderNumber -- Parametre olarak gelen Sipariş No
	
	OPEN cursorID
	FETCH NEXT FROM cursorID INTO @OrderLineID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- İptal edilecek miktarı (kalan miktar) al
		SELECT @CancelQty = Qty1 FROM stOrder WHERE OrderLineID = @OrderLineID
		
		-- trOrderLine tablosunu güncelle
		UPDATE trOrderLine 
		SET CancelQty1 = ISNULL(CancelQty1,0) + @CancelQty
			,LastUpdatedUserName = 'Integrator'
			,CancelDate = GETDATE()
			,LastUpdatedDate = GETDATE()
			,OrderCancelReasonCode = '009'
		FROM trOrderline
		WHERE trOrderLine.OrderLineID = @OrderLineID

		-- LOG INSERT KISMI ÇIKARILDI

		FETCH NEXT FROM cursorID INTO @OrderLineID
	END
	
	CLOSE cursorID
	DEALLOCATE cursorID

	COMMIT TRAN UpdatetrOrderLine		
END TRY
BEGIN CATCH
	IF (XACT_STATE()) <> 0 ROLLBACK TRANSACTION;
	DECLARE @ErrorMessage	NVARCHAR(4000)
	DECLARE @ErrorSeverity	INT
	DECLARE @ErrorState		INT

	SELECT  @ErrorMessage	= ERROR_MESSAGE(),
			@ErrorSeverity	= ERROR_SEVERITY(),
			@ErrorState		= ERROR_STATE()
		
	RAISERROR (
				@ErrorMessage,	-- Message text
				@ErrorSeverity,	-- Severity
				@ErrorState		-- State  
			  )
END CATCH
