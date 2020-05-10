create database assignment2_productManagement;
use assignment2_productManagement;

create table customers
(
    MaKhach      int primary key,
    TenKhachHang nvarchar(50),
    SoDienThoai  varchar(15)
);

create table Items
(
    MaHang  varchar(10) primary key,
    TenHang nvarchar(50),
    SoLuong int,
    DonGia  int
);

create table CustomerItem
(
    MaKhach int,
    MaHang  varchar(10),
    SoLuong int,
    primary key (MaHang, MaKhach)
);

alter table CustomerItem
    add foreign key (MaKhach) references customers (MaKhach)
        on update cascade
        on delete restrict,
    add foreign key (MaHang) references Items (MaHang)
        on update cascade
        on delete restrict;


insert into customers
values ('1', 'Dinh Truong Son', '1234567'),
       ('2', 'Mai Thanh Minh', '1357999'),
       ('3', 'Nguyen Hong Ha', '246888');

insert into Items
values ('TL', 'Tu Lanh', 5, 3500),
       ('TV', 'Ti Vi', 2, 3000),
       ('DH', 'Dieu Hoa', 1, 8000),
       ('QD', 'Quat Da', 5, 1700),
       ('MG', 'May Giat', 3, 5000);

insert into CustomerItem
values (1, 'TL', 4),
       (1, 'MG', 1),
       (2, 'TV', 1),
       (3, 'DH', 1),
       (3, 'TL', 1);

delimiter //
create procedure showCustomers()
begin
    select * from customers;
end //
delimiter ;

delimiter //
create procedure showItems()
begin
    select * from items;
end //
delimiter ;

delimiter //
create procedure showCustomerItem()
begin
    select * from customeritem;
end //
delimiter ;

create view SaleInfo as
select CustomerItem.MaKhach,
       TenKhachHang,
       CustomerItem.MaHang,
       TenHang,
       I.SoLuong                       as Kho,
       CustomerItem.SoLuong            as DatHang,
       DonGia,
       (CustomerItem.SoLuong * DonGia) as ThanhTien
from CustomerItem
         join Items I on CustomerItem.MaHang = I.MaHang
         join customers c on CustomerItem.MaKhach = c.MaKhach;

delimiter //
create procedure showSaleInfo()
begin
    select * from SaleInfo;
end //
delimiter ;

-- 4 Hiển thị tổng số tiền mà cửa hàng đã thu được từ các khách hàng trên
select sum(CustomerItem.SoLuong * DonGia) as ThanhTien
from customeritem
         join customers c on CustomerItem.MaKhach = c.MaKhach
         join Items I on CustomerItem.MaHang = I.MaHang;

-- 5 Hiển thị tên, số tiền đã mua của người khách hàng đã trả tiền cho cửa hàng nhiều nhất
select TenKhachHang, TenHang, I.SoLuong, DonGia, sum(CustomerItem.SoLuong * DonGia) as ThanhTien
from customeritem
         join customers c on CustomerItem.MaKhach = c.MaKhach
         join Items I on CustomerItem.MaHang = I.MaHang
group by TenKhachHang;

-- 6 Kiểm tra xem người khách có số điên thoại 2468888 có mua mặt hàng Tủ lạnh không? Nếu có
-- mua hiện ra dòng chũ “Có mua”, ngược lại “Không mua”.

select SoDienThoai,
       count(SoDienThoai)                                as SoLuong,
       IF(count(SoDienThoai) > 0, 'Co Mua', 'Khong Mua') as KetLuan
from CustomerItem
         join customers c on CustomerItem.MaKhach = c.MaKhach
where SoDienThoai = '2468888'
group by SoDienThoai;


-- 7 Tính tổng số hàng hóa và tổng tiền còn lại trong kho(Số còn lại bằng tổng số trừ đi số đã bán).

select CustomerItem.MaHang,
       TenHang,
       CustomerItem.SoLuong               as SoLuongBan,
       I.SoLuong                          as SoLuongCo,
       (I.SoLuong - CustomerItem.SoLuong) as TonKho
from CustomerItem
         join Items I on CustomerItem.MaHang = I.MaHang;

-- 8. Hiẻn thị danh sách 3 mặt hàng bán chạy nhất(số lượng bán nhiều nhất).
select CustomerItem.MaHang,
       TenHang,
       CustomerItem.SoLuong as SoLuongBan
from CustomerItem
         join Items I on CustomerItem.MaHang = I.MaHang
order by SoLuongBan desc
limit 3;

-- 9 Hiển thị tất cả các mặt hàng mà chưa bán được một cái nào.
select MaHang, TenHang
from items
where MaHang not in (select MaHang from SaleInfo);

# 10. Hiển thị danh sách những người mua nhiều hơn một mặt hàng.
select *
from (select TenKhachHang, TenHang, count(TenHang) as SlgMua
      from SaleInfo
      group by TenKhachHang) as resultTable
where resultTable.SlgMua > 1;


# 11. Hiển thị danh sách những người mua hàng có số lượng nhiều hơn một cái.
select TenKhachHang, DatHang
from SaleInfo
where DatHang > 1;

# 12. Tạo một trigger trên bảng CustomerItem tên là tgNoInsert cho sự kiện Insert. Trigger này có
# nhiệm vụ là bảo đảm rằng sẽ không cho người dùng nhập thêm thông tin mua hàng nếu như số
# lượng mặt hàng ở trong kho không còn đủ hoặc bằng không.
# Sau khi tạo xong trigger nhập thử dữ liệu sau để kiểm tra kết quả:
#      a. Mai Thanh Minh mua một cái Tủ lạnh
#      b. Nguyen Hong Ha mua 3 cái máy giặt
-- ----------------------------

# 13. Viết một stored procedure tên là spSummary để hiển thị các thông tin sau trên cùng một
# dòng: Tổng số lượng các mặt hàng, Tổng số đã bán, Tổng tiền thu được, Tổng số hàng còn lại
# trong kho, Số lượng khách hàng đã mua.

# Tổng số lượng các mặt hàng, Tổng số đã bán, Tổng tiền thu được, Tổng số hàng còn lại
# trong kho, Số lượng khách hàng đã mua.
drop procedure no13;

delimiter //
create procedure no13()
    begin
    set @TongSoMatHang = (select count(*) from Items);
    set @TongSoDaban = (select sum(SoLuong)from customeritem);
    set @TongTienThuDuoc = (select sum(CustomerItem.SoLuong * DonGia) from customeritem join Items I on CustomerItem.MaHang = I.MaHang);
    set @TongSoHangConLai = (select sum(I.SoLuong) - sum(customeritem.SoLuong)from customeritem join Items I on CustomerItem.MaHang = I.MaHang);
    set @SoLuongKhachDaMua = (select count(*) from (select * from customeritem group by MaKhach) as resultTable);
    select round(@TongSoMatHang,0)     as 'Tong So Mat Hang',
           round(@TongSoDaban,0)       as 'Tong So Da Ban',
                 round(@TongTienThuDuoc,0)   as 'Tong Tien Thu Duoc',
                       round(@TongSoHangConLai,0)  as 'Tong So Hang Con Lai',
                             round(@SoLuongKhachDaMua,0) as 'So Luong Khach Da Mua';
    end; //
delimiter ;

call no13();

# 14. Sửa stored procedure trên để nhận vào 1 tham số là tên của một mặt hàng. Hiển thị các thông
# tin sau theo mặt hàng đó: Tổng số lượng mặt hàng đó, Tổng số đã bán, Tổng tiền thu được, Tổng
# số hàng còn lại trong kho, Số lượng khách hàng đã mua mặt hàng đó.

delimiter //
create procedure no14(in Ten nvarchar(50))
begin
    set @TongSoMatHang = (select SoLuong from Items where TenHang = Ten);
    set @TongSoDaban = (select sum(CustomerItem.SoLuong)from customeritem join Items I2 on CustomerItem.MaHang = I2.MaHang where TenHang = Ten);
    set @TongTienThuDuoc = (select sum(CustomerItem.SoLuong * DonGia) from customeritem join Items I on CustomerItem.MaHang = I.MaHang  where TenHang = Ten);
    set @TongSoHangConLai = @TongSoMatHang - @TongSoDaban;
    set @SoLuongKhachDaMua = (select count(*) from (select TenKhachHang from SaleInfo  where TenHang = Ten) as resultTable) ;
    select round(@TongSoMatHang,0)     as 'Tong So Mat Hang',
           round(@TongSoDaban,0)       as 'Tong So Da Ban',
           round(@TongTienThuDuoc,0)   as 'Tong Tien Thu Duoc',
           round(@TongSoHangConLai,0)  as 'Tong So Hang Con Lai',
           round(@SoLuongKhachDaMua,0) as 'So Luong Khach Da Mua';
end; //
delimiter ;