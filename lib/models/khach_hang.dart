import 'package:rent_bik/utils/extesion.dart';

class KhachHang {
  KhachHang(
    this.maKhachHang,
    this.cccd,
    this.hoTen,
    this.ngaySinh,
    this.soDienThoai,
    this.hangGPLX,
    this.ghiChu,
  );

  int? maKhachHang;
  String cccd;
  String hoTen;
  DateTime ngaySinh;
  String soDienThoai;
  String? hangGPLX;
  String? ghiChu;

  Map<String, dynamic> toMap() {
    return {
      'CCCD': cccd,
      'HoTen': hoTen,
      'NgaySinh': ngaySinh.toVnFormat(),
      'SoDienThoai': soDienThoai,
      'HangGPLX': hangGPLX,
      'GhiChu': ghiChu,
    };
  }
}
