import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rent_bik/components/my_search_bar.dart';
import 'package:rent_bik/components/pagination.dart';
import 'package:rent_bik/main.dart';
import 'package:rent_bik/models/phieu_bao_tri.dart';
import 'package:rent_bik/screens/maintance_manage/maintance_list/edit_maintance_form.dart';
import 'package:rent_bik/utils/common_variables.dart';
import 'package:rent_bik/utils/extesion.dart';

class MaintainceList extends StatefulWidget {
  const MaintainceList({super.key});

  @override
  State<MaintainceList> createState() => _MaintainceListState();
}

class _MaintainceListState extends State<MaintainceList> {
// Danh sách Tên các cột trong Bảng Khách Hàng
  final List<String> _colsName = [
    'Mã bảo trì',
    'Biển số xe',
    'Ngày bảo trì',
    'Trạng thái',
  ];

  int _selectedRow = -1;

  /* 2 biến này không set final bởi vì nó sẽ thay đổi giá trị khi người dùng tương tác */
  late List<PhieuBaoTri> _phieuBaoTriRows;
  late int _phieuBaoTriCount;

  late final Future<void> _futureRecentKHs = _getRecentKHs();
  Future<void> _getRecentKHs() async {
    /* 
    Delay 1 khoảng bằng thời gian animation của TabController 
    Tạo chuyển động mượt mà 
    */
    await Future.delayed(kTabScrollDuration);
    _phieuBaoTriRows = await dbProcess.queryPhieuBaoTri(numberRowIgnore: 1);
    _phieuBaoTriCount = await dbProcess.queryCountPhieuBaoTri();
  }

  final _searchController = TextEditingController();

  Future<void> _logicEditPBT() async {
    String? message = await showDialog(
      context: context,
      builder: (ctx) => EditMaintanceForm(
        editPhieuBaoTri: _phieuBaoTriRows[_selectedRow],
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
  Future<void> _logicDeletePBT() async {
    var deleteKHName = _phieuBaoTriRows[_selectedRow].maPhieuBaoTri;

    /* Xóa dòng dữ liệu*/
    await dbProcess.deletePhieuBaoTri(
      _phieuBaoTriRows[_selectedRow].maPhieuBaoTri!,
    );

    /* 
    Lấy giá trị totalPages trước khi giảm _KHCount đi 1 đơn vị 
    VD: Có 17 dòng dữ liệu, phân trang 8 dòng => Đang có 3 total page 
    Nếu giảm _KHCount đi 1 đơn vị trước khi tính totalPages
    thì totalPages chỉ còn 2 => SAI 
    */
    int totalPages = _phieuBaoTriCount ~/ 8 + min(_phieuBaoTriCount % 8, 1);
    int currentPage = int.parse(_paginationController.text);

    _phieuBaoTriCount--;

    // print('totalPage = $totalPages');

    if (currentPage == totalPages) {
      _phieuBaoTriRows.removeAt(_selectedRow);
      /* 
      Trường hợp đặc biệt:
      Thủ thư đang ở trang cuối cùng và xóa nốt dòng cuối cùng 
      thì phải chuyển lại sang trang trước đó.
      VD: Xóa hết các dòng ở trang 3 thì tự động chuyển về trang 2
      */
      if (_phieuBaoTriRows.isEmpty && _phieuBaoTriCount > 0) {
        currentPage--;
        _paginationController.text = currentPage.toString();
        _loadPhieuBaotrisOfPageIndex(currentPage);
      }
      /* 
      Nếu không còn trang trước đó, tức _KHCount == 0, thì không cần làm gì cả 
      */
    } else {
      _loadPhieuBaotrisOfPageIndex(currentPage);
    }

    setState(() {});

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã xóa Phiếu bảo trì $deleteKHName.',
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
          width: 400,
        ),
      );
    }
  }

  /* Hàm này dùng để lấy các KH ở trang thứ Index và hiển thị lên bảng */
  Future<void> _loadPhieuBaotrisOfPageIndex(int pageIndex) async {
    String searchText = _searchController.text.toLowerCase();

    List<PhieuBaoTri> newKHRows = searchText.isEmpty
        ? await dbProcess.queryPhieuBaoTri(
            numberRowIgnore: (pageIndex - 1) * 8 + 1)
        : await dbProcess.queryPhieuBaoTriFullnameWithString(
            numberRowIgnore: (pageIndex - 1) * 8 + 1,
            str: searchText,
          );

    setState(() {
      _phieuBaoTriRows = newKHRows;

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

          int totalPages =
              _phieuBaoTriCount ~/ 8 + min(_phieuBaoTriCount % 8, 1);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MySearchBar(
                  controller: _searchController,
                  onSearch: (value) async {
                    /* 
                    Phòng trường hợp gõ tiếng việt
                    VD: o -> (rỗng) -> ỏ
                    Lúc này, value sẽ bằng '' (rỗng) nhưng _searchController.text lại bằng "ỏ"
                    */
                    if (_searchController.text == value) {
                      _paginationController.text = '1';
                      _phieuBaoTriCount = await dbProcess
                          .queryCountPhieuBaoTriFullnameWithString(
                              _searchController.text);
                      _loadPhieuBaotrisOfPageIndex(1);
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton.filled(
                      onPressed: _selectedRow == -1
                          ? null
                          : () async {
                              await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Xác nhận'),
                                  content: Text(
                                      'Bạn có chắc xóa Phiếu bảo trì ${_phieuBaoTriRows[_selectedRow].maPhieuBaoTri} ?'),
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
                                      onPressed: _logicDeletePBT,
                                      child: const Text('Có'),
                                    ),
                                  ],
                                ),
                              );

                              if (_selectedRow >= _phieuBaoTriRows.length) {
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
                      onPressed: _selectedRow == -1
                          ? null
                          : () {
                              _logicEditPBT();
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
                        _phieuBaoTriRows.length,
                        (index) {
                          PhieuBaoTri phieuBaoTri = _phieuBaoTriRows[index];
                          /* Thẻ Độc Giả quá hạn sẽ tô màu xám (black26) */
                          TextStyle cellTextStyle =
                              const TextStyle(color: Colors.black);

                          return DataRow(
                            selected: _selectedRow == index,
                            onSelectChanged: (_) => setState(() {
                              _selectedRow = index;
                            }),
                            onLongPress: () {
                              setState(() {
                                _selectedRow = index;
                              });
                              _logicEditPBT();
                            },
                            cells: [
                              DataCell(
                                Text(
                                  phieuBaoTri.maPhieuBaoTri.toString(),
                                  style: cellTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  phieuBaoTri.bienSoXe,
                                  style: cellTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  phieuBaoTri.ngayBaoTri.toVnFormat(),
                                  style: cellTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  phieuBaoTri.tinhTrang,
                                  style: TextStyle(
                                      color: phieuBaoTri.tinhTrang ==
                                              "Chưa thanh toán"
                                          ? const Color.fromARGB(
                                              255, 202, 64, 64)
                                          : Colors.black),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                if (_phieuBaoTriCount > 0) const Spacer(),
                _phieuBaoTriCount > 0
                    ? Pagination(
                        controller: _paginationController,
                        maxPages: totalPages,
                        onChanged: _loadPhieuBaotrisOfPageIndex,
                      )
                    : const Expanded(
                        child: Center(
                          child: Text(
                            'Chưa có dữ liệu Phiếu bảo hiểm',
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
