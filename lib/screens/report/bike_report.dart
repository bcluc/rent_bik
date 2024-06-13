import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rent_bik/screens/report/indicator.dart';

import 'package:rent_bik/models/xe_chart.dart';

class _LineChart extends StatelessWidget {
  final List<ChartData> rentedCars;
  final List<ChartData> returnedCars;
  final List<ChartData> purchasedCars;
  bool isShowingMainData;

  _LineChart(
      {required this.rentedCars,
      required this.returnedCars,
      required this.purchasedCars,
      required this.isShowingMainData});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      isShowingMainData ? sampleData1 : sampleData1,
      duration: const Duration(milliseconds: 250),
    );
  }

  LineChartData get sampleData1 => LineChartData(
        lineTouchData: lineTouchData1,
        gridData: gridData,
        titlesData: titlesData1,
        borderData: borderData,
        lineBarsData: lineBarsData1,
        minX: 0,
        maxX: 14,
        maxY: 20,
        minY: 0,
      );

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.2),
        ),
      );

  FlTitlesData get titlesData1 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
      );

  List<LineChartBarData> get lineBarsData1 => [
        _generateLineChartBarData(rentedCars, Color.fromRGBO(58, 166, 185, 1)),
        _generateLineChartBarData(returnedCars, Color.fromARGB(255, 252, 252, 118)),
        _generateLineChartBarData(purchasedCars,Color.fromRGBO(255, 208, 208, 1))
      ];

  LineTouchData get lineTouchData2 => const LineTouchData(
        enabled: false,
      );

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '';
        break;
      case 2:
        text = '2';
        break;
      case 3:
        text = '';
        break;
      case 4:
        text = '4';
        break;
      case 5:
        text = '';
        break;
      case 6:
        text = '6';
        break;
      case 8:
        text = '8';
        break;
      case 10:
        text = '10';
        break;
      case 12:
        text = '12';
      case 14:
        text = '14';
      case 16:
        text = '16';
      case 18:
        text = '18';
      case 20:
        text = '20';
        break;
      default:
        text = '';

        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: 1,
        reservedSize: 40,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        return text = const Text('Jan', style: style);
        ;
      case 2:
        return text = const Text('Feb', style: style);
      case 3:
        return text = const Text('Mar', style: style);
      case 4:
        return text = const Text('Apr', style: style);
      case 5:
        return text = const Text('May', style: style);
      case 6:
        return text = const Text('Jun', style: style);
      case 7:
        return text = const Text('Jul', style: style);
      case 8:
        return text = const Text('Aug', style: style);
      case 9:
        return text = const Text('Sep', style: style);
      case 10:
        return text = const Text('Oct', style: style);
      case 11:
        return text = const Text('Nov', style: style);
      case 12:
        return text = const Text('Dec', style: style);

      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  FlGridData get gridData => const FlGridData(show: false);

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 4),
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      );
  LineChartBarData _generateLineChartBarData(
      List<ChartData> data, Color color) {
    return LineChartBarData(
      color: color,
      barWidth: 8,
      isCurved: true,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      spots: data
          .map((e) => FlSpot(double.parse(e.month), e.count.toDouble()))
          .toList(),
    );
  }
}

class LineChartSample1 extends StatefulWidget {
  const LineChartSample1({super.key});

  @override
  State<StatefulWidget> createState() => LineChartSample1State();
}

class LineChartSample1State extends State<LineChartSample1> {
  late bool isShowingMainData;
  late List<ChartData> rentedCars;
  late List<ChartData> returnedCars;
  late List<ChartData> purchasedCars;
  String _selectedYear = DateTime.now().year.toString();

  @override
  void initState() {
    super.initState();
    isShowingMainData = true;
    _fetchChartData(_selectedYear);
  }

  Future<void> _fetchChartData(String year) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/RentBikBE/report_Xe.php?year=$year'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          rentedCars = List<ChartData>.from(
              data['rentedCars'].map((x) => ChartData.fromJson(x)));
          returnedCars = List<ChartData>.from(
              data['returnedCars'].map((x) => ChartData.fromJson(x)));
          purchasedCars = List<ChartData>.from(
              data['purchasedCars'].map((x) => ChartData.fromJson(x)));
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _onYearChanged(String? newYear) {
    if (newYear != null && newYear != _selectedYear) {
      setState(() {
        _selectedYear = newYear;
        _fetchChartData(newYear);
      });
    }
  }
@override
Widget build(BuildContext context) {
  return AspectRatio(
    aspectRatio: 1.23,
    child: Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                value: _selectedYear,
                onChanged: _onYearChanged,
                decoration: InputDecoration(
                  labelText: 'Chọn năm',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(10, (index) {
                  String year = (DateTime.now().year - index).toString();
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year),
                  );
                }),
              ),
            ),
            const SizedBox(
              height: 37,
            ),
            const Text(
              'Báo cáo Xe',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 37,
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  _LineChart(
                    isShowingMainData: isShowingMainData,
                    rentedCars: rentedCars,
                    returnedCars: returnedCars,
                    purchasedCars: purchasedCars,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: 
                       Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
            
              Indicator(
                color: const Color.fromRGBO(58, 166, 185, 1),
                text: 'Số xe mượn',
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              Indicator(
                color: Color.fromARGB(255, 252, 252, 118),
                text: 'Số xe trả',
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              Indicator(
                color:Color.fromRGBO(255, 208, 208, 1),
                text: 'Số xe đã mua',
                isSquare: true,
              ),
              
              SizedBox(
                height: 18,
              ),
            ],
          ),
          ),
          ],
              
                        // Add more legend items as needed
                      
                    ),
                  ),
                ],
            ),],
  ),
  
        );
     
}

Widget _buildLegendItem(String title, Color color) {
  return Row(
    mainAxisSize: MainAxisSize.min, // Giữ kích thước tối thiểu để không kéo dài quá chiều ngang
    children: <Widget>[
      Container(
        width: 16,
        height: 16,
        color: color,
      ),
      SizedBox(width: 8), // Khoảng cách giữa ô màu và văn bản
      Text(
        title,
        style: TextStyle(fontSize: 14),
      ),
      SizedBox(width: 8),
    ],
  );
}
}