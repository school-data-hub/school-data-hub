import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/session_manager.dart';
import 'package:schuldaten_hub/common/widgets/generic_app_bar.dart';
import 'package:schuldaten_hub/common/widgets/generic_sliver_list.dart';
import 'package:schuldaten_hub/common/widgets/sliver_search_app_bar.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';

import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';
import 'package:schuldaten_hub/features/credit/credit_list_page/widgets/credit_list_card.dart';
import 'package:schuldaten_hub/features/credit/credit_list_page/widgets/credit_list_searchbar.dart';
import 'package:schuldaten_hub/features/credit/credit_list_page/widgets/credit_list_page_bottom_navbar.dart';
import 'package:schuldaten_hub/features/school_lists/filters/school_list_filter_manager.dart';

import 'package:watch_it/watch_it.dart';

import '../../../common/services/base_state.dart';

class CreditListPage extends WatchingStatefulWidget {
  const CreditListPage({super.key});

  @override
  State<CreditListPage> createState() => _CreditListPageState();
}

class _CreditListPageState extends BaseState<CreditListPage> {
  @override
  Future<void> onInitialize() async {
    await locator.isReady<PupilsFilter>();
    await locator.isReady<SchoolListFilterManager>();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Scaffold(
        backgroundColor: canvasColor,
        appBar: GenericAppBar(iconData: Icons.credit_card, title: 'Guthaben:'),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    bool filtersOn = watchValue((PupilsFilter x) => x.filtersOn);
    List<PupilProxy> pupils = watchValue((PupilsFilter x) => x.filteredPupils);
    int userCredit = watchValue((SessionManager x) => x.credentials).credit!;
    // final List<PupilProxy> nonFilteredPupils =
    //     watch(di<PupilManager>()).allPupils;

    return Scaffold(
      backgroundColor: canvasColor,
      appBar: GenericAppBar(
          iconData: Icons.credit_card, title: 'Guthaben: $userCredit'),
      body: RefreshIndicator(
        onRefresh: () async => locator<PupilManager>().fetchAllPupils(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: CustomScrollView(
              slivers: [
                const SliverGap(5),
                SliverSearchAppBar(
                  height: 110,
                  title:
                      CreditListSearchBar(pupils: pupils, filtersOn: filtersOn),
                ),
                GenericSliverListWithEmptyListCheck(
                    items: pupils,
                    itemBuilder: (_, pupil) => CreditListCard(pupil)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: creditListViewBottomNavBar(context, filtersOn),
    );
  }
}
