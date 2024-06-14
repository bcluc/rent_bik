import 'package:dart_date/dart_date.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:rent_bik/components/inform_dialog.dart';
import 'package:rent_bik/components/label_text_form_field.dart';
import 'package:rent_bik/components/label_text_form_field_date_picker.dart';
import 'package:rent_bik/components/my_search_bar.dart';
import 'package:rent_bik/dto/khach_hang_dto.dart';
import 'package:rent_bik/dto/phieu_thue_dto.dart';
import 'package:rent_bik/dto/xe_dto.dart';
import 'package:rent_bik/main.dart';
import 'package:rent_bik/models/phieu_thue.dart';
import 'package:rent_bik/screens/borrow_return_manage/borrow/xuat_phieu_thue_switch.dart';
import 'package:rent_bik/utils/common_variables.dart';
import 'package:rent_bik/utils/extesion.dart';
import 'package:rent_bik/utils/pdf_util.dart';

class ThueXe extends StatefulWidget {
  const ThueXe({super.key});

  @override
  State<ThueXe> createState() => _ThueXeState();
}

class _ThueXeState extends State<ThueXe> {
  late List<XeDTO> _xes;
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

  final _searchCCCDController = TextEditingController();
  final _ngayMuonController = TextEditingController(
    text: DateTime.now().toVnFormat(),
  );
  final _ngayTraController = TextEditingController(
    text: DateTime.now().addDays(3).toVnFormat(),
  );
  final _tienCocController = TextEditingController();

  /*
  Có thể cho _maCuonSachToAddCuonSachController vào trong SachDaChon() cũng được
  Nhưng khi MuonSach() rebuild 
  thì _maCuonSachToAddCuonSachController cũng sẽ được tạo lại trong SachDaChon()
  => Mất giá trị đang nhập
  */
  final _maXeMuonController = TextEditingController();

  bool _isProcessingCCCD = false;
  bool _isProcessingLuuPhieuMuon = false;

  String _errorText = '';
  String _hangGPLX = '';
  String _hoTenKH = '';
  String _bienSoXeThue = '';
  int _maXe = -1;
  int _maKH = -1;
  late XeDTO? _selectedXe;
  bool _isInPhieuMuon = true;

  Future<void> _searchMaDocGia() async {
    _errorText = '';
    if (_searchCCCDController.text.isEmpty) {
      _errorText = 'Bạn chưa nhập căn cước công dân.';
    }

    if (_errorText.isNotEmpty) {
      setState(() {});
      return;
    }

    setState(() {
      _isProcessingCCCD = true;
    });

    _hoTenKH = '';
    _hangGPLX = '';
    _maXe = -1;
    _maKH = -1;
    _selectedXe = null;
    _bienSoXeThue = '';

    String cccd = _searchCCCDController.text;

    print(_searchCCCDController.text);

    String res = await dbProcess.getStatusKHWithCCCD(cccd);
    print(res);

    await Future.delayed(const Duration(milliseconds: 200));

    if (res == "error") {
      _errorText = 'Không tìm thấy Thông tin khách hàng.';
    } else {
      KhachHangDTO khThue = await dbProcess.getKHWithString(str: cccd);
      _hoTenKH = khThue.hoTen.capitalizeFirstLetterOfEachWord();
      _hangGPLX = khThue.hangGPLX.toString();
      _maKH = khThue.maKH;
    }

    setState(() {
      _isProcessingCCCD = false;
    });
  }

  void _savePhieuThue() async {
    /* Kiểm tra mã độc giả đã được nhập đúng đắn chưa */
    if (_hangGPLX.isEmpty) {
      await _searchMaDocGia();
      if (_hangGPLX.isEmpty) {
        return;
      }
    }
    if (_selectedXe == null) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (ctx) => const InformDialog(content: 'Bạn chưa chọn xe'),
      );

      return;
    }

    if (_tienCocController.text == '') {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (ctx) => const InformDialog(content: 'Bạn chưa nhập số tiền'),
      );

      return;
    } else {
      if (int.tryParse(_tienCocController.text) == null) {
        _errorText = 'Tiền cọc là một con số.';
      }
    }
    _errorText = '';

    setState(() {
      _isProcessingLuuPhieuMuon = true;
    });

    final phieuThue = PhieuThueDTO(
      maKH: _maKH,
      maXe: _selectedXe!.maXe!,
      ngayThue: vnDateFormat.parse(_ngayMuonController.text),
      ngayTra: vnDateFormat.parse(_ngayTraController.text),
      giaCoc: int.parse(_tienCocController.text),
    );

    /* Không cần await cũng được */
    int res = await dbProcess.insertPhieuThue(phieuThue);

    if (res == -1) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (ctx) =>
            const InformDialog(content: 'Phiếu thuê không hợp lệ'),
      );
      setState(() {
        _isProcessingLuuPhieuMuon = false;
      });
      return;
    }

    await Future.delayed(const Duration(milliseconds: 200));

    if (mounted) {
      _bienSoXeThue = '';
      /* Hiện thị thông báo lưu Phiếu mượn thành công */
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lưu Phiếu thuê thành công',
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
          width: 300,
        ),
      );
    }

    if (_isInPhieuMuon) {
      final phieuMuonDocument = await PdfApi.generatePhieuMuon(
        maDocGia: _hangGPLX,
        hoTen: _hoTenKH,
        ngayMuon: _ngayMuonController.text,
        hanTra: _ngayTraController.text,
        xeDTO: _selectedXe!,
      );
      final phieuMuonPdfFile = await PdfApi.saveDocument(
        name: removeDiacritics(_hoTenKH).replaceAll(' ', '') +
            DateFormat('_ddMMyyyy_Hms').format(DateTime.now()),
        pdfDoc: phieuMuonDocument,
      );

      PdfApi.openFile(phieuMuonPdfFile);
    }

    /* Sau khi lưu xong dữ liệu vào DB thì ta reset lại trang */
    _searchCCCDController.clear();

    _searchController.clear();
    _maXeMuonController.clear();
    setState(() {
      _hangGPLX = '';
      _hoTenKH = '';
      _bienSoXeThue = '';
      _selectedXe = null;
      _maKH = -1;
      _maXe = -1;
    });

    setState(() {
      _isProcessingLuuPhieuMuon = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _ngayMuonController.addListener(() {
      _ngayTraController.text =
          vnDateFormat.parse(_ngayMuonController.text).addDays(3).toVnFormat();
    });
  }

  @override
  void dispose() {
    _searchCCCDController.dispose();
    _ngayMuonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tìm khách hàng',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCCCDController,
                            autofocus: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(255, 245, 246, 250),
                              hintText: 'Nhập căn cước công dân',
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.all(14),
                              isCollapsed: true,
                              errorMaxLines: 2,
                            ),
                            onEditingComplete: _searchMaDocGia,
                          ),
                        ),
                        const Gap(10),
                        _isProcessingCCCD
                            ? Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                height: 44,
                                width: 44,
                                padding: const EdgeInsets.all(12),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : IconButton.filled(
                                onPressed: _searchMaDocGia,
                                icon: const Icon(Icons.arrow_downward_rounded),
                                style: myIconButtonStyle,
                              ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(30),
              Expanded(
                child: LabelTextFieldDatePicker(
                  labelText: 'Ngày mượn',
                  controller: _ngayMuonController,
                  lastDate: DateTime.now().addYears(3),
                  initialDateInPicker:
                      vnDateFormat.parse(_ngayMuonController.text),
                ),
              ),
              const Gap(30),
              Expanded(
                child: LabelTextFieldDatePicker(
                  labelText: 'Ngày trả',
                  controller: _ngayTraController,
                  lastDate: DateTime.now().addYears(3),
                  initialDateInPicker:
                      vnDateFormat.parse(_ngayMuonController.text).addDays(3),
                ),
              ),
              const Gap(30),
              Expanded(
                  child: LabelTextFormField(
                labelText: 'Số tiền cọc',
                hint: "Nhập tiền cọc",
                controller: _tienCocController,
              )),
            ],
          ),
          const Gap(10),
          const Divider(),
          const Gap(8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Họ tên: $_hoTenKH',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'Hạng GPLX: $_hangGPLX',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(30),
              Expanded(
                child: XuatPhieuThueSwitch(
                  onSwitchChanged: (value) => _isInPhieuMuon = value,
                ),
              ),
            ],
          ),
          const Gap(10),
          const Divider(),
          const Gap(10),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      /* SÁCH TRONG KHO */
                      Expanded(
                          child: FutureBuilder(
                        future: _futureXes,
                        builder: (ctx, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          String searchText =
                              _searchController.text.toLowerCase();
                          if (searchText.isEmpty) {
                            _filteredXes = List.of(_xes);
                          } else {
                            _filteredXes = _xes.where((element) {
                              if (element.bienSoXe
                                      .toLowerCase()
                                      .contains(searchText) ||
                                  element
                                      .dongXeToString()
                                      .toLowerCase()
                                      .contains(searchText) ||
                                  element
                                      .hangXeToString()
                                      .toLowerCase()
                                      .contains(searchText)) {
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
                                const Row(
                                  children: [
                                    Text(
                                      'Danh sách Xe',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
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
                                                      fontStyle:
                                                          FontStyle.italic,
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
                                                      fontStyle:
                                                          FontStyle.italic,
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
                                                      fontStyle:
                                                          FontStyle.italic,
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
                                                      color: _selectedRow ==
                                                              index
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .primary
                                                              .withOpacity(0.1)
                                                          : null,
                                                      child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            _selectedRow =
                                                                index;
                                                            _selectedXe =
                                                                _filteredXes[
                                                                    _selectedRow];
                                                            _bienSoXeThue =
                                                                _selectedXe!
                                                                    .bienSoXe;
                                                          });
                                                        },
                                                        child: Row(
                                                          children: [
                                                            const Gap(30),
                                                            SizedBox(
                                                              width: 80,
                                                              child: Text(
                                                                (index + 1)
                                                                    .toString(),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  vertical: 15,
                                                                  horizontal:
                                                                      15,
                                                                ),
                                                                child: Text(
                                                                  _filteredXes[
                                                                          index]
                                                                      .bienSoXe
                                                                      .capitalizeFirstLetterOfEachWord(),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal:
                                                                      15,
                                                                ),
                                                                child: Text(
                                                                  _filteredXes[
                                                                          index]
                                                                      .tinhTrang
                                                                      .capitalizeFirstLetterOfEachWord(),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal:
                                                                      15,
                                                                ),
                                                                child: Text(
                                                                    _filteredXes[
                                                                            index]
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
                                                                      _filteredXes[
                                                                              index]
                                                                          .giaThue
                                                                          .toString(),
                                                                    ),
                                                                  ),
                                                                  const Gap(10),
                                                                  if (_selectedRow ==
                                                                      index)
                                                                    Icon(
                                                                      Icons
                                                                          .check,
                                                                      color: Theme.of(
                                                                              context)
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
                                                    if (index <
                                                        _filteredXes.length - 1)
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
                      )),
                      /* Khoảng trắng 30 pixel */
                    ],
                  ),
                ),
                const Gap(5),
                Row(
                  children: [
                    Text(
                      _errorText,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const Gap(5),
                Row(
                  children: [
                    Text(
                      "XE ĐÃ CHỌN: $_bienSoXeThue",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    _isProcessingLuuPhieuMuon
                        ? const SizedBox(
                            height: 44,
                            width: 123,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 49.5),
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            ),
                          )
                        : FilledButton(
                            onPressed: () => _savePhieuThue(),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 30,
                              ),
                            ),
                            child: const Text(
                              'Lưu phiếu',
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
