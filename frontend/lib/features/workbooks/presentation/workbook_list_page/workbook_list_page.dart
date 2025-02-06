import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/filters/filters_state_manager.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/features/pupil/presentation/widgets/pupil_search_text_field.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/workbooks/domain/models/workbook.dart';
import 'package:schuldaten_hub/features/workbooks/domain/workbook_manager.dart';
import 'package:schuldaten_hub/features/workbooks/presentation/workbook_list_page/controller/workbook_list_view_model.dart';
import 'package:schuldaten_hub/features/workbooks/presentation/workbook_list_page/widgets/workbook_card.dart';
import 'package:schuldaten_hub/features/workbooks/presentation/workbook_list_page/widgets/workbook_list_bottom_navbar.dart';
import 'package:watch_it/watch_it.dart';

class WorkbookListPage extends WatchingWidget {
  final WorkbookListViewModel viewModel;
  const WorkbookListPage(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    bool filtersOn = watchValue((FiltersStateManager x) => x.filtersActive);

    //Session session = watchValue((SessionManager x) => x.credentials);
    List<Workbook> workbooks = watchValue((WorkbookManager x) => x.workbooks);

    return Scaffold(
      backgroundColor: AppColors.canvasColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_rounded,
              size: 25,
              color: Colors.white,
            ),
            Gap(10),
            Text(
              'Arbeitshefte',
              style: AppStyles.appBarTextStyle,
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => locator<WorkbookManager>().getWorkbooks(),
        child: workbooks.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Text(
                    'Es wurden noch keine Arbeitshefte angelegt!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, top: 15.0, right: 10.00),
                        child: Row(
                          children: [
                            const Text(
                              'Gesamt:',
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                            const Gap(10),
                            Text(
                              workbooks.length.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: PupilSearchTextField(
                                  searchType: SearchType.workbook,
                                  hintText: 'Arbeitsheft suchen',
                                  refreshFunction:
                                      locator<WorkbookManager>().getWorkbooks),
                            ),
                            //---------------------------------
                            InkWell(
                              onTap: () {},

                              onLongPress: () =>
                                  locator<PupilsFilter>().resetFilters(),
                              // onPressed: () => showBottomSheetFilters(context),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Icon(
                                  Icons.filter_list,
                                  color: filtersOn
                                      ? Colors.deepOrange
                                      : Colors.grey,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      workbooks.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Keine Ergebnisse',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                itemCount: workbooks.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return WorkbookCard(
                                      workbook: workbooks[index]);
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: workbookListBottomNavBar(context),
    );
  }
}
