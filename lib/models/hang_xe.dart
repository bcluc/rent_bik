class HangXe{
  String maHangXe;
  String tenHangXe;
  
  HangXe(
    this.maHangXe,
    this.tenHangXe
  );

  Map<String, dynamic> toMap(){
    return{
      'MaHangXe': maHangXe,
      'TenHangXe': tenHangXe,
    };
  }
}