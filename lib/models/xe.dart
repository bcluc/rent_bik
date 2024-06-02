class Xe {
  int? maXe;
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

  Xe({
    this.maXe,
    required this.bienSoXe,
    required this.tinhTrang,
    required this.giaThue,
    required this.hangGPLX,
    required this.loaiXe,
    required this.giaMua,
    required this.ngayMua,
    required this.maDongXe,
    required this.maHangXe,
    required this.soHanhTrinh,
    required this.soBHX,
  });

  factory Xe.fromJson(Map<String, dynamic> json) {
    return Xe(
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

  Map<String, dynamic> toMap() {
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
      'MaDongXe': maDongXe,
      'MaHangXe': maHangXe,
      'SoBHX': soBHX,
    };
  }
}
