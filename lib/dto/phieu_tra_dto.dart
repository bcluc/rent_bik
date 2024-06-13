import 'package:rent_bik/utils/common_variables.dart';

class PhieuTraDTO {
  int maPhieuThue;
  int? phiPhat;
  DateTime ngayTra;
  String? note;
  int soHanhTrinhMoi;
  PhieuTraDTO({
    required this.maPhieuThue,
    required this.phiPhat,
    required this.ngayTra,
    this.note,
    required this.soHanhTrinhMoi,
  });

  factory PhieuTraDTO.fromJson(Map<String, dynamic> json) {
    return PhieuTraDTO(
      maPhieuThue: int.parse(json['MaPhieuThue']),
      phiPhat: int.parse(json['PhiPhat']),
      ngayTra: vnDateFormat.parse(json['NgayTra'] as String),
      note: json['Note'],
      soHanhTrinhMoi: int.parse(json['SoHanhTrinhMoi']),
    );
  }
}
