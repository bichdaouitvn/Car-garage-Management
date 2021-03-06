﻿create database garage					
go

use  garage
go

CREATE TABLE HangXe
(
	id INT IDENTITY PRIMARY KEY,
	tenhangxe NVARCHAR(50),
)


 CREATE TABLE Xe
(
	id INT IDENTITY PRIMARY KEY,
	tenxe NVARCHAR (50),
	idHangXe INT ,
	biensoxe NVARCHAR(100),

	FOREIGN KEY (idHangXe) REFERENCES dbo.HangXe(id)
)


CREATE TABLE KhachHang
(
	id INT IDENTITY PRIMARY KEY,
	hoten NVARCHAR(100) NOT NULL,
	diachi NVARCHAR(100),
	sodienthoai VARCHAR(15),
	idXe INT NOT NULL,
	status INT NOT NULL DEFAULT 0 -- 0=dang cho | 1 = da vao garage

	FOREIGN KEY (idXe) REFERENCES dbo.Xe(id)
)


CREATE TABLE PhuTung
(
	id INT IDENTITY PRIMARY KEY,
	tenphutung NVARCHAR (100),
	idHangXe INT NOT NULL,
	price FLOAT
	
	FOREIGN KEY (idHangXe) REFERENCES dbo.HangXe(id)
)


CREATE TABLE KhuSuaChua
(
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100) NOT NULL DEFAULT N'Insert name',
	status NVARCHAR(100) NOT NULL DEFAULT N'AVAILABLE'	-- 0:trong || 1:dang lam viec
)

CREATE TABLE HoaDon 	
(
	id INT IDENTITY PRIMARY KEY,
	DateCheckIn DATE NOT NULL DEFAULT GETDATE(),
	DateCheckOut DATE,
	idKhuSuaChua INT NOT NULL,
	status INT NOT NULL DEFAULT 0, -- 1: da thanh toan && 0: chua thanh toan
	totalPrice float 
	
	FOREIGN KEY (idKhuSuaChua) REFERENCES dbo.KhuSuaChua(id),
)

CREATE TABLE ThongTinHoaDon
(
	id INT IDENTITY PRIMARY KEY,
	idHoaDon INT NOT NULL,
	idPhuTung INT NOT NULL,
	COUNT INT NOT NULL DEFAULT 0
	
	FOREIGN KEY (idHoaDon) REFERENCES dbo.HoaDon(id),
	FOREIGN KEY (idPhuTung) REFERENCES dbo.PhuTung(id)
)

CREATE TABLE AccountG
(
	UserName NVARCHAR(100) PRIMARY KEY,	
	DisplayName NVARCHAR(100) NOT NULL DEFAULT N'UITer',
	PassWord NVARCHAR(1000) NOT NULL DEFAULT 0,
	Type INT NOT NULL  DEFAULT 0 -- 1: admin && 0: staff
)
GO

insert into dbo.AccountG values (N'manager',N'mng',N'12345',1)
GO

create proc USP_LoginG
@userName nvarchar(100) , @passWord nvarchar(100)
as
begin
 select * from dbo.AccountG where UserName= @userName and PassWord = @passWord
end
GO 

create proc USP_GetAreaList
as select * from dbo.KhuSuaChua
go

EXEC USP_GetAreaList

INSERT dbo.KhuSuaChua (name )
VALUES ( N'Khu 1')
INSERT dbo.KhuSuaChua (name )
VALUES ( N'Khu 2')
INSERT dbo.KhuSuaChua (name )
VALUES ( N'Khu 3')
INSERT dbo.KhuSuaChua (name )
VALUES ( N'Khu 4')
INSERT dbo.KhuSuaChua (name )
VALUES ( N'Khu 5')
INSERT dbo.KhuSuaChua (name )
VALUES ( N'Khu 6')
GO

INSERT dbo.HangXe(tenhangxe )
VALUES ( N'Toyota')
INSERT dbo.HangXe(tenhangxe )
VALUES ( N'Mercedes')
INSERT dbo.HangXe (tenhangxe )
VALUES ( N'BMW')
GO

DELETE FROM KhachHang
DELETE FROM Xe

INSERT	dbo.HoaDon
        ( DateCheckIn ,
          DateCheckOut ,
          idKhuSuaChua ,
          status
        )
VALUES  ( GETDATE() , -- DateCheckIn - date
          NULL , -- DateCheckOut - date
          1, -- idTable - int
          0  -- status - int
        )
INSERT	dbo.HoaDon
        ( DateCheckIn ,
          DateCheckOut ,
          idKhuSuaChua ,
          status
        )
VALUES  ( GETDATE() , -- DateCheckIn - date
          NULL , -- DateCheckOut - date
          2, -- idTable - int
          0  -- status - int
        )

INSERT	dbo.ThongTinHoaDon
        ( idHoaDon, idPhuTung, count )
VALUES  ( 1, -- idBill - int
          1, -- idFood - int
          2  -- count - int
          )
INSERT	dbo.ThongTinHoaDon
        ( idHoaDon, idPhuTung, count )
VALUES  ( 2, -- idBill - int
          2, -- idFood - int
          3  -- count - int
          )

SELECT f.tenphutung, bi.count, f.price, f.price*bi.count AS totalPrice 
FROM dbo.ThongTinHoaDon AS bi, dbo.HoaDon AS b, dbo.PhuTung AS f 
WHERE bi.idHoaDon = b.id AND bi.idPhuTung = f.id AND b.status = 0 AND b.idKhuSuaChua = 1
go

CREATE PROC [dbo].[USP_InsertBill]
@idArea INT
AS
BEGIN
	INSERT dbo.HoaDon
	        ( DateCheckIn ,
	          DateCheckOut ,
	          idKhuSuaChua ,
	          status	   
	        )
	VALUES  ( GETDATE() , -- DateCheckIn - date
	          NULL , -- DateCheckOut - date
	          @idArea , -- idTable - int
	          0  -- status - int
	        )
END
GO

CREATE PROC [dbo].[USP_InsertBillInfo]
@idHoaDon INT, @idPhutung INT, @count INT
AS
BEGIN

	DECLARE @isExitsBillInfo INT
	DECLARE @phutungCount INT = 1
	
	SELECT @isExitsBillInfo = id, @phutungCount = b.count 
	FROM dbo.ThongTinHoaDon AS b 
	WHERE idHoaDon = @idHoaDon AND idPhuTung = @idPhutung

	IF (@isExitsBillInfo > 0)
	BEGIN
		DECLARE @newCount INT = @phutungCount + @count
		IF (@newCount > 0)
			UPDATE dbo.ThongTinHoaDon SET count = @phutungCount + @count WHERE idPhuTung = @idPhutung
		ELSE
			DELETE dbo.ThongTinHoaDon WHERE idHoaDon = @idHoaDon AND idPhuTung = @idPhutung
	END
	ELSE
	BEGIN
		INSERT	dbo.ThongTinHoaDon
        ( idHoaDon, idPhuTung, count )
		VALUES  ( @idHoaDon, -- idBill - int
          @idPhutung, -- idFood - int
          @count  -- count - int
          )
	END
END
GO

CREATE TRIGGER UTG_UpdateThongTinHoaDon
ON dbo.ThongTinHoaDon FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @idBill INT
	
	SELECT @idBill = idHoaDon FROM Inserted
	
	DECLARE @idTable INT
	
	SELECT @idTable = idKhuSuaChua FROM dbo.HoaDon WHERE id = @idBill AND status = 0
	
	UPDATE dbo.KhuSuaChua SET status = N'Working' WHERE id = @idTable
END
GO

CREATE TRIGGER UTG_UpdateHoaDon
ON dbo.HoaDon FOR UPDATE
AS
BEGIN
	DECLARE @idBill INT
	
	SELECT @idBill = id FROM Inserted	
	
	DECLARE @idTable INT
	
	SELECT @idTable = idKhuSuaChua FROM dbo.HoaDon WHERE id = @idBill
	
	DECLARE @count int = 0
	
	SELECT @count = COUNT(*) FROM dbo.HoaDon WHERE idKhuSuaChua = @idTable AND status = 0
	
	IF (@count = 0)
		UPDATE dbo.KhuSuaChua SET status = N'Available' WHERE id = @idTable
END
GO

UPDATE dbo.KhachHang SET status = 1  
WHERE KhachHang.id IN
(SELECT *
FROM [dbo].[KhachHang] inner join [dbo].[Xe] on KhachHang.idXe = Xe.id 
WHERE xe.biensoxe = 'asdasd' )

UPDATE [dbo].[KhachHang]  
SET [dbo].[KhachHang].[status] = 1  
WHERE sodienthoai = 'abc'




SELECT KhachHang.hoten as N'Họ tên', KhachHang.diachi as N'Địa chỉ', KhachHang.sodienthoai as N'Số điện thoại', Xe.tenxe as N'Tên xe', Xe.biensoxe as N'Biển số xe', HangXe.tenhangxe as N'Hãng xe' 
FROM[dbo].[KhachHang] inner join[dbo].[Xe] on KhachHang.idXe = Xe.id inner join[dbo].[HangXe] on Xe.idHangXe = HangXe.id 
WHERE KhachHang.status =0
go

CREATE PROC [dbo].[USP_GetListBillByDate]
@checkIn date, @checkOut date
AS 
BEGIN
	SELECT t.name AS [Tên khu], b.totalPrice AS [Tổng tiền], DateCheckIn AS [Ngày vào], DateCheckOut AS [Ngày ra]
	FROM dbo.HoaDon AS b,dbo.KhuSuaChua AS t
	WHERE DateCheckIn >= @checkIn AND DateCheckOut <= @checkOut AND b.status = 1
	AND t.id = b.idKhuSuaChua
END
GO