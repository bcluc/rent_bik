import 'package:rent_bik/utils/common_variables.dart';

class PhieuThueDTO {
  int maKH;
  int maXe;
  DateTime ngayThue;
  DateTime ngayTra;
  int giaCoc;
  PhieuThueDTO({
    required this.maKH,
    required this.maXe,
    required this.ngayThue,
    required this.ngayTra,
    required this.giaCoc,
  });

  factory PhieuThueDTO.fromJson(Map<String, dynamic> json) {
    return PhieuThueDTO(
      maKH: int.parse(json['MaKH']),
      maXe: int.parse(json['MaXe']),
      ngayThue: vnDateFormat.parse(json['NgayThue'] as String),
      ngayTra: vnDateFormat.parse(json['NgayTra'] as String),
      giaCoc: int.parse(json['GiaCoc']),
    );
  }
}
