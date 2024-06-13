import 'package:rent_bik/utils/common_variables.dart';

class PhieuThue {
  int? maPhieuThue;
  int maKH;
  int maXe;
  DateTime ngayThue;
  DateTime ngayTra;
  int giaCoc;
  String tinhTrang;
  PhieuThue({
    this.maPhieuThue,
    required this.maKH,
    required this.maXe,
    required this.ngayThue,
    required this.ngayTra,
    required this.giaCoc,
    required this.tinhTrang,
  });

  factory PhieuThue.fromJson(Map<String, dynamic> json) {
    return PhieuThue(
      maPhieuThue: int.parse(json['MaPhieuThue']),
      maKH: int.parse(json['MaKH']),
      maXe: int.parse(json['MaXe']),
      ngayThue: vnDateFormat.parse(json['NgayThue'] as String),
      ngayTra: vnDateFormat.parse(json['NgayTra'] as String),
      giaCoc: int.parse(json['GiaCoc']),
      tinhTrang: json['TinhTrang'],
    );
  }
}
