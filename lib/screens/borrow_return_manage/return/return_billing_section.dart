import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rent_bik/components/inform_dialog.dart';
import 'package:rent_bik/dto/phieu_tra_dto.dart';
import 'package:rent_bik/main.dart';
import 'package:rent_bik/utils/common_variables.dart';
import 'package:rent_bik/utils/extesion.dart';

class TraPhieuThueSection extends StatefulWidget {
  const TraPhieuThueSection({
    super.key,
    required this.maPhieuThue,
    required this.onTra,
  });

  final int? maPhieuThue;
  final void Function() onTra;

  @override
  State<TraPhieuThueSection> createState() => _TraPhieuThueSectionState();
}

class _TraPhieuThueSectionState extends State<TraPhieuThueSection> {
  final _ngayThanhToanController = TextEditingController(
    text: DateTime.now().toVnFormat(),
  );
  final _soTienController = TextEditingController();
  final _soHanhTrinhController = TextEditingController();
  final _ghiChuController = TextEditingController();
  int _soTienThue = 0;

  Future<void> _getSoTienThue() async {
    if (widget.maPhieuThue == null) {
      showDialog(
        context: context,
        builder: (ctx) =>
            const InformDialog(content: 'Bạn chưa chọn Mã Phiếu thuê'),
      );

      return;
    }
    int res = await dbProcess.kiemTraTienPhieuThue(
        widget.maPhieuThue!, _ngayThanhToanController.text);
    setState(() {
      _soTienThue = res;
    });
    return;
  }

  Future<void> openDatePicker(BuildContext context) async {
    DateTime? chosenDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().addYears(2),
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
    if (widget.maPhieuThue == null) {
      showDialog(
        context: context,
        builder: (ctx) =>
            const InformDialog(content: 'Bạn chưa chọn Mã Phiếu thuê'),
      );

      return;
    }

    if (_soHanhTrinhController.text == '') {
      showDialog(
        context: context,
        builder: (ctx) =>
            const InformDialog(content: 'Bạn chưa nhập số hành trình'),
      );

      return;
    }

    final PhieuTraDTO phieuTra = PhieuTraDTO(
        maPhieuThue: widget.maPhieuThue!,
        phiPhat: _soTienController.text == ''
            ? null
            : int.parse(_soTienController.text),
        ngayTra: vnDateFormat.parse(_ngayThanhToanController.text),
        soHanhTrinhMoi: int.parse(_soHanhTrinhController.text),
        note: _ghiChuController.text);

    /* Cập nhật Trạng thái Cuốn sách = 'Có Sẵn' */
    dbProcess.insertPhieuTra(phieuTra);

    /* Gọi phương thức từ Widget cha là TraSach để xử lý xóa phiếu mượn và trả */
    widget.onTra();

    /* Hiện thị thông báo lưu Phiếu mượn thành công */
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Phiếu trả thành công',
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
    _ghiChuController.dispose();
    _soHanhTrinhController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'PHIẾU TRẢ',
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
                            'Mã Phiếu thuê',
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
                              widget.maPhieuThue == null
                                  ? ''
                                  : '${widget.maPhieuThue}',
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
                            'Ngày trả',
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
                            'Số tiền phạt',
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
                              hintText: "Nhập tiền phạt (Không bắt buộc)",
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
                    const Gap(30),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Số hành trình mới',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _soHanhTrinhController,
                            enabled: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Nhập số hành trình mới (km)",
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
                const Gap(5),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ghi chú',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _ghiChuController,
                            enabled: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Nhập ghi chú tại đây (Không bắt buộc)",
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
                Row(
                  children: [
                    Text(
                      'TỔNG TIỀN THUÊ: $_soTienThue',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => _getSoTienThue(),
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
                        'Kiểm tra tiền thuê',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
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
                        'Lưu phiếu',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
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
