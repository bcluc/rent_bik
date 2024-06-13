import 'package:rent_bik/utils/common_variables.dart';

class PhieuThueCanTraDTO {
  int maPhieuThue;
  int maKH;
  DateTime ngayThue;
  DateTime ngayTra;
  int maXe;
  String bienSoXe;
  int giaCoc;
  String tenHangXe;
  String tenDongXe;
  String tinhTrang;
  PhieuThueCanTraDTO({
    required this.maPhieuThue,
    required this.maKH,
    required this.ngayThue,
    required this.ngayTra,
    required this.maXe,
    required this.bienSoXe,
    required this.giaCoc,
    required this.tenHangXe,
    required this.tenDongXe,
    required this.tinhTrang,
  });
  factory PhieuThueCanTraDTO.fromJson(Map<String, dynamic> json) {
    return PhieuThueCanTraDTO(
        maPhieuThue: int.parse(json['MaPhieuThue']),
        ngayThue: vnDateFormat.parse(json['NgayThue'] as String),
        ngayTra: vnDateFormat.parse(json['NgayTra'] as String),
        maXe: int.parse(json["MaXe"]),
        giaCoc: int.parse(json["GiaCoc"]),
        bienSoXe: json["BienSoXe"],
        tinhTrang: json["TinhTrang"],
        tenHangXe: json["TenHangXe"],
        tenDongXe: json["TenDongXe"],
        maKH: int.parse(json["MaKH"]));
  }
}
