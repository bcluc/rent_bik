class Xe {
  int? maXe;
  String bienSoXe;
  String tinhTrang;
  int giaThue;
  String? hangGPLX;
  String loaiXe;
  int giaMua;
  DateTime ngayMua;
  int soHanhTrinh;

  Xe(this.maXe, this.bienSoXe, this.tinhTrang, this.giaThue, this.hangGPLX,
      this.loaiXe, this.giaMua, this.ngayMua, this.soHanhTrinh);

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
    };
  }
}
