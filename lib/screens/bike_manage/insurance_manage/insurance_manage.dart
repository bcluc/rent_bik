import 'dart:math';
import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:rent_bik/components/pagination.dart';
import 'package:rent_bik/main.dart';
import 'package:rent_bik/models/bao_hiem_xe.dart';
import 'package:rent_bik/screens/bike_manage/insurance_manage/edit_insurance_form.dart';
import 'package:rent_bik/utils/common_variables.dart';
import 'package:rent_bik/utils/extesion.dart';

class InsuranceManage extends StatefulWidget {
  const InsuranceManage({super.key});

  @override
  State<InsuranceManage> createState() => _InsuranceManageState();
}

class _InsuranceManageState extends State<InsuranceManage> {
  // Danh sách Tên các cột trong Bảng Khách Hàng
  final List<String> _colsName = [
    'Mã BHX',
    'Số bảo hiểm',
    'Biển số xe',
    'Ngày mua',
    'Ngày hết hạn',
    'Giá mua',
  ];

  int _selectedRow = -1;
  bool _isSort = false;

  /* 2 biến này không set final bởi vì nó sẽ thay đổi giá trị khi người dùng tương tác */
  late List<BaoHiemXe> _bhxRows;
  late int _bhxCount;

  late final Future<void> _futureRecentKHs = _getRecentKHs();
  Future<void> _getRecentKHs() async {
    /* 
    Delay 1 khoảng bằng thời gian animation của TabController 
    Tạo chuyển động mượt mà 
    */
    await Future.delayed(kTabScrollDuration);
    _bhxRows = await dbProcess.queryBaoHiemXe(numberRowIgnore: 1);
    _bhxCount = await dbProcess.queryCountBaoHiemXe();
  }

  /*
  Nếu có Độc giả mới được thêm (tức là đã điền đầy đủ thông tin hợp lệ + nhấn Save)
  thì phương thức showDialog() sẽ trả về một KH mới
  */
  Future<void> _filterList() async {
    setState(() {
      if (_isSort) {
        _bhxRows.sort((a, b) => a.ngayHetHan.compareTo(b.ngayHetHan));
      } else {
        _bhxRows.sort((a, b) => a.maBHX!.compareTo(b.maBHX!));
      }
    });
  }

  /*
  Hàm này là logic xử lý khi người dùng nhấn vào nút Edit hoặc Long Press vào một Row trong bảng
  Đầu tiên là show AddEditKHForm, showDialog() sẽ trả về:
    - String 'updated', nếu người dùng nhấn Save
    - null, nếu người dùng nhấn nút Close hoặc Click Outside of Dialog
  */
  Future<void> _logicEditBHX() async {
    String? message = await showDialog(
      context: context,
      builder: (ctx) => EditBHXForm(
        editBaoHiemXe: _bhxRows[_selectedRow],
      ),
    );

    // print(message);
    if (message == "updated") {
      setState(() {});
    }
  }

  /* 
  Hàm này là logic Xóa Độc giả 
  */
  Future<void> _logicDeleteBHX() async {
    var deleteKHName = _bhxRows[_selectedRow].soBHX;

    /* Xóa dòng dữ liệu*/
    await dbProcess.deleteBaoHiemXe(
      _bhxRows[_selectedRow].maBHX!,
    );

    /* 
    Lấy giá trị totalPages trước khi giảm _KHCount đi 1 đơn vị 
    VD: Có 17 dòng dữ liệu, phân trang 8 dòng => Đang có 3 total page 
    Nếu giảm _KHCount đi 1 đơn vị trước khi tính totalPages
    thì totalPages chỉ còn 2 => SAI 
    */
    int totalPages = _bhxCount ~/ 8 + min(_bhxCount % 8, 1);
    int currentPage = int.parse(_paginationController.text);

    _bhxCount--;

    // print('totalPage = $totalPages');

    if (currentPage == totalPages) {
      _bhxRows.removeAt(_selectedRow);
      /* 
      Trường hợp đặc biệt:
      Thủ thư đang ở trang cuối cùng và xóa nốt dòng cuối cùng 
      thì phải chuyển lại sang trang trước đó.
      VD: Xóa hết các dòng ở trang 3 thì tự động chuyển về trang 2
      */
      if (_bhxRows.isEmpty && _bhxCount > 0) {
        currentPage--;
        _paginationController.text = currentPage.toString();
        _loadBHXsOfPageIndex(currentPage);
      }
      /* 
      Nếu không còn trang trước đó, tức _KHCount == 0, thì không cần làm gì cả 
      */
    } else {
      _loadBHXsOfPageIndex(currentPage);
    }

    setState(() {});

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã xóa Bảo hiểm xe $deleteKHName.',
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
          width: 400,
        ),
      );
    }
  }

  /* Hàm này dùng để lấy các KH ở trang thứ Index và hiển thị lên bảng */
  Future<void> _loadBHXsOfPageIndex(int pageIndex) async {
    List<BaoHiemXe> newKHRows = await dbProcess.queryBaoHiemXe(
        numberRowIgnore: (pageIndex - 1) * 8 + 1);

    setState(() {
      _bhxRows = newKHRows;
      /* 
      Chuyển sang trang khác phải cho _selectedRow = -1
      VD: 
      Đang ở trang 1 và selectedRow = 4 (đang ở dòng 5),
      mà chuyển sang trang 2, chỉ có 2 dòng
      => Gây ra LỖI
      */
      _selectedRow = -1;
    });
  }

  final _paginationController = TextEditingController(text: "1");

  @override
  void dispose() {
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

          int totalPages = _bhxCount ~/ 8 + min(_bhxCount % 8, 1);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /* 
                    Nút "Sửa thông tin Độc Giả" 
                    Logic xử lý _logicEditKH xem ở phần khai báo bên trên
                    */
                    FilledButton.icon(
                      onPressed: () {
                        _isSort = !_isSort;
                        _filterList();
                      },
                      icon: const Icon(Icons.filter_alt_rounded),
                      label: Text(
                          'Sắp xếp theo ${_isSort ? "ngày hết hạn" : "mã bảo hiểm"}'),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 16),
                      ),
                    ),
                    const Spacer(),
                    /* 
                    Đây là nút "Xóa độc giả",
                    Phòng trường hợp khi _selectedRow đang ở cuối bảng và ta nhấn xóa dòng cuối của bảng
                    Lúc này _selectedRow đã nằm ngoài mảng, và nút "Xóa độc giả" vẫn chưa được Disable
                    => Có khả năng gây ra lỗi
                    Solution: Sau khi xóa phải kiểm tra lại 
                    xem _selectedRow có nằm ngoài phạm vi của _KHRows hay không.
                    */
                    IconButton.filled(
                      onPressed: _selectedRow == -1
                          ? null
                          : () async {
                              await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Xác nhận'),
                                  content: Text(
                                      'Bạn có chắc xóa Bảo hiểm xe ${_bhxRows[_selectedRow].soBHX}?'),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Huỷ'),
                                    ),
                                    FilledButton(
                                      onPressed: _logicDeleteBHX,
                                      child: const Text('Có'),
                                    ),
                                  ],
                                ),
                              );

                              if (_selectedRow >= _bhxRows.length) {
                                _selectedRow = -1;
                              }
                            },
                      icon: const Icon(Icons.delete),
                      style: myIconButtonStyle,
                    ),
                    const SizedBox(width: 12),
                    /* 
                    Nút "Sửa thông tin Độc Giả" 
                    Logic xử lý _logicEditKH xem ở phần khai báo bên trên
                    */
                    IconButton.filled(
                      onPressed: () {
                        _selectedRow == -1 ? null : _logicEditBHX();
                      },
                      icon: const Icon(Icons.edit),
                      style: myIconButtonStyle,
                    ),
                  ],
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
                        _bhxRows.length,
                        (index) {
                          BaoHiemXe baoHiemXe = _bhxRows[index];
                          /* Thẻ Độc Giả quá hạn sẽ tô màu xám (black26) */
                          TextStyle cellTextStyle =
                              const TextStyle(color: Colors.black);

                          return DataRow(
                            color: baoHiemXe.ngayHetHan < DateTime.now()
                                ? MaterialStateProperty.resolveWith((states) {
                                    if (states
                                        .contains(MaterialState.selected)) {
                                      return Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.3);
                                    }
                                    return Colors.black12;
                                  })
                                : null,
                            selected: _selectedRow == index,
                            onSelectChanged: (_) => setState(() {
                              _selectedRow = index;
                            }),
                            onLongPress: () {
                              setState(() {
                                _selectedRow = index;
                              });
                              _logicEditBHX();
                            },
                            cells: [
                              DataCell(
                                Text(
                                  baoHiemXe.maBHX.toString(),
                                  style: cellTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  baoHiemXe.soBHX.toString(),
                                  style: cellTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  baoHiemXe.bienSoXe.toString(),
                                  style: cellTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  baoHiemXe.ngayMua.toVnFormat(),
                                  style: cellTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  baoHiemXe.ngayHetHan.toVnFormat(),
                                  style: baoHiemXe.ngayHetHan < DateTime.now()
                                      ? const TextStyle(
                                          color:
                                              Color.fromARGB(255, 155, 10, 0),
                                          fontWeight: FontWeight.bold)
                                      : cellTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  baoHiemXe.soTien.toString(),
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
                if (_bhxCount > 0) const Spacer(),
                _bhxCount > 0
                    ? Pagination(
                        controller: _paginationController,
                        maxPages: totalPages,
                        onChanged: _loadBHXsOfPageIndex,
                      )
                    : const Expanded(
                        child: Center(
                          child: Text(
                            'Chưa có dữ liệu Bảo hiểm xe',
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
