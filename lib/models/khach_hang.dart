
import 'package:rent_bik/utils/extesion.dart';

class KhachHang {
  KhachHang(
    this.maKhachHang,
    this.hoTen,
    this.ngaySinh,
    this.soDienThoai,
    this.hangGPLX,
    this.ghiChu,
  );

  String? maKhachHang;
  String hoTen;
  DateTime ngaySinh;
  String soDienThoai;
  List<String>? hangGPLX;
  String? ghiChu;

  Map<String, dynamic> toMap() {
    return {
      'CCCD': maKhachHang,
      'HoTen': hoTen,
      'NgaySinh': ngaySinh.toVnFormat(),
      'SoDienThoai': soDienThoai,
      'HangGPLX': hangGPLX,
      'GhiChu': ghiChu,
    };
  }
}
