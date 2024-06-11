// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:rent_bik/utils/common_variables.dart';

class BaoHiemXeDTO {
  int? maBHX;
  String soBHX;
  DateTime ngayMua;
  DateTime ngayHetHan;
  int soTien;
  int? maXe;
  String bienSoXe;
  String tinhTrang;
  int giaThue;
  String hangGPLX;
  String loaiXe;
  int giaMua;
  int? maDongXe;
  int? maHangXe;
  int soHanhTrinh;
  BaoHiemXeDTO({
    this.maBHX,
    required this.soBHX,
    required this.ngayMua,
    required this.ngayHetHan,
    required this.soTien,
    this.maXe,
    required this.bienSoXe,
    required this.tinhTrang,
    required this.giaThue,
    required this.hangGPLX,
    required this.loaiXe,
    required this.giaMua,
    this.maDongXe,
    this.maHangXe,
    required this.soHanhTrinh,
  });

  factory BaoHiemXeDTO.fromJson(Map<String, dynamic> json) {
    return BaoHiemXeDTO(
      maBHX: int.parse(json['MaBHX']),
      soBHX: json['SoBHX'],
      ngayHetHan: vnDateFormat.parse(json['NgayHetHan'] as String),
      ngayMua: vnDateFormat.parse(json['NgayMua'] as String),
      soTien: int.parse(json['SoTien']),
      maXe: int.parse(json['MaXe']),
      bienSoXe: json['BienSoXe'],
      tinhTrang: json['TinhTrang'],
      giaThue: int.parse(json['GiaThue']),
      hangGPLX: json['HangGPLX'],
      loaiXe: json['LoaiXe'],
      giaMua: int.parse(json['GiaMua']),
      maDongXe: json['MaDongXe'],
      maHangXe: json['MaHangXe'],
      soHanhTrinh: int.parse(json['SoHanhTrinh']),
    );
  }
}
