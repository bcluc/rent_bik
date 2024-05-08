import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rent_bik/components/my_search_bar.dart';
import 'package:rent_bik/dto/xe_dto.dart';
import 'package:rent_bik/main.dart';
import 'package:rent_bik/models/xe.dart';
import 'package:rent_bik/screens/bike_manage/bike_add/add_edit_bike_form.dart';
import 'package:rent_bik/utils/common_variables.dart';
import 'package:rent_bik/utils/extesion.dart';

class BikeWarehouse extends StatefulWidget {
  const BikeWarehouse({super.key});

  @override
  State<BikeWarehouse> createState() => _BikeWarehouseState();
}

class _BikeWarehouseState extends State<BikeWarehouse> {
  late final List<XeDTO> _xes;
  late List<XeDTO> _filteredXes;

  int _selectedRow = -1;

  final _searchController = TextEditingController();

  late final Future<void> _futureXes = _getXes();
  Future<void> _getXes() async {
    /* 
    Delay 1 khoảng bằng thời gian animation của TabController 
    Tạo chuyển động mượt mà 
    */
    await Future.delayed(kTabScrollDuration);
    _xes = await dbProcess.queryXeDto();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureXes,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        String searchText = _searchController.text.toLowerCase();
        if (searchText.isEmpty) {
          _filteredXes = List.of(_xes);
        } else {
          _filteredXes = _xes.where((element) {
            if (element.bienSoXe.toLowerCase().contains(searchText) ||
                element.dongXeToString().toLowerCase().contains(searchText) ||
                element.hangXeToString().toLowerCase().contains(searchText)) {
              return true;
            }
            return false;
          }).toList();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MySearchBar(
                controller: _searchController,
                onSearch: (value) {
                  /* 
                  Phòng trường hợp gõ tiếng việt
                  VD: o -> (rỗng) -> ỏ
                  Lúc này, value sẽ bằng '' (rỗng) nhưng _searchController.text lại bằng "ỏ"
                  */
                  if (_searchController.text == value) {
                    setState(() {});
                  }
                },
              ),
              const Gap(20),
              Row(
                children: [
                  const Text(
                    'Danh sách Xe',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () async {
                      // Xử lý Thêm Đầu Sách
                      XeDTO? newXeDTO = await showDialog(
                        context: context,
                        builder: (ctx) => const AddEditBikeForm(),
                      );

                      if (newXeDTO != null) {
                        setState(() {
                          _xes.add(newXeDTO);
                        });
                      }
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Thêm xe'),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 16),
                    ),
                  ),
                  const Gap(12),
                  IconButton.filled(
                    onPressed: (_selectedRow == -1)
                        ? null
                        : () async {
                            final readyDeleteXe = _filteredXes[_selectedRow];
                            await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Xác nhận'),
                                content: Text(
                                    'Bạn có chắc xóa Xe ${readyDeleteXe.bienSoXe}?'),
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
                                    onPressed: () async {
                                      await dbProcess
                                          .deleteXeWithId(readyDeleteXe.maXe!);

                                      setState(() {
                                        _xes.removeWhere((element) =>
                                            element.maXe == readyDeleteXe.maXe);
                                        _filteredXes.removeAt(_selectedRow);
                                        /*
                                        Phòng trường hợp khi _selectedRow đang ở cuối bảng và ta nhấn xóa dòng cuối của bảng
                                        Lúc này _selectedRow đã nằm ngoài mảng, và nút "Xóa" vẫn chưa được Disable
                                        => Có khả năng gây ra lỗi
                                        Solution: Sau khi xóa phải kiểm tra lại 
                                        xem _selectedRow có nằm ngoài phạm vi của _filteredXes hay không.
                                        */
                                        if (_selectedRow >=
                                            _filteredXes.length) {
                                          _selectedRow = -1;
                                        }
                                      });
                                      if (mounted) {
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context)
                                            .clearSnackBars();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Đã xóa Xe ${readyDeleteXe.bienSoXe}.',
                                              textAlign: TextAlign.center,
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            width: 400,
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text('Có'),
                                  ),
                                ],
                              ),
                            );
                          },
                    icon: const Icon(Icons.delete),
                    style: myIconButtonStyle,
                    tooltip: 'Chỉ có thể xóa những Xe đã có.',
                  ),
                  const Gap(12),
                  /* 
                    Nút "Sửa thông tin Đầu sách" 
                    Logic xử lý _logicEditReader xem ở phần khai báo bên trên
                    */
                  IconButton.filled(
                    onPressed: _selectedRow == -1
                        ? null
                        : () async {
                            String? message = await showDialog(
                              context: context,
                              builder: (ctx) => AddEditBikeForm(
                                editXe: _filteredXes[_selectedRow],
                              ),
                            );

                            if (message == 'updated') {
                              setState(() {});
                            }
                          },
                    icon: const Icon(Icons.edit),
                    style: myIconButtonStyle,
                  ),
                ],
              ),
              const Gap(10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    children: [
                      Container(
                        color: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 30,
                        ),
                        child: const Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(
                                '#',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                child: Text(
                                  'Biển số xe',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                child: Text(
                                  'Tình trạng',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                child: Text(
                                  'Loại xe',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                'Giá thuê',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: List.generate(
                            _filteredXes.length,
                            (index) {
                              return Column(
                                children: [
                                  Ink(
                                    color: _selectedRow == index
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.1)
                                        : null,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedRow = index;
                                        });
                                      },
                                      onLongPress: () async {
                                        setState(() {
                                          _selectedRow = index;
                                        });
                                        String? message = await showDialog(
                                          context: context,
                                          builder: (ctx) => AddEditBikeForm(
                                            editXe: _filteredXes[_selectedRow],
                                          ),
                                        );

                                        if (message == 'updated') {
                                          setState(() {});
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          const Gap(30),
                                          SizedBox(
                                            width: 80,
                                            child: Text(
                                              (index + 1).toString(),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 15,
                                                horizontal: 15,
                                              ),
                                              child: Text(
                                                _filteredXes[index]
                                                    .bienSoXe
                                                    .capitalizeFirstLetterOfEachWord(),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 15,
                                              ),
                                              child: Text(
                                                _filteredXes[index]
                                                    .tinhTrang
                                                    .capitalizeFirstLetterOfEachWord(),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 15,
                                              ),
                                              child: Text(_filteredXes[index]
                                                  .loaiXe
                                                  .capitalizeFirstLetterOfEachWord()),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 80,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    _filteredXes[index]
                                                        .giaThue
                                                        .toString(),
                                                  ),
                                                ),
                                                const Gap(10),
                                                if (_selectedRow == index)
                                                  Icon(
                                                    Icons.check,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  )
                                              ],
                                            ),
                                          ),
                                          const Gap(30),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (index < _filteredXes.length - 1)
                                    const Divider(
                                      height: 0,
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
