// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:rent_bik/utils/common_variables.dart';

class BaoHiemXe {
  int? maBHX;
  String soBHX;
  DateTime ngayMua;
  DateTime ngayHetHan;
  int soTien;
  BaoHiemXe({
    this.maBHX,
    required this.soBHX,
    required this.ngayMua,
    required this.ngayHetHan,
    required this.soTien,
  });
  factory BaoHiemXe.fromJson(Map<String, dynamic> json) {
    return BaoHiemXe(
      maBHX: int.parse(json['MaBHX']),
      soBHX: json['SoBHX'],
      ngayHetHan: vnDateFormat.parse(json['NgayHetHan'] as String),
      ngayMua: vnDateFormat.parse(json['NgayMua'] as String),
      soTien: int.parse(json['SoTien']),
    );
  }
}
