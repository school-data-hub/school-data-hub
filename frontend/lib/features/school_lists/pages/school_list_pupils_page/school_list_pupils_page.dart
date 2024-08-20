// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/generic_app_bar.dart';
import 'package:schuldaten_hub/common/widgets/sliver_search_app_bar.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/school_lists/models/pupil_list.dart';
import 'package:schuldaten_hub/features/school_lists/filters/school_list_filter_manager.dart';

import 'package:schuldaten_hub/features/school_lists/services/school_list_manager.dart';
import 'package:schuldaten_hub/features/school_lists/models/school_list.dart';
import 'package:schuldaten_hub/features/school_lists/pages/school_list_pupils_page/widgets/school_list_pupil_card.dart';
import 'package:schuldaten_hub/features/school_lists/pages/school_list_pupils_page/widgets/school_list_pupils_bottom_navbar.dart';
import 'package:schuldaten_hub/features/school_lists/pages/school_list_pupils_page/widgets/school_list_pupils_searchbar.dart';

import 'package:watch_it/watch_it.dart';

class SchoolListPupilsPage extends WatchingWidget {
  final SchoolList schoolList;

  const SchoolListPupilsPage(this.schoolList, {super.key});

  @override
  Widget build(BuildContext context) {
    final thisSchoolList = watchValue((SchoolListManager x) => x.schoolLists)
        .firstWhere((element) => element.listId == schoolList.listId);

    final List<PupilProxy> filteredPupils =
        watchValue((PupilsFilter x) => x.filteredPupils);

    final List<PupilList> pupilLists = locator<SchoolListFilterManager>()
        .addPupilListFiltersToFilteredPupils(thisSchoolList.pupilLists);

    List<PupilProxy> pupilsInList = filteredPupils
        .where((pupil) => pupilLists
            .any((pupilList) => pupilList.listedPupilId == pupil.internalId))
        .toList();

    return Scaffold(
      backgroundColor: canvasColor,
      appBar: GenericAppBar(iconData: Icons.list, title: schoolList.listName),
      body: RefreshIndicator(
        onRefresh: () async => locator<SchoolListManager>().fetchSchoolLists(),
        child: Padding(
          padding: const EdgeInsets.only(left: 5.0, right: 5),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CustomScrollView(
                slivers: [
                  const SliverGap(10),
                  SliverSearchAppBar(
                    height: 135,
                    title: SchoolListPupilsPageSearchBar(
                      pupilsInList: pupilsInList,
                      schoolList: schoolList,
                    ),
                  ),
                  pupilsInList.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Keine Ergebnisse',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return SchoolListPupilCard(
                                  pupilsInList[index].internalId, schoolList);
                            },
                            childCount: pupilsInList.length,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SchoolListPupilsPageBottomNavBar(
          listId: schoolList.listId,
          pupilsInList:
              locator<PupilManager>().pupilIdsFromPupils(pupilsInList)),
    );
  }
}
