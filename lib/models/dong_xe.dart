class DongXe{
  String maDongXe;
  String tenDongXe;
  
  DongXe(
    this.maDongXe,
    this.tenDongXe
  );

  Map<String, dynamic> toMap(){
    return{
      'MaDongXe': maDongXe,
      'TenDongXe': tenDongXe,
    };
  }
}