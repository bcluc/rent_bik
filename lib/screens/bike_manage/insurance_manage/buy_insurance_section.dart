import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rent_bik/components/inform_dialog.dart';
import 'package:rent_bik/main.dart';
import 'package:rent_bik/models/bao_hiem_xe.dart';
import 'package:rent_bik/utils/common_variables.dart';
import 'package:rent_bik/utils/extesion.dart';

class BuyInsuranceSection extends StatefulWidget {
  const BuyInsuranceSection({
    super.key,
    required this.soBHX,
    required this.maXe,
    required this.bienSoXe,
    required this.ngayMua,
    required this.ngayHetHan,
    required this.onAdd,
  });

  final String? soBHX;
  final String? bienSoXe;
  final int? maXe;
  final DateTime? ngayMua;
  final DateTime? ngayHetHan;
  final void Function() onAdd;
  @override
  State<BuyInsuranceSection> createState() => _BuyInsuranceSectionState();
}

class _BuyInsuranceSectionState extends State<BuyInsuranceSection> {
  final _ngayMuaController = TextEditingController();
  final _ngayHetHanController = TextEditingController();
  final _soTienController = TextEditingController();
  final _soBHXController = TextEditingController();

  Future<void> openDateExpiredPicker(BuildContext context) async {
    DateTime? chosenDate = await showDatePicker(
      context: context,
      initialDate: widget.ngayHetHan,
      firstDate: DateTime(1950),
      lastDate: DateTime.now().addYears(20),
    );
    if (chosenDate != null) {
      setState(() {
        _ngayHetHanController.text = chosenDate.toVnFormat();
      });
    }
  }

  Future<void> openDateBuyPicker(BuildContext context) async {
    DateTime? chosenDate = await showDatePicker(
      context: context,
      initialDate: widget.ngayMua,
      firstDate: DateTime(1950),
      lastDate: DateTime.now().addYears(20),
    );
    if (chosenDate != null) {
      setState(() {
        _ngayMuaController.text = chosenDate.toVnFormat();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    //print(widget.editBaoHiemXe.toString());
    /*
    Nếu là chỉnh sửa khách hàng
    thì phải fill thông tin vào của khách hàng cần chỉnh sửa vào form
    */
    widget.ngayMua == null
        ? _ngayMuaController.text = DateTime.now().toVnFormat()
        : _ngayMuaController.text = widget.ngayMua!.toVnFormat();
    widget.ngayHetHan == null
        ? _ngayHetHanController.text = ""
        : _ngayHetHanController.text = widget.ngayHetHan!.toVnFormat();
    widget.soBHX == null
        ? _soBHXController.text = ""
        : _soBHXController.text = widget.soBHX!;
  }

  void _saveBHX() async {
    if (_soBHXController.text == "") {
      showDialog(
        context: context,
        builder: (ctx) =>
            const InformDialog(content: 'Bạn chưa điền Số bảo hiểm xe'),
      );
      return;
    }
    if (widget.maXe == null) {
      showDialog(
        context: context,
        builder: (ctx) => const InformDialog(content: 'Bạn chưa có mã xe'),
      );
      return;
    }
    final baoHiemXe = BaoHiemXe(
        soBHX: _soBHXController.text,
        ngayMua: vnDateFormat.parse(_ngayMuaController.text),
        ngayHetHan: vnDateFormat.parse(_ngayHetHanController.text),
        soTien: int.parse(_soTienController.text),
        bienSoXe: widget.bienSoXe!);

    /* Thêm phiếu trả */
    int resInsert = await dbProcess.insertBaoHiemXe(baoHiemXe, widget.maXe!);

    if (resInsert == -1 && mounted) {
      showDialog(
        context: context,
        builder: (ctx) =>
            const InformDialog(content: 'Xe không được thêm thành công'),
      );
      return;
    }
    widget.onAdd();

    /* Hiện thị thông báo lưu Phiếu mượn thành công */
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mua bảo hiểm xe thành công',
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
          width: 300,
        ),
      );
    }
  }

  @override
  void dispose() {
    _ngayMuaController.dispose();
    _ngayHetHanController.dispose();
    _soTienController.dispose();
    _soBHXController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'MUA BẢO HIỂM XE',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(6),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Gap(22),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Số Bảo hiểm xe',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 44,
                            alignment: Alignment.centerLeft,
                            padding: widget.soBHX != null
                                ? const EdgeInsets.symmetric(horizontal: 14)
                                : null,
                            decoration: BoxDecoration(
                              color: widget.soBHX == null
                                  ? Colors.white
                                  : const Color.fromARGB(255, 245, 245, 245),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: widget.soBHX != null
                                ? Text(
                                    '${widget.soBHX}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  )
                                : TextFormField(
                                    controller: _soBHXController,
                                    enabled: true,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: "Nhập số bảo hiểm xe",
                                      hintStyle: const TextStyle(
                                          color: Color(0xFF888888)),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: const EdgeInsets.all(14),
                                      isCollapsed: true,
                                      errorMaxLines: 2,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(30),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mã xe',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 44,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 245, 245, 245),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: widget.maXe != -1
                                ? Text(
                                    widget.maXe.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  )
                                : const Text(
                                    "",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(22),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ngày mua',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => openDateBuyPicker(context),
                            child: TextField(
                              controller: _ngayMuaController,
                              enabled: false,
                              mouseCursor: SystemMouseCursors.click,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'dd/MM/yyyy',
                                hintStyle:
                                    const TextStyle(color: Color(0xFF888888)),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.all(14),
                                isCollapsed: true,
                                suffixIcon: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 14),
                                  child: Icon(
                                    Icons.calendar_today,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(30),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ngày hết hạn',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => openDateExpiredPicker(context),
                            child: TextField(
                              controller: _ngayHetHanController,
                              enabled: false,
                              mouseCursor: SystemMouseCursors.click,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'dd/MM/yyyy',
                                hintStyle:
                                    const TextStyle(color: Color(0xFF888888)),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.all(14),
                                isCollapsed: true,
                                suffixIcon: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 14),
                                  child: Icon(
                                    Icons.calendar_today,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(30),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Số tiền',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _soTienController,
                            enabled: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Nhập số tiền mua bảo hiểm",
                              hintStyle:
                                  const TextStyle(color: Color(0xFF888888)),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.all(14),
                              isCollapsed: true,
                              errorMaxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(20),
                FilledButton(
                  onPressed: () => _saveBHX(),
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
                    'Thêm',
                    textAlign: TextAlign.center,
                  ),
                ),
                const Gap(20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
