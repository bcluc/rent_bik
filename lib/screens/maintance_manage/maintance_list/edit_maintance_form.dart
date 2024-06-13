import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:rent_bik/components/label_text_form_field_date_picker.dart';
import 'package:rent_bik/main.dart';
import 'package:rent_bik/models/phieu_bao_tri.dart';
import 'package:rent_bik/utils/common_variables.dart';
import 'package:rent_bik/utils/extesion.dart';

class EditMaintanceForm extends StatefulWidget {
  const EditMaintanceForm({super.key, required this.editPhieuBaoTri});

  final PhieuBaoTri editPhieuBaoTri;

  @override
  State<EditMaintanceForm> createState() => _EditMaintanceFormState();
}

class _EditMaintanceFormState extends State<EditMaintanceForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  final _ngayBaoTriController = TextEditingController();

  void savePhieuBT(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });

      widget.editPhieuBaoTri.ngayBaoTri =
          vnDateFormat.parse(_ngayBaoTriController.text);

      await dbProcess.updatePhieuBaoTri(widget.editPhieuBaoTri);

      if (mounted) {
        Navigator.of(context).pop('updated');
      }

      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
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
    _ngayBaoTriController.text = widget.editPhieuBaoTri.ngayBaoTri.toVnFormat();
  }

  @override
  void dispose() {
    /* dispose các controller để tránh lãng phí bộ nhớ */
    _ngayBaoTriController.dispose();
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
                      'SỬA THÔNG TIN PHIẾU BẢO TRÌ',
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
                  "Mã Phiếu bảo trì",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.editPhieuBaoTri.maPhieuBaoTri.toString(),
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
                //
                const SizedBox(height: 10),
                LabelTextFieldDatePicker(
                  labelText: 'Ngày bảo trì',
                  controller: _ngayBaoTriController,
                  firstDate: DateTime.now().subYears(2),
                  initialDateInPicker: widget.editPhieuBaoTri.ngayBaoTri,
                  lastDate: DateTime.now().addYears(2),
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
                          onPressed: () => savePhieuBT(context),
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
