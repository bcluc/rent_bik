import 'dart:convert';

import 'package:rent_bik/utils/common_variables.dart';

class PhieuBaoTriDTO {
  int maPhieuBaoTri;
  DateTime ngayBaoTri;
  int maXe;
  String bienSoXe;
  String tinhTrang;
  int giaThue;
  String hangGPLX;
  String loaiXe;
  int giaMua;
  DateTime ngayMua;
  int soHanhTrinh;
  int maDongXe;
  int maHangXe;
  String soBHX;
  PhieuBaoTriDTO({
    required this.maPhieuBaoTri,
    required this.ngayBaoTri,
    required this.maXe,
    required this.bienSoXe,
    required this.tinhTrang,
    required this.giaThue,
    required this.hangGPLX,
    required this.loaiXe,
    required this.giaMua,
    required this.ngayMua,
    required this.soHanhTrinh,
    required this.maDongXe,
    required this.maHangXe,
    required this.soBHX,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    result.addAll({'MaPhieuBaoTri': maPhieuBaoTri});
    result.addAll({'NgayBaoTri': ngayBaoTri.millisecondsSinceEpoch});
    result.addAll({'MaXe': maXe});
    result.addAll({'BienSoXe': bienSoXe});
    result.addAll({'TinhTrang': tinhTrang});
    result.addAll({'GiaThue': giaThue});
    result.addAll({'HangGPLX': hangGPLX});
    result.addAll({'LoaiXe': loaiXe});
    result.addAll({'GiaMua': giaMua});
    result.addAll({'NgayMua': ngayMua.millisecondsSinceEpoch});
    result.addAll({'SoHanhTrinh': soHanhTrinh});
    result.addAll({'MaDongXe': maDongXe});
    result.addAll({'MaHangXe': maHangXe});
    result.addAll({'SoBHX': soBHX});

    return result;
  }

  factory PhieuBaoTriDTO.fromJson(Map<String, dynamic> json) {
    return PhieuBaoTriDTO(
        maPhieuBaoTri: int.parse(json['MaPhieuBaoTri']),
        ngayBaoTri: vnDateFormat.parse(json['NgayBaoTri'] as String),
        maXe: json["MaXe"],
        bienSoXe: json["BienSoXe"],
        tinhTrang: json["TinhTrang"],
        giaThue: int.parse(json["GiaThue"]),
        hangGPLX: json["HangGPLX"],
        loaiXe: json["LoaiXe"],
        giaMua: int.parse(json["GiaMua"]),
        ngayMua: json["NgayMua"],
        maDongXe: int.parse(json["MaDongXe"]),
        maHangXe: int.parse(json["MaHangXe"]),
        soHanhTrinh: int.parse(json["SoHanhTrinh"]),
        soBHX: json["SoBHX"]);
  }
}
