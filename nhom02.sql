﻿--Kiểm tra xem database đã tồn tại hay chưa, tồn tại thì xóa
IF EXISTS (SELECT * FROM sys.databases WHERE name = N'Nhom2')
BEGIN
    -- Đóng tất cả các kết nối đến cơ sở dữ liệu
    EXECUTE sp_MSforeachdb 'IF ''?'' = ''Nhom2'' 
    BEGIN 
        DECLARE @sql AS NVARCHAR(MAX) = ''USE [?]; ALTER DATABASE [?] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;''
        EXEC (@sql)
    END'
    -- Xóa tất cả các kết nối tới cơ sở dữ liệu (thực hiện qua hệ thống master)
    USE master;

    -- Xóa cơ sở dữ liệu nếu tồn tại
    DROP DATABASE Nhom2;
END

-- Tạo cơ sở dữ liệu mới
CREATE DATABASE Nhom2;
GO

-- Sử dụng cơ sở dữ liệu vừa tạo
USE Nhom2;
GO

-- Tạo bảng KHACHHANG
CREATE TABLE KHACHHANG
(
    MAKHACHHANG CHAR(9) PRIMARY KEY,
    TENCONGTY NVARCHAR(50) null,
    TENGIAODICH NVARCHAR(50) null,
	DIACHI NVARCHAR(50),
    EMAIL VARCHAR(50) not null,
    DIENTHOAI VARCHAR(11) not null,
    FAX VARCHAR(20) null
);

-- Tạo bảng QuocGia
CREATE TABLE QuocGia
(
    maQG CHAR(10) PRIMARY KEY,
    tenQG NVARCHAR(50) not null
);

-- Tạo bảng TinhTP
CREATE TABLE TinhTP
(
    maTP CHAR(10) PRIMARY KEY,
    tenTP NVARCHAR(50) not null ,
    maQG CHAR(10) null,
    CONSTRAINT fk_TinhTP_QuocGia FOREIGN KEY (maQG) REFERENCES QuocGia(maQG) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Tạo bảng QuanHuyen
CREATE TABLE QuanHuyen
(
    maQH CHAR(10) PRIMARY KEY,
    tenQH NVARCHAR(50) not null ,
    maTP CHAR(10) not null,
    CONSTRAINT fk_QuanHuyen_TinhTP FOREIGN KEY (maTP) REFERENCES TinhTP(maTP) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Tạo bảng PhuongXa
CREATE TABLE PhuongXa
(
    maPX CHAR(10) PRIMARY KEY,
    tenPX NVARCHAR(50) not null,
    maQH CHAR(10) not null,
    CONSTRAINT fk_PhuongXa_QuanHuyen FOREIGN KEY (maQH) REFERENCES QuanHuyen(maQH) ON UPDATE CASCADE ON DELETE CASCADE
);

--xóa cột địa chỉ
ALTER TABLE KHACHHANG
	DROP COLUMN DIACHI;

-- Thêm cột maPX và soNhaTenDuong vào bảng KHACHHANG
ALTER TABLE KHACHHANG
    ADD maPX CHAR(10) not null,
        soNhaTenDuong NVARCHAR(50) not null ;

-- Thêm ràng buộc khóa ngoại cho maPX trong bảng KHACHHANG
ALTER TABLE KHACHHANG
    ADD CONSTRAINT fk_KhachHang_PhuongXa FOREIGN KEY (maPX) REFERENCES PhuongXa(maPX) ON UPDATE CASCADE ON DELETE CASCADE;

-- Tạo bảng NHANVIEN
CREATE TABLE NHANVIEN
(
    MANHANVIEN CHAR(9) PRIMARY KEY,
    HO NVARCHAR(10) not null,
    TEN NVARCHAR(30) not null,
    NGAYSINH DATE not null,
    NGAYLAMVIEC DATE not null,
    DIACHI NVARCHAR(50),
    DIENTHOAI VARCHAR(11) not null,
	EMAIL VARCHAR(50),
	FAX CHAR(50) null,
    LUONGCOBAN MONEY null,
    PHUCAP MONEY not null,
    CONSTRAINT CK_NHANVIEN_NGAYSINH CHECK (DATEDIFF(YEAR, NGAYSINH, GETDATE()) BETWEEN 18 AND 60)
);

--xóa cột địa chỉ
ALTER TABLE NHANVIEN
	DROP COLUMN DIACHI;

-- Thêm cột maPX và soNhaTenDuong vào bảng NHANVIEN
ALTER TABLE NHANVIEN
    ADD maPX CHAR(10) null,
        soNhaTenDuong NVARCHAR(50) null;

-- Thêm ràng buộc khóa ngoại cho maPX trong bảng NHANVIEN
ALTER TABLE NHANVIEN
    ADD CONSTRAINT fk_NhanVien_PhuongXa FOREIGN KEY (maPX) REFERENCES PhuongXa(maPX) ON UPDATE CASCADE ON DELETE CASCADE;

-- Sửa số điện thoại 10 chữ số hoặc 11 chữ số duy nhất trong NhanVien
alter table NHANVIEN
	add constraint chk_NhanVien_SDT check (
    DIENTHOAI like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
    OR DIENTHOAI like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') ;
alter table NHANVIEN
	add constraint uq_NhanVien_SDT unique (DIENTHOAI);
--   bổ sung email có ký tự @ bắt đầu bằng chữ cái   trong bảng NHANVIEN
alter table NHANVIEN
	add constraint chk_KhachHang_Email check (EMAIL LIKE '[a-zA-Z]%@%');
alter table NHANVIEN
	add constraint uq_NhanVien_Email unique (EMAIL);

-- Sửa số điện thoại 10 chữ số hoặc 11 chữ số duy nhất trong KhachHang
alter table KHACHHANG
	add constraint chk_KhachHang_SDT check (
	DIENTHOAI like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
    OR DIENTHOAI like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'  ) ;
alter table KHACHHANG
	add constraint uq_KhachHang_SDT unique (DIENTHOAI);
--   bổ sung email có ký tự @ bắt đầu bằng chữ cái   trong bảng KhachHang
alter table KHACHHANG
	add constraint chk_Kh_Email check (EMAIL LIKE '[a-zA-Z]%@%');
alter table KHACHHANG
	add constraint uq_KHACHHANG_Email unique (EMAIL);

-- Tạo bảng DONDATHANG
CREATE TABLE DONDATHANG
(
    SOHOADON CHAR(9) PRIMARY KEY,
    MAKHACHHANG CHAR(9) not null,
    MANHANVIEN CHAR(9) not null,
    NGAYDATHANG DATE null,
	NGAYCHUYENHANG DATE null,
    NGAYGIAOHANG DATE not null,
    NOIGIAOHANG NVARCHAR(50) not null ,
    CONSTRAINT fk_DONDATHANG_KHACHHANG FOREIGN KEY (MAKHACHHANG) REFERENCES KHACHHANG(MAKHACHHANG)ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_DONDATHANG_NHANVIEN FOREIGN KEY (MANHANVIEN) REFERENCES NHANVIEN(MANHANVIEN)ON UPDATE no action ON DELETE no action,
    CONSTRAINT chk_DONDATHANG_NGAYCHUYENHANG CHECK (NGAYCHUYENHANG >= NGAYDATHANG),
	CONSTRAINT chk_DONDATHANG_NGAYGIAOHANG CHECK (NGAYGIAOHANG >= NGAYCHUYENHANG)
);
--xóa cột địa chỉ
ALTER TABLE DONDATHANG
	DROP COLUMN NOIGIAOHANG;
-- Thêm cột maPX và soNhaTenDuong vào bảng NHANVIEN
ALTER TABLE DONDATHANG
    ADD maPX CHAR(10) null,
        soNhaTenDuong NVARCHAR(50) null;
-- ngày tạo đơn hàng bằng ngày hiện tại
alter table  DONDATHANG 
	add constraint  df_DonDatHang_ngayDatHang default  getdate() for NGAYDATHANG;

-- Tạo bảng NHACUNGCAP
CREATE TABLE NHACUNGCAP
(
    MACONGTY CHAR(10) PRIMARY KEY,
    TENCONGTY NVARCHAR(50) not null ,
	TENGIAODICH NVARCHAR(50) null , 
    DIACHI NVARCHAR(50),
    DIENTHOAI VARCHAR(11) not null,
    FAX VARCHAR(20) null,
    EMAIL NVARCHAR(50) not null
);
-- Sửa số điện thoại 10 chữ số hoặc 11 chữ số duy nhất trong NHACUNGCAP
alter table NHACUNGCAP
	add constraint chk_NhaCungCap_SDT check (
	DIENTHOAI like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
	or DIENTHOAI like'[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') ;
alter table NhaCungCap
	add constraint uq_NhaCungCap_SDT unique (DIENTHOAI);
--   bổ sung email có ký tự @ bắt đầu bằng chữ cái trong bảng NHACUNGCAP
alter table NHACUNGCAP
	add constraint chk_NhaCungCap_Email check (EMAIL LIKE '[a-zA-Z]%@%');
alter table NhaCungCap
	add constraint uq_NhaCungCap_Email unique (EMAIL);

--xóa cột địa chỉ
ALTER TABLE NHACUNGCAP
	DROP COLUMN DIACHI
-- Thêm cột maPX và soNhaTenDuong vào bảng NHACUNGCAP
ALTER TABLE NHACUNGCAP
    ADD maPX CHAR(10) not null,
        soNhaTenDuong NVARCHAR(50) not null;

-- Thêm ràng buộc khóa ngoại cho maPX trong bảng NHACUNGCAP
ALTER TABLE NHACUNGCAP
    ADD CONSTRAINT fk_NhaCungCap_PhuongXa FOREIGN KEY (maPX) REFERENCES PhuongXa(maPX)ON UPDATE CASCADE ON DELETE CASCADE;

-- Tạo bảng LOAIHANG
CREATE TABLE LOAIHANG
(
    MALOAIHANG CHAR(5) PRIMARY KEY,
    TENLOAIHANG NVARCHAR(50) not null
);

-- Tạo bảng MATHANG
CREATE TABLE MATHANG
(
    MAHANG CHAR(5) PRIMARY KEY,
    TENHANG NVARCHAR(50) not null,
    MACONGTY CHAR(10) not null,
    MALOAIHANG CHAR(5) not null,
    SOLUONG INT CHECK (SOLUONG >= 0) not null,
    DONVITINH NVARCHAR(5) DEFAULT N'Cái' null,
    GIAHANG MONEY CHECK (GIAHANG >= 0) not null,
    CONSTRAINT fk_MATHANG_NHACUNGCAP FOREIGN KEY (MACONGTY) REFERENCES NHACUNGCAP(MACONGTY) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_MATHANG_LOAIHANG FOREIGN KEY (MALOAIHANG) REFERENCES LOAIHANG(MALOAIHANG) ON UPDATE CASCADE ON DELETE CASCADE
);


-- Tạo bảng CHITIETDATHANG
CREATE TABLE CHITIETDATHANG
(
    SOHOADON CHAR(9),
    MAHANG CHAR(5),
    GIABAN MONEY not null CHECK (GIABAN >= 0),
    SOLUONG INT null DEFAULT 1 CHECK (SOLUONG > 0),
    MUCGIAMGIA MONEY null DEFAULT 0,
    PRIMARY KEY (SOHOADON, MAHANG),
    CONSTRAINT fk_CHITIETDATHANG_DONDATHANG FOREIGN KEY (SOHOADON) REFERENCES DONDATHANG(SOHOADON) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_CHITIETDATHANG_MATHANG FOREIGN KEY (MAHANG) REFERENCES MATHANG(MAHANG) ON UPDATE no action  ON DELETE no action
);

---------------------------------------------------------------------------------------------------------------------------------------------------------------	
-- Tạo thông tin trong bảng QuocGia
INSERT INTO QuocGia
VALUES 
		('QG00000001', N'Việt Nam');

-- Tạo thông tin trong bảng TinhTP
INSERT INTO TinhTP
VALUES 
		('T000000001', N'Đà Nẵng',null),
		('T000000002', N'Hà Nội',null),
		('T000000003', N'Ninh Bình',null),
		('T000000004', N'Quảng Trị',null),
		('T000000005', N'TP Hồ Chí Minh',null);

-- Tạo thông tin trong bảng QuanHuyen
INSERT INTO QuanHuyen
VALUES 
		('QH00000001', N'Liên Chiểu', 'T000000001'),
		('QH00000002', N'Long Biên', 'T000000002'),
		('QH00000003', N'Kim Sơn', 'T000000003'),
		('QH00000004', N'Gio Linh', 'T000000004'),
		('QH00000005', N'Quận 7', 'T000000005');
-- Tạo thông tin trong bảng PhuongXa
INSERT INTO PhuongXa
VALUES
		('PX00000001', N'Hòa Minh','QH00000001'),
		('PX00000002', N'Ngọc Lâm','QH00000002'),
		('PX00000003', N'Đông Hải','QH00000003'),
		('PX00000004', N'Bắc Sơn','QH00000004'),
		('PX00000005', N'Phường 1','QH00000005');

-- Tạo thông tin trong bảng KHACHHANG
set dateformat dmy
insert into KHACHHANG
values 
		('KH0000001','Aristino','GD001','Aristino@gmail.com','0909090919','fax001','PX00000001',N'15 Lý Thường Kiệt'),
		('KH0000002','5S Fashion','GD002','SFashion@gmail.com','0909090908','fax002','PX00000002',N'20 Lê Đại Hành'),
		('KH0000003','Routine','GD003','Routine@gmail.com','0909090907','fax003','PX00000003',N'100 Điện Biên Phủ'),
		('KH0000004','Coolmate','GD004','Coolmate@gmail.com','0909090906','fax004','PX00000004',N'26 Quang Trung'),
		('KH0000005','Yody','GD005','Yody@gmail.com','0909090905','fax005','PX00000005',N'12 Nguyễn Tất Thành');

-- Tạo thông tin trong bảng NHANVIEN
set dateformat dmy
insert into NHANVIEN
values
		('NV0000001',N'Đặng',N'Công Kiệt','28-10-2005',getdate(),'0101010101','congkiet@gmail.com','fax006',5000000,2000000,'PX00000001',N'12 Điện Biên Phủ'),
		('NV0000002',N'Nguyễn',N'Khánh Ly','12-6-2005',getdate(),'0101010102','khanhly@gmail.com','fax007',5000000,2000000,'PX00000002',N'15 Điện Biên Phủ'),
		('NV0000003',N'Nguyễn',N'Khánh Linh','26-10-2005',getdate(),'0101013101','khanhlinh@gmail.com','fax008',5000000,2000000,'PX00000003',N'12 Ông Ích Khiêm'),
		('NV0000004',N'Phạm',N'Huy Hoàng','25-10-2005',getdate(),'0101010104','huyhoang@gmail.com','fax009',5000000,2000000,'PX00000004',N'23 Nguyễn Tất Thành'),
		('NV0000005',N'Đinh',N'Tiên Hoàng','24-10-2005',getdate(),'0101010181','tienhoang@gmail.com','fax010',5000000,2000000,'PX00000005',N'01 Lê Lợi');

-- Tạo thông tin trong bảng LOAIHANG
insert into LOAIHANG
values 
		('LH001',N'Quần'),
		('LH002',N'Áo'),
		('LH003',N'Túi xách'),
		('LH004',N'Khăn'),
		('LH005',N'Giày');

-- Tạo thông tin trong bảng DONDATHANG
set dateformat dmy
insert into DONDATHANG
values 
		('HD0000001','KH0000001','NV0000001',getdate(),null,getdate()+4,'PX00000001',NULL),
		('HD0000002','KH0000001','NV0000002',getdate(),null,getdate()+4,'PX00000002',NULL),
		('HD0000003','KH0000003','NV0000001',getdate(),getdate()+3,getdate()+4,'PX00000001',N'12 Lý Thường Kiệt'),
		('HD0000004','KH0000004','NV0000004',getdate(),getdate()+2,getdate()+4,'PX00000004',N'26 Quang Trung'),
		('HD0000005','KH0000005','NV0000005',getdate(),getdate()+1,getdate()+4,'PX00000003',N'66 Điện Biên Phủ');

-- Tạo thông tin trong bảng NHACUNGCAP
INSERT INTO NHACUNGCAP
VALUES
		('CT00000001',N'Aristino','GD001','0123456789',null,'Aristino@gmail.com','PX00000001', N'23 Nguyễn Tất Thành'),
		('CT00000005',N'5S Fashion','GD002','0113456789',null,'Bristino@gmail.com','PX00000001', N'24 Nguyễn Tất Thành'),
		('CT00000002',N'Công ty B','GD003','0121456789',null,'Gristino@gmail.com','PX00000002', N'15 Lý Thường Kiệt'),
		('CT00000003',N'Công ty C','GD004','0123156789',null,'Dristino@gmail.com','PX00000003', N'26 Quang Trung'),
		('CT00000004',N'Công ty D','GD005','0123416789',null,'Eristino@gmail.com','PX00000004', N'66 Điện Biên Phủ');

-- Tạo thông tin trong bảng MATHANG
insert into MATHANG
values 
		('MH001',N'Quần jeans','CT00000001','LH001',50,null,5000000),--100k/cái
		('MH002',N'Áo phông','CT00000001','LH002',40,null,2000000),--50k/cái
		('MH003',N'Quần jeans','CT00000002','LH001',60,null,4800000),--80k/cái
		('MH004',N'Giày thể thao','CT00000003','LH005',20,null,3000000),--150k/cái
		('MH005',N'Quần đùi','CT00000003','LH001',30,null,1200000);--40k/cái

-- Tạo thông tin trong bảng CHITIETDATHANG
insert into CHITIETDATHANG
values 
		('HD0000001','MH001',500000,5,null),
		('HD0000001','MH002',250000,5,null),
		('HD0000003','MH002',450000,10,null),
		('HD0000004','MH004',300000,2,10000),
		('HD0000005','MH005',40000,20,10000);

---------------------------------------------------------------------------------------------------------------------------------------------------------------		
--a) Cập nhật lại giá trị trường NGAYCHUYENHANG của những bản ghi 
--có NGAYCHUYENHANG chưa xác định (NULL) trong bảng DONDATHANG bằng với giá trị của trường NGAYDATHANG.
update DONDATHANG
	set NGAYCHUYENHANG = NGAYDATHANG
	where NGAYCHUYENHANG is NULL
--select * from DONDATHANG
--b) Tăng số lượng hàng của những mặt hàng do công ty Aristino cung cấp lên gấp đôi.
update MATHANG
	set SOLUONG = SOLUONG*2
	from NHACUNGCAP
	where NHACUNGCAP.MACONGTY = MATHANG.MACONGTY
		and TENCONGTY = N'Aristino'
/*select * 
from MATHANG m, NHACUNGCAP ncc
where m.MACONGTY=ncc.MACONGTY*/
--c) Cập nhật giá trị của trường soNhaTenDuong trong bảng DONDATHANG bằng địa chỉ của 
--khách hàng đối với những đơn đặt hàng chưa xác định được nơi giao hàng (giá trị trường soNhaTenDuong bằng NULL).
UPDATE DONDATHANG
set DONDATHANG.soNhaTenDuong = KHACHHANG.soNhaTenDuong
from KHACHHANG
where 
	KHACHHANG.MAKHACHHANG = DONDATHANG.MAKHACHHANG and
	DONDATHANG.soNhaTenDuong is NULL
/*select * 
from DONDATHANG, KHACHHANG
where KHACHHANG.MAKHACHHANG = DONDATHANG.MAKHACHHANG*/
--d) Cập nhật lại dữ liệu trong bảng KHACHHANG sao cho nếu tên công ty và tên giao dịch của 
--khách hàng trùng với tên công ty và tên giao dịch của một nhà cung cấp nào đó thì 
--địa chỉ, điện thoại, fax và e-mail phải giống nhau.
UPDATE KHACHHANG
SET 
    KHACHHANG.DIENTHOAI = NHACUNGCAP.DIENTHOAI,
    KHACHHANG.FAX = NHACUNGCAP.FAX,
    KHACHHANG.EMAIL = NHACUNGCAP.EMAIL,
    KHACHHANG.maPX = NHACUNGCAP.maPX,
	KHACHHANG.soNhaTenDuong = NHACUNGCAP.soNhaTenDuong
FROM 
    KHACHHANG, NHACUNGCAP
WHERE 
    KHACHHANG.TENCONGTY = NHACUNGCAP.TENCONGTY AND
    KHACHHANG.TENGIAODICH = NHACUNGCAP.TENGIAODICH;
--e) Tăng lương lên gấp rưỡi cho những nhân viên bán được số lượng hàng nhiều hơn 8 trong năm 2024.
update NHANVIEN
	set LUONGCOBAN = LUONGCOBAN *1.5
	where MANHANVIEN in (
		select n.MANHANVIEN
		from NHANVIEN n , DONDATHANG d, CHITIETDATHANG c
		where
			n.MANHANVIEN = d.MANHANVIEN and
			d.SOHOADON = c.SOHOADON and
			year(NGAYDATHANG) = '2024'
		group by n.MANHANVIEN
		having SUM(SOLUONG) > 8
	)
--select * from NHANVIEN
--f) Tăng phụ cấp lên bằng 50% lương cho những nhân viên bán được hàng nhiều nhất.
update NHANVIEN
	set PHUCAP = LUONGCOBAN/2
	where MANHANVIEN in (
		select top 1 with ties n.MANHANVIEN
		from NHANVIEN n, DONDATHANG d, CHITIETDATHANG c
		where 
			n.MANHANVIEN = d.MANHANVIEN 
		and d.SOHOADON = c.SOHOADON
		group by n.MANHANVIEN
		order by SUM(SOLUONG) desc
	)
--select * from NHANVIEN

--g) Giảm 25% lương của những nhân viên trong năm 2024 không lập được bất kỳ đơn đặt hàng nào.
UPDATE NHANVIEN
SET LUONGCOBAN = LUONGCOBAN * 0.75
WHERE MANHANVIEN NOT IN (
    SELECT MANHANVIEN
    FROM DONDATHANG
    WHERE YEAR(NGAYDATHANG) = 2024
);
--select * from NHANVIEN

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--1.Cho biết danh sách các đối tác cung cấp hàng cho công ty
select *
from NHACUNGCAP

--2.Mã hàng, tên hàng và số lượng của các mặt hàng hiện có trong công ty.
SELECT 
    m.MAHANG,
    m.TENHANG,
    COALESCE(m.SOLUONG - SUM(c.SOLUONG), m.SOLUONG) AS SO_LUONG_HIEN_CO
FROM 
    MATHANG m
LEFT JOIN 
    CHITIETDATHANG c ON m.MAHANG = c.MAHANG
GROUP BY 
    m.MAHANG, m.TENHANG, m.SOLUONG;
--3.Họ tên và địa chỉ và năm bắt đầu làm việc của các nhân viên trong công ty
select MANHANVIEN,CONCAT(HO, ' ', TEN) AS HovaTen,maPX,soNhaTenDuong,YEAR(NGAYLAMVIEC) as NamBĐLamViec
from NHANVIEN 

--4.Địa chỉ và điện thoại của nhà cung cấp có tên giao dịch [VINAMILK]  là gì?
update NHACUNGCAP
set TENGIAODICH='VINAMILK'
where MACONGTY='CT00000003'
select TENGIAODICH,soNhaTenDuong,maPX,DIENTHOAI
from NHACUNGCAP 
where TENGIAODICH='VINAMILK'

--5.	Cho biết mã và tên của các mặt hàng có giá lớn hơn 100000 và số lượng hiện có ít hơn 50.
SELECT 
    MAHANG, 
    TENHANG, 
    SOLUONG, 
    FORMAT(GIAHANG, 'N0', 'vi-VN') + ' VND' AS GIAHANG_VND
FROM 
    MATHANG
WHERE 
    SOLUONG < 50 
    AND GIAHANG > 100000;

--6.	Cho biết mỗi mặt hàng trong công ty do ai cung cấp
select ncc.TENCONGTY, m.TENHANG
from MATHANG m
join NHACUNGCAP ncc on m.MACONGTY=ncc.MACONGTY

--7.	Công ty [Việt Tiến] đã cung cấp những mặt hàng nào?
update NHACUNGCAP
set TENCONGTY=N'Viet Tien'
where MACONGTY='CT00000003'
select ncc.TENCONGTY, m.MAHANG, m.TENHANG
from NHACUNGCAP ncc
join MATHANG m on ncc.MACONGTY=m.MACONGTY
where TENCONGTY=N'Viet Tien'

--8.	Loại hàng thực phẩm do những công ty nào cung cấp và địa chỉ của các công ty đó là gì?
update LOAIHANG
set TENLOAIHANG= N'Táo'
where MALOAIHANG='LH001'
select l.TENLOAIHANG, ncc.TENCONGTY, ncc.soNhaTenDuong
from NHACUNGCAP ncc
join MATHANG m on m.MACONGTY=ncc.MACONGTY
join LOAIHANG l on m.MALOAIHANG=l.MALOAIHANG
where l.TENLOAIHANG= N'Táo'

--9.	Những khách hàng nào (tên giao dịch) đã đặt mua mặt hàng Sữa hộp XYZ của công ty?
update MATHANG
set TENHANG = N'Sữa hộp XYZ'
where MAHANG = 'MH002'

select TENGIAODICH, TENHANG
from KHACHHANG k
join DONDATHANG d on d.MAKHACHHANG = k.MAKHACHHANG
join CHITIETDATHANG c on c.SOHOADON = d.SOHOADON
join MATHANG m on m.MAHANG = c.MAHANG
where TENHANG = N'Sữa hộp XYZ'

--10.	Đơn đặt hàng số 1 do ai đặt và do nhân viên nào lập, thời gian và địa điểm giao hàng là ở đâu?
select TEN [tên nhân viên], k.TENCONGTY [tên khách hàng], NGAYGIAOHANG[thời gian giao hàng], d.soNhaTenDuong [địa điểm]
from NHANVIEN n
	join DONDATHANG d on n.MANHANVIEN = d.MANHANVIEN
	join KHACHHANG k on d.MAKHACHHANG = k.MAKHACHHANG
where SOHOADON = 'HD0000001'

--11.	Hãy cho biết số tiền lương mà công ty phải trả cho mỗi nhân viên là bao nhiêu (lương = lương cơ bản + phụ cấp).
SELECT 
    ten AS [Tên Nhân Viên], 
    FORMAT(LUONGCOBAN + PHUCAP, 'N0', 'vi-VN') + ' VND' AS [Lương]
FROM 
    NHANVIEN;

--12.	Hãy cho biết có những khách hàng nào lại chính là đối tác cung cấp hàng của công ty (tức là có cùng tên giao dịch).
select n.TENCONGTY as N'tên công ty cung cấp', k.TENCONGTY N'tên công ty khách hàng'
from NHACUNGCAP n, KHACHHANG k
where
	n.TENGIAODICH = k.TENGIAODICH

--13.	Trong công ty có những nhân viên nào có cùng ngày sinh?
set dateformat dmy
update NHANVIEN
set NGAYSINH = '28/10/2005'
where NGAYSINH = '24/10/2005'

SELECT NV1.MANHANVIEN, CONCAT(NV1.HO, ' ', NV1.TEN) AS HoTen
FROM NHANVIEN NV1
JOIN NHANVIEN NV2 ON NV1.NGAYSINH = NV2.NGAYSINH
WHERE NV1.MANHANVIEN <> NV2.MANHANVIEN;

-- 14. Những đơn đặt hàng nào yêu cầu giao hàng ngay tại công ty đặt hàng và những đơn đó là của công ty nào?
SELECT dh.SOHOADON, kh.TENCONGTY
FROM DONDATHANG dh
JOIN KHACHHANG kh ON dh.MAKHACHHANG = kh.MAKHACHHANG
WHERE dh.soNhaTenDuong = kh.soNhaTenDuong;

-- 15. Tên công ty, tên giao dịch, địa chỉ và điện thoại của các khách hàng và nhà cung cấp
SELECT TENCONGTY, TENGIAODICH, soNhaTenDuong, DIENTHOAI
FROM KHACHHANG
UNION
SELECT TENCONGTY, TENGIAODICH, soNhaTenDuong, DIENTHOAI
FROM NHACUNGCAP;

-- 16. Những mặt hàng nào chưa từng được khách hàng đặt mua
SELECT 
    mh.MAHANG,
    mh.TENHANG,
    mh.SOLUONG,
    FORMAT(mh.GIAHANG, 'N0', 'vi-VN') + ' VND' AS GIAHANG
FROM 
    MATHANG mh
WHERE 
    mh.MAHANG NOT IN (SELECT ctdh.MAHANG FROM CHITIETDATHANG ctdh);

-- 17. Những nhân viên nào của công ty chưa từng lập bất kỳ một hoá đơn đặt hàng nào
SELECT NV.*
FROM NHANVIEN NV
WHERE NV.MANHANVIEN NOT IN (SELECT MANHANVIEN FROM DONDATHANG);

-- 18. Những nhân viên nào có lương cơ bản cao nhất
SELECT 
    NV.MANHANVIEN,NV.HO, NV.TEN,
    FORMAT(NV.LUONGCOBAN, 'N0', 'vi-VN') + ' VND' AS LUONGCOBAN
FROM 
    NHANVIEN NV
WHERE 
    NV.LUONGCOBAN = (SELECT MAX(LUONGCOBAN) FROM NHANVIEN);