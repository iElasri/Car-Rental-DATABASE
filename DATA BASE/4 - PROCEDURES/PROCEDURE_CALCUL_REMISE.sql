USE [CAR_RENTAL]
GO
/****** Object:  StoredProcedure [dbo].[CALCULATE_DISCOUNT_AMOUNT]    Script Date: 1/11/2017 10:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------
--Procedure Name: CALCULATE_DISCOUNT_AMOUNT
--cette procedure calcule le remise pour un enregistrement .
-------------------------------------------------------------------------------------------


ALTER PROCEDURE [dbo].[CALCULATE_DISCOUNT_AMOUNT] /*CLACUL_REMISE*/
/*les arguments de cette procedures*/
(
@dlNum VARCHAR(8) /* Numero de client */,
@amount NUMERIC(10,2) /* PRIX TOTAL */,
@discountCode CHAR(4) /* le CODE DU PROMO dans la table DISCOUNT_DETAILES */, 
@discountAmt NUMERIC(10,2) /* le taux de remise dans la table  BILLING_DETAILS */ OUT) AS
 BEGIN
 --local declarations
DECLARE @memberType CHAR(1) /* Use -meta option CUSTOMER_DETAILS.MEMBERSHIP_TYPE%TYPE */;
  SELECT @memberType = (select MEMBERSHIP_TYPE FROM Client WHERE Client_ID = @dlNum);

  IF ISNULL(@discountCode,'NULL') <> 'NULL' 
  BEGIN
	DECLARE @discountPercentage NUMERIC(4,2) /* Use -meta option DISCOUNT_DETAILS.DISCOUNT_PERCENTAGE%TYPE */; 
    SELECT @discountPercentage = (select DISCOUNT_PERCENTAGE FROM DISCOUNT_DETAILS WHERE DISCOUNT_CODE = @discountCode);
    IF @memberType = 'M' BEGIN
      SET @discountAmt = @amount * ((@discountPercentage+10)/100);
    END
    ELSE BEGIN
      SET @discountAmt = @amount * (@discountPercentage/100);
    END 
  END
  ELSE 
  BEGIN
    IF @memberType = 'M' BEGIN
      SET @discountAmt = @amount * 0.1;
    END
    ELSE BEGIN
      SET @discountAmt = 0;
    END 
  END 
END;
