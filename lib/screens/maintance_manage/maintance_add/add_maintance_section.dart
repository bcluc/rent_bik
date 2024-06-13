import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rent_bik/components/inform_dialog.dart';
import 'package:rent_bik/main.dart';
import 'package:rent_bik/utils/extesion.dart';

class AddMaintanceSection extends StatefulWidget {
  const AddMaintanceSection({
    super.key,
    required this.bienSoXe,
  });
  final String? bienSoXe;

  @override
  State<AddMaintanceSection> createState() => _AddMaintanceSectionState();
}

class _AddMaintanceSectionState extends State<AddMaintanceSection> {
  final _ngayThemController = TextEditingController();
  final _bienSoXeController = TextEditingController();

  Future<void> openDateAddPicker(BuildContext context) async {
    DateTime? chosenDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().addYears(20),
    );
    if (chosenDate != null) {
      setState(() {
        _ngayThemController.text = chosenDate.toVnFormat();
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
    widget.bienSoXe == null
        ? _bienSoXeController.text = ""
        : _bienSoXeController.text = widget.bienSoXe!;
    _ngayThemController.text = DateTime.now().toVnFormat();
  }

  void _savePBT() async {
    if (_bienSoXeController.text == "") {
      showDialog(
        context: context,
        builder: (ctx) =>
            const InformDialog(content: 'Bạn chưa điền Biển số xe'),
      );
      return;
    }

    /* Thêm phiếu trả */
    int resInsert = await dbProcess.insertPhieuBaoTri(
        _bienSoXeController.text, _ngayThemController.text);

    if (resInsert == -1 && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => const InformDialog(
            content: 'Phiếu bảo trì không được lưu thành công'),
      );
      return;
    }
    if (resInsert == -2 && mounted) {
      showDialog(
        context: context,
        builder: (ctx) =>
            const InformDialog(content: 'Xe hiện đang không có sẵn'),
      );
      return;
    }

    /* Hiện thị thông báo lưu Phiếu mượn thành công */
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Thêm phiếu thành công',
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
    _ngayThemController.dispose();
    _bienSoXeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'THÊM PHIẾU BẢO TRÌ XE',
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
                            'Biển số xe',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 44,
                            alignment: Alignment.centerLeft,
                            padding: widget.bienSoXe != null
                                ? const EdgeInsets.symmetric(horizontal: 14)
                                : null,
                            decoration: BoxDecoration(
                              color: widget.bienSoXe == null
                                  ? Colors.white
                                  : const Color.fromARGB(255, 245, 245, 245),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: widget.bienSoXe != null
                                ? Text(
                                    '${widget.bienSoXe}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  )
                                : TextFormField(
                                    controller: _bienSoXeController,
                                    enabled: true,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: "Nhập biển số xe",
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
                            'Ngày bảo trì',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => openDateAddPicker(context),
                            child: TextField(
                              controller: _ngayThemController,
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
                  ],
                ),
                const Gap(20),
                FilledButton(
                  onPressed: () => _savePBT(),
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
                const Gap(20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
