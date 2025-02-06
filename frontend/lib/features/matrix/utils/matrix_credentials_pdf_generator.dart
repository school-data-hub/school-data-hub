import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/utils/custom_encrypter.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/common/widgets/list_view_components/generic_app_bar.dart';
import 'package:schuldaten_hub/features/matrix/domain/models/matrix_user.dart';

Future<File> printMatrixCredentials(
    {required String matrixDomain,
    required MatrixUser matrixUser,
    required String password,
    required bool isStaff}) async {
  final data = await rootBundle.load('assets/hermannpost_button.png');
  final imageBytes = data.buffer.asUint8List();
  final image = pw.MemoryImage(imageBytes);
  final pdf = pw.Document();
  final String matrixId =
      matrixUser.id!.replaceAll("@", "").replaceAll(":hermannschule.de", "");
  String qrPassword = password.substring(0, password.length - 4);
  String pin = password.substring(password.length - 4);
  final String domain =
      matrixDomain.replaceAll("https://", "").replaceAll("/", "");
  final String qrCodeData = "$matrixId:$domain*$qrPassword";
  logger.i('QR Code Data: $qrCodeData');
  final String encryptedQrCodeData = customEncrypter.encryptString(qrCodeData);
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Center(
        child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
          pw.Expanded(
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Image(image, width: 40, height: 40),
                      // pw.SizedBox(width: 10),
                      pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Text('Hermannpost',
                                style: pw.TextStyle(
                                    fontSize: 20,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text('Zugangsdaten - gut aufbewahren!',
                                style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold)),
                          ])
                    ]),
                pw.SizedBox(height: 5),
                pw.Text(matrixUser.displayName,
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.BarcodeWidget(
                        data: encryptedQrCodeData,
                        width: 60,
                        height: 60,
                        barcode: pw.Barcode.qrCode(),
                        drawText: false,
                      ),
                      pw.SizedBox(width: 10),
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                          children: [
                            pw.Text('PIN: $pin',
                                style: pw.TextStyle(
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(
                              height: 32,
                            ),
                            pw.Text(
                                'Erstellt am ${DateTime.now().formatForUser()}',
                                style: const pw.TextStyle(
                                  fontSize: 9,
                                )),
                          ]),
                    ]),
                if (isStaff) ...[
                  pw.SizedBox(height: 10),
                  pw.Row(children: [
                    pw.Text(
                      'Passwort:',
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Text(
                      password,
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ]),
                ]
              ])),
          pw.Expanded(child: pw.Column(children: [])),
        ]),
      ),
    ),
  );

  final file = File("HP_credentials_${matrixUser.displayName}.pdf");
  await file.writeAsBytes(await pdf.save());
  return file;
}

class PdfViewPage extends StatelessWidget {
  final File pdfFile;
  const PdfViewPage({required this.pdfFile, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GenericAppBar(
          iconData: Icons.print_rounded, title: 'Pdf Vorschau'),
      // AppBar(
      //   foregroundColor: Colors.white,
      //   backgroundColor: AppColors.backgroundColor,
      //   title: const Text('PDF Vorschau',
      //       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      // ),
      body: PdfPreview(
        actionBarTheme: const PdfActionBarTheme(
          backgroundColor: AppColors.backgroundColor,
          iconColor: Colors.white,
          textStyle: TextStyle(color: Colors.white),
        ),
        allowSharing: false,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        // actions: [Icon(Icons.download)],
        onPrinted: (context) {
          pdfFile.delete();
          if (context.mounted) {
            Navigator.of(context).pop();
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        },
        build: (format) => pdfFile.readAsBytes(),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              pdfFile.delete();
              if (context.mounted) {
                Navigator.of(context).pop();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          )
        ],
      ),
    );
  }
}
