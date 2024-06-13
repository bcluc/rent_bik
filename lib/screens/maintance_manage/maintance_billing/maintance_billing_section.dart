import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rent_bik/components/inform_dialog.dart';
import 'package:rent_bik/main.dart';
import 'package:rent_bik/utils/extesion.dart';

class ThanhToanBaoTriSection extends StatefulWidget {
  const ThanhToanBaoTriSection({
    super.key,
    required this.maPhieuBaoTri,
    required this.ngayThanhToan,
    required this.onThanhToan,
  });

  final int? maPhieuBaoTri;
  final DateTime? ngayThanhToan;
  final void Function() onThanhToan;

  @override
  State<ThanhToanBaoTriSection> createState() => _ThanhToanBaoTriSectionState();
}

class _ThanhToanBaoTriSectionState extends State<ThanhToanBaoTriSection> {
  final _ngayThanhToanController = TextEditingController(
    text: DateTime.now().toVnFormat(),
  );
  final _soTienController = TextEditingController();

  Future<void> openDatePicker(BuildContext context) async {
    DateTime? chosenDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (chosenDate != null) {
      setState(() {
        _ngayThanhToanController.text = chosenDate.toVnFormat();
      });
      /* 
      Bản chất, 
      giá trị của TextField chứa _ngayTraController vẫn sẽ thay đổi và không cần gọi setState 
      nhưng, PHẢI gọi setState để cập nhật lại số tiền được hiển thị phụ thuộc vào ngày trả.
      */
    }
  }

  void _savePhieuTra() async {
    if (widget.maPhieuBaoTri == null) {
      showDialog(
        context: context,
        builder: (ctx) =>
            const InformDialog(content: 'Bạn chưa chọn Mã Phiếu mượn'),
      );

      return;
    }
    if (_soTienController.text == '') {
      showDialog(
        context: context,
        builder: (ctx) => const InformDialog(content: 'Bạn chưa nhập số tiền'),
      );

      return;
    }

    /* Cập nhật Trạng thái Cuốn sách = 'Có Sẵn' */
    dbProcess.thanhToanPhieuBaoTri(widget.maPhieuBaoTri!,
        _ngayThanhToanController.text, int.parse(_soTienController.text));

    /* Gọi phương thức từ Widget cha là TraSach để xử lý xóa phiếu mượn và trả */
    widget.onThanhToan();

    /* Hiện thị thông báo lưu Phiếu mượn thành công */
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Thanh toán phiếu bảo trì thành công',
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
    _ngayThanhToanController.dispose();
    _soTienController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'THANH TOÁN PHIẾU BẢO TRÌ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(6),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                            'Mã Phiếu bảo trì',
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.maPhieuBaoTri == null
                                  ? ''
                                  : '${widget.maPhieuBaoTri}',
                              style: const TextStyle(
                                fontSize: 16,
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
                            'Ngày thanh toán',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => openDatePicker(context),
                            child: TextField(
                              controller: _ngayThanhToanController,
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
                            'Số tiền thanh toán',
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
                              hintText: "Nhập số tiền thanh toán",
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
                  onPressed: () => _savePhieuTra(),
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
                    'Thanh toán',
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
