// import 'package:flutter/material.dart';

// class MaintainceList extends StatefulWidget {
//   const MaintainceList({super.key});

//   @override
//   State<MaintainceList> createState() => _MaintainceListState();
// }

// class _MaintainceListState extends State<MaintainceList> {
// // Danh sách Tên các cột trong Bảng Khách Hàng
//   final List<String> _colsName = [
//     '#',
//     'CCCD',
//     'Họ Tên',
//     'Ngày sinh',
//     'Số điện thoại',
//     'GPLX',
//     'Ghi chú',
//   ];

//   int _selectedRow = -1;

//   /* 2 biến này không set final bởi vì nó sẽ thay đổi giá trị khi người dùng tương tác */
//   late List<KhachHang> _khachHangRows;
//   late int _khachHangCount;

//   late final Future<void> _futureRecentKHs = _getRecentKHs();
//   Future<void> _getRecentKHs() async {
//     /* 
//     Delay 1 khoảng bằng thời gian animation của TabController 
//     Tạo chuyển động mượt mà 
//     */
//     await Future.delayed(kTabScrollDuration);
//     _khachHangRows = await dbProcess.queryKhachHang(numberRowIgnore: 1);
//     _khachHangCount = await dbProcess.queryCountKhachHang();
//   }

//   final _searchController = TextEditingController();

//   /*
//   Nếu có Độc giả mới được thêm (tức là đã điền đầy đủ thông tin hợp lệ + nhấn Save)
//   thì phương thức showDialog() sẽ trả về một KH mới
//   */
//   Future<void> _logicAddKH() async {
//     KhachHang? newKH = await showDialog(
//       context: context,
//       builder: (ctx) => const AddEditCustomerForm(),
//     );

//     // print(newKH);
//     if (newKH != null) {
//       // print(
//       //     "('${newKH.fullname}', '${newKH.dob.toVnFormat()}', '${newKH.address}', '${newKH.phoneNumber}', '${newKH.creationDate.toVnFormat()}', '${newKH.expirationDate.toVnFormat()}', 0),");
//       setState(() {
//         if (_khachHangRows.length < 8) {
//           _khachHangRows.add(newKH);
//         }
//         _khachHangCount++;
//         // print('total page = ${_KHCount ~/ 8 + min(_KHCount % 8, 1)}');
//       });
//     }
//   }

//   /*
//   Hàm này là logic xử lý khi người dùng nhấn vào nút Edit hoặc Long Press vào một Row trong bảng
//   Đầu tiên là show AddEditKHForm, showDialog() sẽ trả về:
//     - String 'updated', nếu người dùng nhấn Save
//     - null, nếu người dùng nhấn nút Close hoặc Click Outside of Dialog
//   */
//   Future<void> _logicEditKH() async {
//     String? message = await showDialog(
//       context: context,
//       builder: (ctx) => AddEditCustomerForm(
//         editKhachHang: _khachHangRows[_selectedRow],
//       ),
//     );

//     // print(message);
//     if (message == "updated") {
//       setState(() {});
//     }
//   }

//   /* 
//   Hàm này là logic Xóa Độc giả 
//   */
//   Future<void> _logicDeleteKH() async {
//     var deleteKHName = _khachHangRows[_selectedRow].hoTen;

//     /* Xóa dòng dữ liệu*/
//     await dbProcess.deleteKhachHang(
//       _khachHangRows[_selectedRow].maKhachHang!,
//     );

//     /* 
//     Lấy giá trị totalPages trước khi giảm _KHCount đi 1 đơn vị 
//     VD: Có 17 dòng dữ liệu, phân trang 8 dòng => Đang có 3 total page 
//     Nếu giảm _KHCount đi 1 đơn vị trước khi tính totalPages
//     thì totalPages chỉ còn 2 => SAI 
//     */
//     int totalPages = _khachHangCount ~/ 8 + min(_khachHangCount % 8, 1);
//     int currentPage = int.parse(_paginationController.text);

//     _khachHangCount--;

//     // print('totalPage = $totalPages');

//     if (currentPage == totalPages) {
//       _khachHangRows.removeAt(_selectedRow);
//       /* 
//       Trường hợp đặc biệt:
//       Thủ thư đang ở trang cuối cùng và xóa nốt dòng cuối cùng 
//       thì phải chuyển lại sang trang trước đó.
//       VD: Xóa hết các dòng ở trang 3 thì tự động chuyển về trang 2
//       */
//       if (_khachHangRows.isEmpty && _khachHangCount > 0) {
//         currentPage--;
//         _paginationController.text = currentPage.toString();
//         _loadKHsOfPageIndex(currentPage);
//       }
//       /* 
//       Nếu không còn trang trước đó, tức _KHCount == 0, thì không cần làm gì cả 
//       */
//     } else {
//       _loadKHsOfPageIndex(currentPage);
//     }

//     setState(() {});

//     if (mounted) {
//       Navigator.of(context).pop();
//       ScaffoldMessenger.of(context).clearSnackBars();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Đã xóa Khách Hàng $deleteKHName.',
//             textAlign: TextAlign.center,
//           ),
//           behavior: SnackBarBehavior.floating,
//           width: 400,
//         ),
//       );
//     }
//   }

//   /* Hàm này dùng để lấy các KH ở trang thứ Index và hiển thị lên bảng */
//   Future<void> _loadKHsOfPageIndex(int pageIndex) async {
//     String searchText = _searchController.text.toLowerCase();

//     List<KhachHang> newKHRows = searchText.isEmpty
//         ? await dbProcess.queryKhachHang(
//             numberRowIgnore: (pageIndex - 1) * 8 + 1)
//         : await dbProcess.queryKhachHangFullnameWithString(
//             numberRowIgnore: (pageIndex - 1) * 8 + 1,
//             str: searchText,
//           );

//     setState(() {
//       _khachHangRows = newKHRows;
//       /* 
//       Chuyển sang trang khác phải cho _selectedRow = -1
//       VD: 
//       Đang ở trang 1 và selectedRow = 4 (đang ở dòng 5),
//       mà chuyển sang trang 2, chỉ có 2 dòng
//       => Gây ra LỖI
//       */
//       _selectedRow = -1;
//     });
//   }

//   final _paginationController = TextEditingController(text: "1");

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: FutureBuilder(
//         future: _futureRecentKHs,
//         builder: (ctx, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }

//           int totalPages = _khachHangCount ~/ 8 + min(_khachHangCount % 8, 1);

//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 MySearchBar(
//                   controller: _searchController,
//                   onSearch: (value) async {
//                     /* 
//                     Phòng trường hợp gõ tiếng việt
//                     VD: o -> (rỗng) -> ỏ
//                     Lúc này, value sẽ bằng '' (rỗng) nhưng _searchController.text lại bằng "ỏ"
//                     */
//                     if (_searchController.text == value) {
//                       _paginationController.text = '1';
//                       _khachHangCount =
//                           await dbProcess.queryCountKhachHangFullnameWithString(
//                               _searchController.text);
//                       _loadKHsOfPageIndex(1);
//                     }
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     /* 
//                     Đây là nút "Thêm độc giả" mới,
//                     Logic xử lý khi nhấn _logicAddKH xem ở bên trên
//                     */
//                     FilledButton.icon(
//                       onPressed: _logicAddKH,
//                       icon: const Icon(Icons.add_rounded),
//                       label: const Text('Thêm khách hàng'),
//                       style: TextButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 18, horizontal: 16),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     /* 
//                     Đây là nút "Xóa độc giả",
//                     Phòng trường hợp khi _selectedRow đang ở cuối bảng và ta nhấn xóa dòng cuối của bảng
//                     Lúc này _selectedRow đã nằm ngoài mảng, và nút "Xóa độc giả" vẫn chưa được Disable
//                     => Có khả năng gây ra lỗi
//                     Solution: Sau khi xóa phải kiểm tra lại 
//                     xem _selectedRow có nằm ngoài phạm vi của _KHRows hay không.
//                     */
//                     IconButton.filled(
//                       onPressed: _selectedRow == -1
//                           ? null
//                           : () async {
//                               await showDialog(
//                                 context: context,
//                                 builder: (ctx) => AlertDialog(
//                                   title: const Text('Xác nhận'),
//                                   content: Text(
//                                       'Bạn có chắc xóa Khách hàng ${_khachHangRows[_selectedRow].hoTen}?'),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   actions: [
//                                     TextButton(
//                                       onPressed: () {
//                                         Navigator.of(context).pop();
//                                       },
//                                       child: const Text('Huỷ'),
//                                     ),
//                                     FilledButton(
//                                       onPressed: _logicDeleteKH,
//                                       child: const Text('Có'),
//                                     ),
//                                   ],
//                                 ),
//                               );

//                               if (_selectedRow >= _khachHangRows.length) {
//                                 _selectedRow = -1;
//                               }
//                             },
//                       icon: const Icon(Icons.delete),
//                       style: myIconButtonStyle,
//                     ),
//                     const SizedBox(width: 12),
//                     /* 
//                     Nút "Sửa thông tin Độc Giả" 
//                     Logic xử lý _logicEditKH xem ở phần khai báo bên trên
//                     */
//                     IconButton.filled(
//                       onPressed: () {
//                         _selectedRow == -1 ? null : _logicEditKH();
//                       },
//                       icon: const Icon(Icons.edit),
//                       style: myIconButtonStyle,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),

//                 /* Bo góc cho DataTable */
//                 SizedBox(
//                   width: double.infinity,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     clipBehavior: Clip.antiAlias,
//                     child: DataTable(
//                       /* Set màu cho Heading */
//                       headingRowColor: MaterialStateColor.resolveWith(
//                         (states) => Theme.of(context).colorScheme.primary,
//                       ),
//                       /* The horizontal margin between the contents of each data column */
//                       columnSpacing: 40,
//                       dataRowColor: MaterialStateProperty.resolveWith(
//                         (states) => getDataRowColor(context, states),
//                       ),
//                       dataRowMaxHeight: 62,
//                       border: TableBorder.symmetric(),
//                       showCheckboxColumn: false,
//                       columns: List.generate(
//                         _colsName.length,
//                         (index) => DataColumn(
//                           label: Text(
//                             _colsName[index],
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontStyle: FontStyle.italic,
//                             ),
//                           ),
//                         ),
//                       ),
//                       rows: List.generate(
//                         _khachHangRows.length,
//                         (index) {
//                           KhachHang khachHang = _khachHangRows[index];
//                           /* Thẻ Độc Giả quá hạn sẽ tô màu xám (black26) */
//                           TextStyle cellTextStyle =
//                               const TextStyle(color: Colors.black);

//                           return DataRow(
//                             selected: _selectedRow == index,
//                             onSelectChanged: (_) => setState(() {
//                               _selectedRow = index;
//                             }),
//                             onLongPress: () {
//                               setState(() {
//                                 _selectedRow = index;
//                               });
//                               _logicEditKH();
//                             },
//                             cells: [
//                               DataCell(
//                                 Text(
//                                   khachHang.maKhachHang.toString(),
//                                   style: cellTextStyle,
//                                 ),
//                               ),
//                               DataCell(
//                                 Text(
//                                   khachHang.cccd.toString(),
//                                   style: cellTextStyle,
//                                 ),
//                               ),
//                               DataCell(
//                                 /* Ràng buộc cho Chiều rộng Tối đa của cột Họ Tên = 150 */
//                                 ConstrainedBox(
//                                   constraints:
//                                       const BoxConstraints(maxWidth: 150),
//                                   child: Text(
//                                     khachHang.hoTen
//                                         .capitalizeFirstLetterOfEachWord(),
//                                     style: cellTextStyle,
//                                   ),
//                                 ),
//                               ),
//                               DataCell(
//                                 Text(
//                                   khachHang.ngaySinh.toVnFormat(),
//                                   style: cellTextStyle,
//                                 ),
//                               ),
//                               DataCell(
//                                 Text(
//                                   khachHang.soDienThoai,
//                                   style: cellTextStyle,
//                                 ),
//                               ),
//                               DataCell(
//                                 Text(
//                                   khachHang.hangGPLX!
//                                       .capitalizeFirstLetterOfEachWord(),
//                                   style: cellTextStyle,
//                                 ),
//                               ),
//                               DataCell(
//                                 /* 
//                                 Ràng buộc cho Chiều rộng Tối đa của cột Địa chỉ = 250 
//                                 phòng trường hợp địa chỉ quá dài
//                                 */
//                                 ConstrainedBox(
//                                   constraints:
//                                       const BoxConstraints(maxWidth: 250),
//                                   child: Text(
//                                     khachHang.ghiChu == null
//                                         ? ''
//                                         : khachHang.ghiChu!,
//                                     style: cellTextStyle,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//                 if (_khachHangCount > 0) const Spacer(),
//                 _khachHangCount > 0
//                     ? Pagination(
//                         controller: _paginationController,
//                         maxPages: totalPages,
//                         onChanged: _loadKHsOfPageIndex,
//                       )
//                     : const Expanded(
//                         child: Center(
//                           child: Text(
//                             'Chưa có dữ liệu Khách hàng',
//                             style:
//                                 TextStyle(fontSize: 16, color: Colors.black54),
//                           ),
//                         ),
//                       ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
