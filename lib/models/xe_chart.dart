class ChartData {
  final String month;
  final int count;

  ChartData( { required this.month, required this.count});
 

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      month: json['Thang'],
      count: json['SoLuongThue'] ?? json['SoLuongTra'] ?? json['SoLuongMua'] ?? 0,
    );
  }
}