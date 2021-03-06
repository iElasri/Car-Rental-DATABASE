USE [CAR_RENTAL]
GO
/****** Object:  Trigger [dbo].[GENERATE_BILLING]    Script Date: 1/10/2017 21:39:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------
--Trigger Name: GENERATE_BILLING
--This trigger generates the bill and inserts a row in Billing_Details table
-------------------------------------------------------------------------------------------
ALTER TRIGGER [dbo].[GENERATE_BILLING] ON [dbo].[BOOKING_DETAILS]
AFTER UPDATE AS
-- declaration section
DECLARE @lastBillId int /* Use -meta option BILLING_DETAILS.BILL_ID%TYPE */;
DECLARE @newBillId varchar(6) /* Use -meta option BILLING_DETAILS.BILL_ID%TYPE */;
DECLARE @discountAmt numeric(10,2) /* Use -meta option BILLING_DETAILS.DISCOUNT_AMOUNT%TYPE */;
DECLARE @totalLateFee numeric(10,2) /* Use -meta option BILLING_DETAILS.TOTAL_LATE_FEE%TYPE */;
DECLARE @totalTax numeric(10,2) /* Use -meta option BILLING_DETAILS.TAX_AMOUNT%TYPE */;
DECLARE @totalAmountBeforeDiscount numeric(10,2) /* Use -meta option BILLING_DETAILS.TOTAL_AMOUNT%TYPE */;
DECLARE @finalAmount numeric(10,2) /* Use -meta option BILLING_DETAILS.TOTAL_AMOUNT%TYPE */;
DECLARE @bookstatus char(1) /* Use -meta option BILLING_DETAILS.TOTAL_AMOUNT%TYPE */;

	BEGIN
		  set @bookstatus = (select BOOKING_STATUS FROM inserted);
		  if(@bookstatus = 'R')
		  BEGIN		
		      
			  SELECT @lastBillId = ( select count(*) from BILLING_DETAILS) + 1001;
									/*select BILL_ID FROM ( SELECT BILL_ID, ROW_NUMBER() OVER(ORDER BY BILL_ID ASC) AS RN 
														FROM  BILLING_DETAILS) s
														WHERE RN= (SELECT MAX(ROW_NUMBER() OVER(ORDER BY BILL_ID ASC) ) FROM BILLING_DETAILS)*/
									--SELECT TOP 1 BILL_ID FROM BILLING_DETAILS ORDER BY BILL_ID DESC
			  --SET @newBillId = 'BL' + ISNULL(CONVERT(VARCHAR, CAST(SUBSTRING(@lastBillId,3,4) AS INT)+1),'');
			  SET @newBillId = 'BL' + CONVERT(varchar(4),@lastBillId);
  
				
				declare @actualReturnDateTime datetime /* Use -meta option BOOKING_DETAILS.ACT_RET_DT_TIME%TYPE */;
				set @actualReturnDateTime =(select ACT_RET_DT_TIME from inserted );
				declare @ReturnDateTime datetime /* Use -meta option BOOKING_DETAILS.RET_DT_TIME%TYPE */;
				set @ReturnDateTime =(select RET_DT_TIME from inserted );
				declare @regNum VARCHAR(7) /* Use -meta option BOOKING_DETAILS.REG_NUM%TYPE */;
				set @regNum =(select REG_NUM from inserted );
				declare @amount NUMERIC(10,2) /* Use -meta option BOOKING_DETAILS.AMOUNT%TYPE */;
				set @amount =(select AMOUNT from inserted );


	
			
				exec CALCULATE_LATE_FEE_AND_TAX @actualReturnDateTime, @ReturnDateTime, @regNum,@amount, @totalLateFee output, @totalTax output;
  
 
  
				declare @dlNum VARCHAR(8) /* Numero de client */;
				set @dlNum = (select DL_NUM from inserted);
	
				set @amount = (select AMOUNT from inserted);
				declare @discountCode CHAR(4) /* le CODE DU PROMO dans la table DISCOUNT_DETAILES */;
				set @discountCode = (select DISCOUNT_CODE from inserted);	

				SET @totalAmountBeforeDiscount = @amount + @totalLateFee + @totalTax;

  print ' @@amount :  ' + CAST( @amount AS VARCHAR);
  print ' @totalAmountBeforeDiscount :  ' + CAST( @totalAmountBeforeDiscount AS VARCHAR);
  print ' @@totalLateFee :  ' + CAST( @totalLateFee AS VARCHAR);
  print ' @@totalTax :  ' + CAST( @totalTax AS VARCHAR);

				exec CALCULATE_DISCOUNT_AMOUNT @dlNum, @totalAmountBeforeDiscount, @discountCode, @discountAmt output;

  print ' CALCULATE_DISCOUNT_AMOUNT' ;

				SET @finalAmount = @totalAmountBeforeDiscount - @discountAmt;  
			  --insert new bill into the billing_details table
			  declare @bookid varchar(5);
			  set @bookid = ( select BOOKING_ID FROM INSERTED);
			  INSERT INTO BILLING_DETAILS (BILL_ID,BILL_DATE,BILL_STATUS,DISCOUNT_AMOUNT,TOTAL_AMOUNT,TAX_AMOUNT,BOOKING_ID,TOTAL_LATE_FEE) 
			  VALUES (@newBillId,convert(DATE,GETDATE()),'P',@discountAmt,@finalAmount,@totalTax,@bookid,@totalLateFee);
		  END
  

  END;

  












