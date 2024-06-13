import 'package:intl/intl.dart';

class CustomerData {
  final String maKhachHang;
  final String hoTen;
  final String cccd;
  final String soLanMuon;
  final String soLanTra;
  final String tongTienChi;

  CustomerData({
    required this.maKhachHang,
    required this.hoTen,
    required this.cccd,
    required this.soLanMuon,
    required this.soLanTra,
    required this.tongTienChi,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      maKhachHang: json['MaKhachHang'],
      hoTen: json['HoTen'],
      cccd: json['CCCD'],
      soLanMuon: json['SoLanMuon'],
      soLanTra: json['SoLanTra'],
      tongTienChi: formatCurrency(json['TongTienChi']),
    );
  }

  static String formatCurrency(String amount) {
    final formatter = NumberFormat("#,###");
    final parsedAmount = int.tryParse(amount) ?? 0;
    return '${formatter.format(parsedAmount)} VND';
  }
}
