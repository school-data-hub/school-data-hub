import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/api/api_settings.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_data.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';
import 'package:schuldaten_hub/features/workbooks/domain/models/workbook.dart';

class WorkbookManager {
  ValueListenable<List<Workbook>> get workbooks => _workbooks;

  final _workbooks = ValueNotifier<List<Workbook>>([]);

  WorkbookManager();
  final session = locator.get<SessionManager>().credentials.value;

  final apiPupilWorkbookService = PupilWorkbookApiService();

  final apiWorkbookService = WorkbookApiService();

  final notificationService = locator<NotificationService>();

  final pupilManager = locator<PupilManager>();

  Future<WorkbookManager> init() async {
    await getWorkbooks();

    return this;
  }

  void clearData() {
    _workbooks.value = [];
  }

  Future<void> getWorkbooks() async {
    final List<Workbook> responseWorkbooks =
        await apiWorkbookService.getWorkbooks();
    // sort workbooks by name
    responseWorkbooks.sort((a, b) => a.name.compareTo(b.name));
    notificationService.showSnackBar(
        NotificationType.success, 'Arbeitshefte erfolgreich geladen');

    _workbooks.value = responseWorkbooks;

    return;
  }

  Future<void> postWorkbook(
    String name,
    int isbn,
    String subject,
    String level,
    int amount,
  ) async {
    final Workbook responseWorkbook = await apiWorkbookService.postWorkbook(
        name: name, isbn: isbn, subject: subject, level: level, amount: amount);

    _workbooks.value = [..._workbooks.value, responseWorkbook];

    notificationService.showSnackBar(
        NotificationType.success, 'Arbeitsheft erfolgreich erstellt');

    return;
  }

  Future<void> updateWorkbookProperty(name, isbn, subject, level) async {
    final Workbook workbookToUpdate = _workbooks.value.firstWhere(
      (workbook) => workbook.isbn == isbn,
    );

    final Workbook updatedWorkbook =
        await apiWorkbookService.updateWorkbookProperty(
      workbook: workbookToUpdate,
      name: name,
      subject: subject,
      level: level,
    );

    List<Workbook> workbooks = List.from(_workbooks.value);
    int index = workbooks
        .indexWhere((workbook) => workbook.isbn == updatedWorkbook.isbn);

    workbooks[index] = updatedWorkbook;

    _workbooks.value = workbooks;

    notificationService.showSnackBar(
        NotificationType.success, 'Arbeitsheft erfolgreich aktualisiert');

    return;
  }

  Future<void> postWorkbookFile(File imageFile, int isbn) async {
    final Workbook responseWorkbook =
        await apiWorkbookService.postWorkbookFile(imageFile, isbn);

    updateWorkbookInRepositoryWithResponse(responseWorkbook);

    notificationService.showSnackBar(
        NotificationType.success, 'Bild erfolgreich hochgeladen');

    return;
  }

  Future<void> deleteWorkbook(int isbn) async {
    final List<Workbook> workbooks =
        await apiWorkbookService.deleteWorkbook(isbn);

    _workbooks.value = workbooks;

    notificationService.showSnackBar(
        NotificationType.success, 'Arbeitsheft erfolgreich gelöscht');

    //- TODO: delete all pupilWorkbooks with this isbn in memory

    return;
  }

  Future<void> deleteWorkbookFile(int isbn) async {
    final Workbook responseWorkbook =
        await apiWorkbookService.deleteWorkbookFile(isbn);

    updateWorkbookInRepositoryWithResponse(responseWorkbook);

    notificationService.showSnackBar(
        NotificationType.success, 'Bild erfolgreich gelöscht');

    return;
  }
  //- PUPIL WORKBOOKS

  Future<void> newPupilWorkbook(int pupilId, int isbn) async {
    final PupilData responsePupil =
        await apiPupilWorkbookService.postNewPupilWorkbook(pupilId, isbn);

    pupilManager.updatePupilProxyWithPupilData(responsePupil);

    notificationService.showSnackBar(
        NotificationType.success, 'Arbeitsheft erstellt');

    return;
  }

  Future<void> updatePupilWorkbook(
      {required int pupilId,
      required int isbn,
      String? comment,
      int? status,
      String? createdBy,
      DateTime? createdAt,
      DateTime? finishedAt}) async {
    final PupilData responsePupil =
        await apiPupilWorkbookService.patchPupilWorkbook(
            pupilId: pupilId,
            isbn: isbn,
            comment: comment,
            status: status,
            createdBy: createdBy,
            createdAt: createdAt,
            finishedAt: finishedAt);

    pupilManager.updatePupilProxyWithPupilData(responsePupil);

    notificationService.showSnackBar(
        NotificationType.success, 'Arbeitsheft aktualisiert');

    return;
  }

  Future<void> deletePupilWorkbook(int pupilId, int isbn) async {
    final PupilData responsePupil =
        await apiPupilWorkbookService.deletePupilWorkbook(pupilId, isbn);

    pupilManager.updatePupilProxyWithPupilData(responsePupil);

    notificationService.showSnackBar(
        NotificationType.success, 'Arbeitsheft gelöscht');

    return;
  }

  //- helper function
  Workbook? getWorkbookByIsbn(int? isbn) {
    if (isbn == null) return null;
    final Workbook? workbook =
        _workbooks.value.firstWhereOrNull((element) => element.isbn == isbn);
    return workbook;
  }

  //- helper function
  void updateWorkbookInRepositoryWithResponse(Workbook workbook) {
    List<Workbook> workbooks = List.from(_workbooks.value);
    int index = workbooks.indexWhere((wb) => wb.isbn == workbook.isbn);
    workbooks[index] = workbook;
    _workbooks.value = workbooks;
  }
}
