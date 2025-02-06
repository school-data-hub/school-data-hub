import 'dart:io';

import 'package:pdf/widgets.dart' as pw;
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';

List<String> generateBookIds({required int startAtIdNr, required int count}) {
  List<String> bookIds = [];
  for (int index = startAtIdNr; index <= count + startAtIdNr; index++) {
    String bookId = 'Buch ID: ${index.toString().padLeft(5, '0')}';
    bookIds.add(bookId);
  }
  return bookIds;
}

pw.Widget buildBarcodePage(List<String> bookIds, int startIndex) {
  return pw.Column(
    children: List.generate(9, (rowIndex) {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (colIndex) {
          int index = startIndex + rowIndex * 6 + colIndex;
          if (index < bookIds.length) {
            return pw.Column(
              children: [
                pw.Text(bookIds[index],
                    style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 3),
                pw.BarcodeWidget(
                  data: bookIds[index],
                  width: 60,
                  height: 60,
                  barcode: pw.Barcode.qrCode(),
                ),
                pw.SizedBox(height: 12),
              ],
            );
          } else {
            return pw.SizedBox(width: 70);
          }
        }),
      );
    }),
  );
}

void generateBookIdsPdf() async {
  locator<NotificationService>().setHeavyLoadingValue(true);
  final pdf = pw.Document();
  List<String> bookIds = generateBookIds(startAtIdNr: 1, count: 5000);

  int itemsPerPage = 9 * 6;
  int totalPages = (bookIds.length / itemsPerPage).ceil();

  for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
    int startIndex = pageIndex * itemsPerPage;
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.only(top: 30, left: 15, right: 15),
        build: (context) => buildBarcodePage(bookIds, startIndex),
      ),
    );
  }

  final file = File("book_ids_qr.pdf");
  await file.writeAsBytes(await pdf.save());
  locator<NotificationService>().setHeavyLoadingValue(false);
}
