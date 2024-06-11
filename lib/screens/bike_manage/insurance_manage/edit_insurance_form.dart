import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:rent_bik/components/label_text_form_field.dart';
import 'package:rent_bik/components/label_text_form_field_date_picker.dart';
import 'package:rent_bik/main.dart';
import 'package:rent_bik/models/bao_hiem_xe.dart';
import 'package:rent_bik/utils/common_variables.dart';
import 'package:rent_bik/utils/extesion.dart';

class EditBHXForm extends StatefulWidget {
  const EditBHXForm({super.key, required this.editBaoHiemXe});
  final BaoHiemXe editBaoHiemXe;

  @override
  State<EditBHXForm> createState() => _EditBHXFormState();
}

class _EditBHXFormState extends State<EditBHXForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  final _bhxNumberController = TextEditingController();

  final _ngayMuaController = TextEditingController();

  final _ngayHetHanController = TextEditingController();

  final _soTienController = TextEditingController();

  void saveBaoHiemXe(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });

      widget.editBaoHiemXe.ngayMua =
          vnDateFormat.parse(_ngayMuaController.text);
      widget.editBaoHiemXe.ngayHetHan =
          vnDateFormat.parse(_ngayHetHanController.text);
      widget.editBaoHiemXe.soBHX = _bhxNumberController.text;
      widget.editBaoHiemXe.soTien = int.parse(_soTienController.text);

      await dbProcess.updateBaoHiemXe(widget.editBaoHiemXe);

      if (mounted) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop('updated');
      }

      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin thành công'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
            width: 300,
          ),
        );
      }
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
    _bhxNumberController.text = widget.editBaoHiemXe.soBHX;
    _ngayMuaController.text = widget.editBaoHiemXe.ngayMua.toVnFormat();
    _ngayHetHanController.text = widget.editBaoHiemXe.ngayHetHan.toVnFormat();
    _soTienController.text = widget.editBaoHiemXe.soTien.toString();
  }

  @override
  void dispose() {
    /* dispose các controller để tránh lãng phí bộ nhớ */
    _ngayMuaController.dispose();
    _bhxNumberController.dispose();
    _ngayHetHanController.dispose();
    _soTienController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: SizedBox(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 30,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'SỬA THÔNG TIN BẢO HIỂM XE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Mã BHX",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.editBaoHiemXe.maBHX.toString(),
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 10),
                LabelTextFormField(
                  labelText: 'Số bảo hiểm xe',
                  controller: _bhxNumberController,
                ),
                //

                const SizedBox(height: 10),
                LabelTextFieldDatePicker(
                  labelText: 'Ngày mua',
                  controller: _ngayMuaController,
                  initialDateInPicker: widget.editBaoHiemXe.ngayMua,
                  lastDate: DateTime.now().addYears(10),
                ),
                const SizedBox(height: 10),

                LabelTextFieldDatePicker(
                  labelText: 'Ngày hết hạn',
                  controller: _ngayHetHanController,
                  initialDateInPicker: widget.editBaoHiemXe.ngayHetHan,
                  lastDate: DateTime.now().addYears(10),
                ),
                //
                const SizedBox(height: 10),
                LabelTextFormField(
                  labelText: 'Số tiền mua',
                  controller: _soTienController,
                ),
                //
                const SizedBox(height: 50),
                Align(
                  alignment: Alignment.center,
                  child: _isProcessing
                      ? const SizedBox(
                          height: 44,
                          width: 44,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : FilledButton(
                          onPressed: () => saveBaoHiemXe(context),
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
                            'Lưu',
                            textAlign: TextAlign.center,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
