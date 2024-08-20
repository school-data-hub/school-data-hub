import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/pages/select_pupils_list_page/widgets/select_pupils_filter_bottom_sheet.dart';

class SelectPupilsPageBottomNavBar extends StatelessWidget {
  final bool filtersOn;
  final bool isSelectMode;
  final bool isSelectAllMode;
  final List<int> selectedPupilIds;
  final Function cancelSelect;
  final Function toggleSelectAll;
  const SelectPupilsPageBottomNavBar(
      {required this.filtersOn,
      required this.isSelectMode,
      required this.isSelectAllMode,
      required this.selectedPupilIds,
      required this.cancelSelect,
      required this.toggleSelectAll,
      super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      padding: const EdgeInsets.all(9),
      shape: null,
      color: backgroundColor,
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Row(
            children: [
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
              const Gap(30),
              isSelectMode
                  ? IconButton(
                      onPressed: () {
                        cancelSelect();
                      },
                      icon: const Icon(Icons.close))
                  : const SizedBox.shrink(),
              IconButton(
                tooltip: 'alle auswählen',
                icon: Icon(
                  Icons.select_all_rounded,
                  color: isSelectAllMode ? Colors.deepOrange : Colors.white,
                  size: 30,
                ),
                onPressed: () => toggleSelectAll(),
              ),
              IconButton(
                tooltip: 'Okay',
                icon: Icon(
                  Icons.check,
                  color: isSelectMode ? Colors.green : Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context, selectedPupilIds);
                },
              ),
              InkWell(
                onTap: () => showSelectPupilsFilterBottomSheet(context),
                onLongPress: () => locator<PupilsFilter>().resetFilters(),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.filter_list,
                    color: filtersOn ? Colors.deepOrange : Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const Gap(10)
            ],
          ),
        ),
      ),
    );
  }
}
