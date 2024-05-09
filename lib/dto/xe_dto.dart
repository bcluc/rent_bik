// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:rent_bik/models/dong_xe.dart';
import 'package:rent_bik/models/hang_xe.dart';
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
  int soHanhTrinh;

  XeDTO(
    this.maXe,
    this.bienSoXe,
    this.tinhTrang,
    this.giaThue,
    this.giaMua,
    this.loaiXe,
    this.hangGPLX,
    this.dongXes,
    this.hangXes,
    this.ngayMua,
    this.soHanhTrinh,
  );

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
