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
  String? hangGPLX;
  DongXe? dongXe;
  HangXe? hangXe;
  DateTime ngayMua;
  int? maBHX;
  int soHanhTrinh;

  XeDTO(
    this.maXe,
    this.bienSoXe,
    this.tinhTrang,
    this.giaThue,
    this.giaMua,
    this.loaiXe,
    this.hangGPLX,
    this.dongXe,
    this.hangXe,
    this.ngayMua,
    this.maBHX,
    this.soHanhTrinh,
  );

  String dongXeToString() {
    String str = "";
    str += '${dongXe!.tenDongXe.capitalizeFirstLetterOfEachWord()}, ';

    return str.substring(0, str.length - 2);
  }

  String hangXeToString() {
    String str = "";
    str += '${hangXe!.tenHangXe.capitalizeFirstLetterOfEachWord()}, ';

    return str.substring(0, str.length - 2);
  }
}
