import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class XuatPhieuThueSwitch extends StatefulWidget {
  const XuatPhieuThueSwitch({
    super.key,
    required this.onSwitchChanged,
  });

  final void Function(bool) onSwitchChanged;

  @override
  State<XuatPhieuThueSwitch> createState() => _XuatPhieuThueSwitchState();
}

class _XuatPhieuThueSwitchState extends State<XuatPhieuThueSwitch> {
  bool _isInPhieuMuon = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Xuất file Phiếu mượn',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(30),
        Switch(
          value: _isInPhieuMuon,
          onChanged: (value) {
            setState(() => _isInPhieuMuon = value);
            widget.onSwitchChanged(value);
          },
        ),
      ],
    );
  }
}
