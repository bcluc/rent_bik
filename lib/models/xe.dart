class Xe{
  String maXe;
  String tinhTrang;
  int giaThue;
  String? hangGPLX;
  String? ghiChu;
  
  Xe(
    this.maXe,
    this.tinhTrang,
    this.giaThue,
    this.hangGPLX,
    this.ghiChu
  );

  Map<String, dynamic> toMap(){
    return{
      'MaXe': maXe,
      'TinhTrang': tinhTrang,
      'GiaThue': giaThue,
      'HangGPLX': hangGPLX,
      'GhiChu': ghiChu
    };
  }
}