import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/widgets/bottom_nav_bar_layouts.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/short_textfield_dialog.dart';
import 'package:schuldaten_hub/common/widgets/filter_button.dart';
import 'package:schuldaten_hub/common/widgets/generic_filter_bottom_sheet.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';
import 'package:schuldaten_hub/features/pupil/presentation/select_pupils_list_page/select_pupils_list_page.dart';
import 'package:schuldaten_hub/features/pupil/presentation/widgets/common_pupil_filters.dart';
import 'package:schuldaten_hub/features/school_lists/domain/school_list_manager.dart';
import 'package:schuldaten_hub/features/school_lists/presentation/school_list_pupils_page/widgets/school_list_pupil_filters_widget.dart';

class SchoolListPupilsPageBottomNavBar extends StatelessWidget {
  final String listId;

  final List<int> pupilsInList;
  const SchoolListPupilsPageBottomNavBar(
      {required this.listId, required this.pupilsInList, super.key});

  @override
  Widget build(BuildContext context) {
    final schoolList = locator<SchoolListManager>().getSchoolListById(listId);
    return BottomNavBarLayout(
      bottomNavBar: BottomAppBar(
        height: 60,
        padding: const EdgeInsets.all(9),
        shape: null,
        color: AppColors.backgroundColor,
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            children: <Widget>[
              const Spacer(),
              IconButton(
                tooltip: 'zurück',
                icon: const Icon(
                  Icons.arrow_back,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              if (schoolList.visibility != 'public' ||
                  locator<SessionManager>().credentials.value.username ==
                      schoolList.createdBy)
                Row(
                  children: [
                    const Gap(30),
                    IconButton(
                        tooltip: 'Liste teilen',
                        onPressed: () async {
                          final String? visibility = await shortTextfieldDialog(
                              context: context,
                              title: 'Liste teilen mit...',
                              labelText: 'Kürzel eingeben',
                              hintText: 'Kürzel eingeben',
                              obscureText: false);
                          if (visibility != null) {
                            locator<SchoolListManager>()
                                .updateSchoolListProperty(
                                    listId, null, null, visibility);
                          }
                        },
                        icon: const Icon(
                          Icons.share,
                          size: 30,
                        )),
                  ],
                ),
              const Gap(30),
              IconButton(
                tooltip: 'Kinder hinzufügen',
                icon: const Icon(
                  Icons.add,
                  size: 30,
                ),
                onPressed: () async {
                  final List<int> selectedPupilIds =
                      await Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => SelectPupilsListPage(
                                selectablePupils: locator<PupilManager>()
                                    .pupilsNotListed(pupilsInList)),
                          )) ??
                          [];
                  if (selectedPupilIds.isNotEmpty) {
                    locator<SchoolListManager>().addPupilsToSchoolList(
                      listId,
                      selectedPupilIds,
                    );
                  }
                },
              ),
              const Gap(30),
              FilterButton(
                  isSearchBar: false,
                  showBottomSheetFunction: () => showGenericFilterBottomSheet(
                        context: context,
                        filterList: [
                          const CommonPupilFiltersWidget(),
                          const SchoolListPupilFiltersWidget(),
                        ],
                      )),
              const Gap(15)
            ],
          ),
        ),
      ),
    );
  }
}
