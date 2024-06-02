// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:rent_bik/models/dong_xe.dart';
import 'package:rent_bik/models/hang_xe.dart';
import 'package:rent_bik/utils/common_variables.dart';
import 'package:rent_bik/utils/extesion.dart';

class XeDTO {
  int? maXe;
  String bienSoXe;
  String tinhTrang;
  int giaThue;
  int giaMua;
  String loaiXe;
  String hangGPLX;
  List<DongXe> dongXes;
  List<HangXe> hangXes;
  DateTime ngayMua;
  String? soBHX;
  int soHanhTrinh;

  XeDTO({
    this.maXe,
    required this.bienSoXe,
    required this.tinhTrang,
    required this.giaThue,
    required this.hangGPLX,
    required this.loaiXe,
    required this.giaMua,
    required this.ngayMua,
    required this.dongXes,
    required this.hangXes,
    required this.soHanhTrinh,
    this.soBHX,
  });

  factory XeDTO.fromJson(Map<String, dynamic> json) {
    var dongXeList = json['DongXe'] as List;
    List<DongXe> dongXeDtoList =
        dongXeList.map((i) => DongXe.fromJson(i)).toList();

    var hangXeList = json['HangXe'] as List;
    List<HangXe> hangXeDtoList =
        hangXeList.map((i) => HangXe.fromJson(i)).toList();

    return XeDTO(
        maXe: int.parse(json["MaXe"]),
        bienSoXe: json["BienSoXe"],
        tinhTrang: json["TinhTrang"],
        giaThue: int.parse(json["GiaThue"]),
        hangGPLX: json["HangGPLX"],
        loaiXe: json["LoaiXe"],
        giaMua: int.parse(json["GiaMua"]),
        ngayMua: vnDateFormat.parse(json["NgayMua"] as String),
        dongXes: dongXeDtoList,
        hangXes: hangXeDtoList,
        soHanhTrinh: int.parse(json["SoHanhTrinh"]),
        soBHX: json["SoBHX"]);
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> dongXeList =
        dongXes.map((i) => i.toMap()).toList();
    List<Map<String, dynamic>> hangXeList =
        hangXes.map((i) => i.toMap()).toList();
    return {
      'MaXe': maXe,
      'BienSoXe': bienSoXe,
      'TinhTrang': tinhTrang,
      'GiaThue': giaThue,
      'HangGPLX': hangGPLX,
      'LoaiXe': loaiXe,
      'GiaMua': giaMua,
      'NgayMua': ngayMua,
      'SoHanhTrinh': soHanhTrinh,
      'DongXe': dongXeList,
      'HangXe': hangXeList,
      'SoBHX': soBHX,
    };
  }

  String dongXeToString() {
    String str = "";
    for (var dongXe in dongXes) {
      str += '${dongXe.tenDongXe.capitalizeFirstLetterOfEachWord()}, ';
    }

    return str.substring(0, str.length - 2);
  }

  String hangXeToString() {
    String str = "";
    for (var hangXe in hangXes) {
      str += '${hangXe.tenHangXe.capitalizeFirstLetterOfEachWord()}, ';
    }
    return str.substring(0, str.length - 2);
  }
}
