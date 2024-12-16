import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/workbooks/domain/workbook_manager.dart';
import 'package:schuldaten_hub/features/workbooks/presentation/workbook_list_page/workbook_list_page.dart';

class WorkbookList extends StatefulWidget {
  const WorkbookList({
    super.key,
  });

  @override
  WorkbookListViewModel createState() => WorkbookListViewModel();
}

class WorkbookListViewModel extends State<WorkbookList> {
  @override
  void initState() {
    locator<WorkbookManager>().getWorkbooks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WorkbookListPage(this);
  }
}
