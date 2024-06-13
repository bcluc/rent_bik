import 'package:rent_bik/utils/common_variables.dart';

class PhieuBaoTriCanTraDTO {
  int maPhieuBaoTri;
  DateTime ngayBaoTri;
  int maXe;
  String bienSoXe;
  String soBHX;
  String tenHangXe;
  String tenDongXe;
  String tinhTrang;
  PhieuBaoTriCanTraDTO({
    required this.maPhieuBaoTri,
    required this.ngayBaoTri,
    required this.maXe,
    required this.bienSoXe,
    required this.soBHX,
    required this.tenHangXe,
    required this.tenDongXe,
    required this.tinhTrang,
  });
  factory PhieuBaoTriCanTraDTO.fromJson(Map<String, dynamic> json) {
    return PhieuBaoTriCanTraDTO(
        maPhieuBaoTri: int.parse(json['MaPhieuBaoTri']),
        ngayBaoTri: vnDateFormat.parse(json['NgayBaoTri'] as String),
        maXe: int.parse(json["MaXe"]),
        bienSoXe: json["BienSoXe"],
        tinhTrang: json["TinhTrang"],
        tenHangXe: json["TenHangXe"],
        tenDongXe: json["TenDongXe"],
        soBHX: json["SoBHX"]);
  }
}
