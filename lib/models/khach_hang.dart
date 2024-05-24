import 'package:rent_bik/utils/common_variables.dart';
import 'package:rent_bik/utils/extesion.dart';

class KhachHang {
  KhachHang({
    this.maKhachHang,
    required this.cccd,
    required this.hoTen,
    required this.ngaySinh,
    required this.soDienThoai,
    this.hangGPLX,
    this.ghiChu,
  });

  int? maKhachHang;
  String cccd;
  String hoTen;
  DateTime ngaySinh;
  String soDienThoai;
  String? hangGPLX;
  String? ghiChu;

  factory KhachHang.fromJson(Map<String, dynamic> json) {
    return KhachHang(
      maKhachHang: int.parse(json['MaKhachHang']),
      cccd: json['CCCD'],
      hoTen: json['HoTen'],
      ngaySinh: vnDateFormat.parse(json['NgaySinh'] as String),
      soDienThoai: json['SoDienThoai'],
      hangGPLX: json['HangGPLX'],
      ghiChu: json['GhiChu'],
    );
  }
}
