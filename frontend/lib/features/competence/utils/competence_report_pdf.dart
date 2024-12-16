import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:schuldaten_hub/common/domain/models/school_data.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence_report.dart';

Future<pw.Widget> buildFirstPage() async {
  final imageBytes = await loadAssetImage(schoolData.logo);
  final image = pw.MemoryImage(imageBytes);
  return pw.Stack(children: [
    pw.Column(children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(schoolData.name,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))
        ],
      ),
      // pw.SizedBox(height: 2),
      if (schoolData.predicate != null)
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              schoolData.predicate!,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      //   pw.SizedBox(height: 2),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            schoolData.address,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
      //  pw.SizedBox(height: 1),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            'Schulnummer: ${schoolData.schoolNumber}',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    ]),
    pw.Positioned(
      top: 0,
      right: 20,
      child: pw.Image(image, width: 85, height: 85),
    ),
  ]);
}

Future<Uint8List> loadAssetImage(String path) async {
  final ByteData data = await rootBundle.load(path);
  return data.buffer.asUint8List();
}

void generateCompetenceReportPdf(
    {CompetenceReport? competenceReport,
    required ReportLevel reportLevel}) async {
  // final pupil = locator<PupilManager>().findPupilById(competenceReport.pupilId);

  final pdf = pw.Document();
  final firstPage = await buildFirstPage();
  pdf.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.only(top: 25, left: 20, right: 20),
      build: (context) => firstPage,
    ),
  );

  final file = File("competence_report.pdf");
  await file.writeAsBytes(await pdf.save());
}

// ignore: constant_identifier_names
enum ReportLevel { E1, E2, S3, S4 }
