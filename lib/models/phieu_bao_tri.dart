import 'package:rent_bik/utils/common_variables.dart';

class PhieuBaoTri {
  int? maPhieuBaoTri;
  DateTime ngayBaoTri;
  int maXe;
  String bienSoXe;
  String tinhTrang;
  PhieuBaoTri({
    this.maPhieuBaoTri,
    required this.ngayBaoTri,
    required this.maXe,
    required this.bienSoXe,
    required this.tinhTrang,
  });
  factory PhieuBaoTri.fromJson(Map<String, dynamic> json) {
    return PhieuBaoTri(
      maPhieuBaoTri: int.parse(json['MaPhieuBaoTri']),
      maXe: int.parse(json['MaXe']),
      bienSoXe: json['BienSoXe'],
      tinhTrang: json['TinhTrang'],
      ngayBaoTri: vnDateFormat.parse(json['NgayBaoTri'] as String),
    );
  }
}
