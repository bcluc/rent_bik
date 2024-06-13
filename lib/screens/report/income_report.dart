import 'package:fl_chart/fl_chart.dart';
import 'package:rent_bik/screens/report/indicator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Thêm thư viện intl

class PieChartSample2 extends StatefulWidget {
  const PieChartSample2({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartSample2> {
  int touchedIndex = -1;
  late int revenue = 0;
  late int maintenanceCost = 0;
  late int insuranceCost = 0;
  late int purchasedCost = 0;
  late int profit = 0;
  String _selectedYear = 'tất cả'; // Mặc định chọn tất cả
  final numberFormat = NumberFormat("#,##0", "en_US");

  @override
  void initState() {
    super.initState();
    _fetchChartData(_selectedYear);
  }

  Future<void> _fetchChartData(String year) async {
    String url;
    if (year == 'tất cả') {
      url = 'http://localhost/RentBikBE/report_DoanhThu.php';
    } else {
      url = 'http://localhost/RentBikBE/report_DoanhThu.php?year=$year';
    }
    try {
      final response = await http.get(
        Uri.parse(url),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            revenue = data["totalRevenue"];
            maintenanceCost = data['totalMaintenanceCost'];
            insuranceCost = data['totalInsuranceCost'];
            purchasedCost = data['totalPurchaseCost'];
            profit = data['totalProfit'];
          });
        } else {
          throw Exception('Invalid data');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Chọn năm: '),
              DropdownButton<String>(
                value: _selectedYear,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedYear = newValue!;
                    _fetchChartData(_selectedYear);
                  });
                },
                items: <String>['2022', '2023', '2024', 'tất cả']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Báo cáo doanh thu năm $_selectedYear',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 0, 0, 0), // Thay đổi màu sắc theo ý muốn
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
                        sections: showingSections(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Indicator(
                        color: Color.fromRGBO(58, 166, 185, 1),
                        text: 'Chi phí bảo trì: ${numberFormat.format(maintenanceCost)} VND',
                        isSquare: true,
                      ),
                      SizedBox(height: 4),
                      Indicator(
                        color: Color.fromARGB(255, 252, 252, 118),
                        text: 'Chi phí bảo hiểm: ${numberFormat.format(insuranceCost)} VND',
                        isSquare: true,
                      ),
                      SizedBox(height: 4),
                      Indicator(
                        color: Color.fromRGBO(255, 208, 208, 1),
                        text: 'Chi phí thu mua: ${numberFormat.format(purchasedCost)} VND',
                        isSquare: true,
                      ),
                      SizedBox(height: 18),
                      Text(
                        'Tổng chi: ${numberFormat.format(revenue - profit)} VND',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tổng thu: ${numberFormat.format(revenue)} VND',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tổng lãi: ${numberFormat.format(profit)} VND',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      double percentage(double value) {
        if ((revenue - profit) == 0) {
          return 0;
        }
        return (value / (revenue - profit)) * 100;
      }

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Color.fromARGB(255, 58, 166, 185),
            value: maintenanceCost.toDouble(),
            title: percentage(maintenanceCost.toDouble()).toStringAsFixed(2) + '%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.normal,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Color.fromARGB(255, 252, 252, 118),
            value: insuranceCost.toDouble(),
            title: percentage(insuranceCost.toDouble()).toStringAsFixed(2) + '%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.normal,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Color.fromARGB(255, 255, 208, 208),
            value: purchasedCost.toDouble(),
            title: percentage(purchasedCost.toDouble()).toStringAsFixed(2) + '%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.normal,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}
