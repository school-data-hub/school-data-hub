import 'dart:io';

import 'package:pdf/widgets.dart' as pw;
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';

//- TODO: implement pdf generation

final pupilManager = locator<PupilManager>();
Future generatePdf(int pupilId) async {
  final pdf = pw.Document();
  final pupil = pupilManager.getPupilById(pupilId)!;
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Column(children: [
        pw.Row(children: [
          pw.Text(pupil.firstName),
        ])
      ]),
    ),
  );

  final file = File('Förderplan_${pupil.firstName}.pdf');
  await file.writeAsBytes(await pdf.save());
}
