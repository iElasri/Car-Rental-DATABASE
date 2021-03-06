USE [CAR_RENTAL]
GO
/****** Object:  Trigger [dbo].[UPDATE_CAR_DETAILS]    Script Date: 1/10/2017 22:52:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------
--Trigger Name: UPDATE_CAR_DETAILS
--This trigger updates the availability flag, mileage and location in the car table 
--when the car is returned.
-------------------------------------------------------------------------------------------
ALTER  TRIGGER [dbo].[UPDATE_CAR_DETAILS] ON [dbo].[BOOKING_DETAILS]
AFTER UPDATE AS 

declare @bookstate char(1);
set @bookstate = (select BOOKING_STATUS from inserted);
declare @actretdate datetime;
set @actretdate = (select ACT_RET_DT_TIME from inserted );
declare @pickloc char(4)
set @pickloc = (select PICKUP_LOC from INSERTED );
declare @droploc char(4)
set @droploc = (select DROP_LOC from INSERTED );
declare @reg_num char(7)
set @reg_num = (select REG_NUM from INSERTED );

IF (ISNULL(CONVERT(VARCHAR,@actretdate),'NULL') = 'NULL' and @bookstate ='C') 
      UPDATE CAR SET AVAILABILITY_FLAG = 'A' , LOC_ID = @pickloc WHERE REGISTRATION_NUMBER = @reg_num;
ELSE IF (ISNULL(CONVERT(VARCHAR,@actretdate),'NULL') <> 'NULL')
	BEGIN
      UPDATE CAR SET AVAILABILITY_FLAG = 'A' , LOC_ID = @droploc, MILEAGE = MILEAGE + dbo.get_mileage() WHERE REGISTRATION_NUMBER = @reg_num;
      UPDATE BOOKING_DETAILS SET BOOKING_STATUS = 'R' WHERE BOOKING_ID in (SELECT BOOKING_ID FROM inserted);
	END
