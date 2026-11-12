import 'package:flutter/material.dart';

class DanhMuc {
  final String ten;
  final IconData icon;
  final Color mau;
  const DanhMuc(this.ten, this.icon, this.mau);
}

const danhSachDanhMuc = [
  DanhMuc('Ăn uống', Icons.restaurant_rounded, Color(0xFFFF7043)),
  DanhMuc('Đi lại', Icons.directions_bus_rounded, Color(0xFF42A5F5)),
  DanhMuc('Mua sắm', Icons.shopping_bag_rounded, Color(0xFFAB47BC)),
  DanhMuc('Giải trí', Icons.movie_rounded, Color(0xFFEC407A)),
  DanhMuc('Học tập', Icons.menu_book_rounded, Color(0xFF26A69A)),
  DanhMuc('Khác', Icons.more_horiz_rounded, Color(0xFF78909C)),
];

DanhMuc layDanhMuc(String ten) => danhSachDanhMuc.firstWhere(
  (d) => d.ten == ten,
  orElse: () => danhSachDanhMuc.last,
);
