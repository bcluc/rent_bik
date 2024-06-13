import 'package:rent_bik/utils/common_variables.dart';

class PhieuTra {
  int maPhieuTra;
  int maPhieuThue;
  int? tongHoaDon;
  DateTime ngayTra;
  String? note;
  int soHanhTrinhMoi;
  PhieuTra({
    required this.maPhieuTra,
    required this.maPhieuThue,
    required this.tongHoaDon,
    required this.ngayTra,
    this.note,
    required this.soHanhTrinhMoi,
  });

  factory PhieuTra.fromJson(Map<String, dynamic> json) {
    return PhieuTra(
      maPhieuTra: int.parse(json['MaPhieuTra']),
      maPhieuThue: int.parse(json['MaPhieuThue']),
      tongHoaDon: json['TongHoaDon'],
      ngayTra: vnDateFormat.parse(json['NgayTra'] as String),
      note: json['GhiChu'],
      soHanhTrinhMoi: int.parse(json['SoHanhTrinhMoi']),
    );
  }
}
