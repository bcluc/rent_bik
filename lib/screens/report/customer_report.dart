import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rent_bik/components/my_search_bar.dart';
import 'package:rent_bik/components/pagination.dart';
import 'package:rent_bik/main.dart';
import 'package:rent_bik/models/khach_hang.dart';
import 'package:rent_bik/screens/customer_manage/add_edit_customer_form.dart';
import 'package:rent_bik/utils/common_variables.dart';
import 'package:rent_bik/utils/extesion.dart';
import 'package:http/http.dart' as http;
import 'package:rent_bik/models/khach_hang_report.dart';

class CustomerReport extends StatefulWidget {
  const CustomerReport({super.key});

  @override
  State<CustomerReport> createState() => _CustomerReportState();
}

class _CustomerReportState extends State<CustomerReport> {
// Danh sách Tên các cột trong Bảng Khách Hàng
  final List<String> _colsName = [
    '#',
    'CCCD',
    'Họ Tên',
    'Số lần mượn',
    'Số lần trả',
    'Tổng tiền',
    
  ];

  int _selectedRow = -1;

  /* 2 biến này không set final bởi vì nó sẽ thay đổi giá trị khi người dùng tương tác */
  late List<KhachHang> _khachHangRows;
  late int _khachHangCount;
   List<CustomerData> _customerData = [];
  String _selectedYear = DateTime.now().year.toString();

  @override
  void initState() {
    super.initState();
    _fetchCustomerData(_selectedYear);
  }


  late final Future<void> _futureRecentKHs = _getRecentKHs();
  Future<void> _getRecentKHs() async {
    /* 
    Delay 1 khoảng bằng thời gian animation của TabController 
    Tạo chuyển động mượt mà 
    */
    _khachHangRows = await dbProcess.queryKhachHang(numberRowIgnore: 1);
    _khachHangCount = await dbProcess.queryCountKhachHang();
  }

   Future<void> _fetchCustomerData(String year) async {
    await Future.delayed(kTabScrollDuration);

    final response = await http.get(Uri.parse('http://localhost/RentBikBE/report_KH.php?year=$year'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          _customerData = (data['data'] as List)
              .map((item) => CustomerData.fromJson(item))
              .toList();
        _khachHangCount= (data['data'] as List).length;

        });
      } else {
        setState(() {
            _khachHangCount=0;
        _customerData= [];
        });
      
      }
    } else {
      // handle error
      setState(() {
            _khachHangCount=0;
        _customerData= [];
        });
    }
  }


  void _onYearChanged(String? newYear) {
    if (newYear != null && newYear != _selectedYear) {
      setState(() {
        _selectedYear = newYear;
        _fetchCustomerData(newYear);
      });
    }
  }

  final _searchController = TextEditingController();

  


  

  /* Hàm này dùng để lấy các KH ở trang thứ Index và hiển thị lên bảng */
  Future<void> _loadKHsOfPageIndex(int pageIndex) async {
    String searchText = _searchController.text.toLowerCase();

    List<KhachHang> newKHRows = searchText.isEmpty
        ? await dbProcess.queryKhachHang(
            numberRowIgnore: (pageIndex - 1) * 8 + 1)
        : await dbProcess.queryKhachHangFullnameWithString(
            numberRowIgnore: (pageIndex - 1) * 8 + 1,
            str: searchText,
          );

    setState(() {
      _khachHangRows = newKHRows;
     
      _selectedRow = -1;
    });
  }

  final _paginationController = TextEditingController(text: "1");

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: _futureRecentKHs,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          int totalPages = _khachHangCount ~/ 8 + min(_khachHangCount % 8, 1);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
               
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
                const SizedBox(height: 12),

                /* Bo góc cho DataTable */
                SizedBox(
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    clipBehavior: Clip.antiAlias,
                    child: DataTable(
                      /* Set màu cho Heading */
                      headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Theme.of(context).colorScheme.primary,
                      ),
                      /* The horizontal margin between the contents of each data column */
                      columnSpacing: 40,
                      dataRowColor: MaterialStateProperty.resolveWith(
                        (states) => getDataRowColor(context, states),
                      ),
                      dataRowMaxHeight: 62,
                      border: TableBorder.symmetric(),
                      showCheckboxColumn: false,
                      columns: List.generate(
                        _colsName.length,
                        (index) => DataColumn(
                          label: Text(
                            _colsName[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                      rows: List.generate(
                        _customerData.length,
                        (index) {
                          CustomerData khachHang = _customerData[index];
                          /* Thẻ Độc Giả quá hạn sẽ tô màu xám (black26) */
                          TextStyle cellTextStyle =
                              const TextStyle(color: Colors.black);

                          return DataRow(
                           
                            
                            cells: [
                              DataCell(
                                Text(
                                  khachHang.maKhachHang.toString(),
                                  style: cellTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  khachHang.cccd.toString(),
                                  style: cellTextStyle,
                                ),
                              ),
                              DataCell(
                                /* Ràng buộc cho Chiều rộng Tối đa của cột Họ Tên = 150 */
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 150),
                                  child: Text(
                                    khachHang.hoTen
                                        .capitalizeFirstLetterOfEachWord(),
                                    style: cellTextStyle,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  khachHang.soLanMuon.toString(),
                                  style: cellTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                 khachHang.soLanTra.toString() ,
                                  style: cellTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                 khachHang.tongTienChi.toString(),
                                  style: cellTextStyle,
                                ),
                              ),
                          
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                if (_khachHangCount > 0) const Spacer(),
                _khachHangCount > 0
                    ? Pagination(
                        controller: _paginationController,
                        maxPages: totalPages,
                        onChanged: _loadKHsOfPageIndex,
                      )
                    : const Expanded(
                        child: Center(
                          child: Text(
                            'Chưa có dữ liệu Khách hàng',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
