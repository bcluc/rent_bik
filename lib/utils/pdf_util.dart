import 'dart:io';

import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:printing/printing.dart';
import 'package:rent_bik/dto/xe_dto.dart';

class PdfApi {
  static Future<Document> generatePhieuMuon({
    required String ngayMuon,
    required String hanTra,
    required String maDocGia,
    required String hoTen,
    required XeDTO xeDTO,
  }) async {
    final pdf = Document();

    final nunitoRegularFont = await PdfGoogleFonts.nunitoRegular();
    final nunitoBoldFont = await PdfGoogleFonts.nunitoBold();
    final nunitoItalicFont = await PdfGoogleFonts.nunitoItalic();

    final nunitoRegularTextStyle = pw.TextStyle(font: nunitoRegularFont);
    // final nunitoBoldTextStyle = pw.TextStyle(font: nunitoBoldFont);

    final img = await rootBundle.load('assets/logo/textLogo.png');
    final imageBytes = img.buffer.asUint8List();

    final List<List<String>> dataTable = [
      [
        xeDTO.maXe.toString(),
        xeDTO.bienSoXe,
        xeDTO.loaiXe,
        xeDTO.soHanhTrinh.toString()
      ]
    ];
    final headers = [
      'Mã xe',
      'Biển số xe',
      'Loại xe',
      'Số hành trình',
    ];

    pdf.addPage(
      pw.Page(
        /* A4: 21.0 * cm, 29.7 * cm, marginAll: 2.0 * cm */
        pageFormat: const PdfPageFormat(
          21.0 * PdfPageFormat.cm,
          29.7 * PdfPageFormat.cm,
          marginAll: 0,
        ),
        build: (context) {
          return Column(
            children: [
              pw.Container(
                color: PdfColor.fromHex('F9FAFC'),
                padding: const pw.EdgeInsets.all(15 * PdfPageFormat.mm),
                child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        pw.Image(
                          pw.MemoryImage(imageBytes),
                          width: 44,
                        ),
                        pw.SizedBox(width: 7 * PdfPageFormat.mm),
                        pw.Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'RentBik',
                              style: nunitoRegularTextStyle,
                            ),
                            pw.SizedBox(
                              width: 8 * PdfPageFormat.cm,
                              child: pw.Text(
                                'Địa chỉ: 123 Nguyễn Hữu Thọ, Quận 3, TP. HCM',
                                style: nunitoRegularTextStyle,
                              ),
                            ),
                          ],
                        ),
                        pw.Spacer(),
                        pw.Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Email: rentbike@gmail.com',
                              style: nunitoRegularTextStyle,
                            ),
                            pw.Text(
                              'SĐT: 0123456789',
                              style: nunitoRegularTextStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(
                      height: 8 * PdfPageFormat.mm,
                    ),
                    pw.Text(
                      'PHIẾU THUÊ',
                      style: pw.TextStyle(
                        font: nunitoBoldFont,
                        fontSize: 12 * PdfPageFormat.mm,
                      ),
                    ),
                    pw.SizedBox(
                      height: 8 * PdfPageFormat.mm,
                    ),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(
                            'Mã khách hàng: $maDocGia',
                            style: nunitoRegularTextStyle,
                          ),
                        ),
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(
                            'Họ tên: $hoTen',
                            style: nunitoRegularTextStyle,
                          ),
                        ),
                      ],
                    ),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(
                            'Ngày mượn: $ngayMuon',
                            style: nunitoRegularTextStyle,
                          ),
                        ),
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(
                            'Hạn trả: $hanTra',
                            style: nunitoRegularTextStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Container(
                  color: PdfColors.white,
                  padding: const pw.EdgeInsets.all(15 * PdfPageFormat.mm),
                  child: pw.Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      pw.TableHelper.fromTextArray(
                        headers: headers,
                        data: dataTable,
                        border: null,
                        headerStyle: TextStyle(
                          font: nunitoBoldFont,
                        ),
                        headerAlignments: {
                          0: pw.Alignment.centerLeft,
                          1: pw.Alignment.centerLeft,
                          2: pw.Alignment.centerLeft,
                          3: pw.Alignment.centerLeft,
                        },
                        headerDecoration:
                            const pw.BoxDecoration(color: PdfColors.grey300),
                        cellHeight: 30,
                        cellStyle: nunitoRegularTextStyle,
                        cellAlignments: {
                          0: Alignment.centerLeft,
                          1: Alignment.centerLeft,
                          2: Alignment.centerLeft,
                          3: Alignment.centerLeft,
                        },
                        rowDecoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                                width: 1, color: PdfColors.grey200),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 5 * PdfPageFormat.mm),
                      pw.Text(
                        'Vui lòng trả xe đúng hạn.',
                        style: pw.TextStyle(font: nunitoItalicFont),
                      ),
                      pw.Text(
                        'Trong trường hợp vượt quá hạn trả, cửa hàng sẽ thu phí 100/ngày/xe.',
                        style: pw.TextStyle(font: nunitoItalicFont),
                      )
                    ],
                  ),
                ),
              ),
              /* Footer */
              pw.Container(
                color: PdfColor.fromHex('F9FAFC'),
                padding: const pw.EdgeInsets.all(15 * PdfPageFormat.mm),
                child: pw.Row(
                  children: [
                    pw.Text(
                      'RentBik',
                      style: nunitoRegularTextStyle,
                    ),
                    pw.Spacer(),
                    pw.Text(
                      '0123456789',
                      style: nunitoRegularTextStyle,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static Future<File> saveDocument({
    required String name,
    required Document pdfDoc,
  }) async {
    final bytes = await pdfDoc.save();

    final dir = await getApplicationDocumentsDirectory();

    final folderPath = '${dir.path}/ReaderLM Document';

    // Kiểm tra xem thư mục có tồn tại hay không
    if (!await Directory(folderPath).exists()) {
      // Nếu không tồn tại, tạo thư mục
      await Directory(folderPath).create();
    }

    final file = File('${dir.path}/ReaderLM Document/$name.pdf');

    await file.writeAsBytes(bytes);

    return file;
  }

  static Future<void> openFile(File file) async {
    final url = file.path;

    await OpenFile.open(url);
  }
}
