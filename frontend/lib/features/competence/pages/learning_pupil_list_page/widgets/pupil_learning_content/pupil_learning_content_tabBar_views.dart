import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/features/competence/pages/learning_pupil_list_page/widgets/pupil_learning_content/pupil_learning_content_competence_goals.dart';
import 'package:schuldaten_hub/features/competence/pages/learning_pupil_list_page/widgets/pupil_learning_content/pupil_learning_content_competence_statuses.dart';
import 'package:schuldaten_hub/features/competence/pages/learning_pupil_list_page/widgets/pupil_learning_content/pupil_learning_content_workbooks.dart';
import 'package:schuldaten_hub/features/pupil/models/pupil_proxy.dart';

class NestedTabBar extends StatefulWidget {
  final PupilProxy pupil;

  const NestedTabBar({required this.pupil, super.key});

  @override
  State<NestedTabBar> createState() => _NestedTabBarState();
}

class _NestedTabBarState extends State<NestedTabBar>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pupil = widget.pupil;
    return Column(
      children: <Widget>[
        TabBar.secondary(
          isScrollable: true,
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              text: 'Lernzziele',
              icon: Icon(Icons.lightbulb),
            ),
            Tab(
              text: 'Kompetenzen',
              icon: Icon(Icons.lightbulb),
            ),
            Tab(
              text: 'Arbeitshefte',
              icon: Icon(Icons.note),
            ),
            Tab(
              text: 'Lesen',
              icon: Icon(Icons.note),
            ),
          ],
        ),
        Flexible(
          fit: FlexFit.loose, // Use FlexFit.loose for Flexible children
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              PupilLearningContentCompetenceGoals(pupil: pupil),
              PupilLearningContentCompetenceStatuses(pupil: pupil),
              PupilLearningContentWorkbooks(pupil: pupil),
            ],
          ),
        ),
      ],
    );
  }
}

class ActionChipExample extends StatefulWidget {
  const ActionChipExample({super.key});

  @override
  State<ActionChipExample> createState() => _ActionChipExampleState();
}

class _ActionChipExampleState extends State<ActionChipExample> {
  bool favorite1 = false;
  bool favorite2 = false;
  bool favorite3 = false;
  bool favorite4 = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ActionChip(
          disabledColor: backgroundColor,
          backgroundColor: accentColor,
          avatar: Icon(favorite1 ? Icons.lightbulb : Icons.favorite_border),
          label: const SizedBox.shrink(),
          onPressed: () {
            setState(() {
              favorite1 = !favorite1;
            });
          },
        ),
        const Gap(10),
        ActionChip(
          disabledColor: backgroundColor,
          backgroundColor: accentColor,
          avatar: Icon(
              favorite2 ? Icons.emoji_nature_rounded : Icons.favorite_border),
          label: const Text('Save to favorites'),
          onPressed: () {
            setState(() {
              favorite2 = !favorite2;
            });
          },
        ),
        const Gap(10),
        ActionChip(
          disabledColor: backgroundColor,
          backgroundColor: accentColor,
          avatar: Icon(favorite3 ? Icons.lightbulb : Icons.favorite_border),
          label: const Text('Save to favorites'),
          onPressed: () {
            setState(() {
              favorite3 = !favorite3;
            });
          },
        ),
        const Gap(10),
        ActionChip(
          disabledColor: backgroundColor,
          backgroundColor: accentColor,
          avatar: Icon(favorite4
              ? Icons.insert_emoticon_rounded
              : Icons.favorite_border),
          label: const Text('Save to favorites'),
          onPressed: () {
            setState(() {
              favorite4 = !favorite4;
            });
          },
        ),
      ],
    );
  }
}

enum Calendar { day, week, month, year }

class SingleChoice extends StatefulWidget {
  const SingleChoice({super.key});

  @override
  State<SingleChoice> createState() => _SingleChoiceState();
}

class _SingleChoiceState extends State<SingleChoice> {
  Calendar calendarView = Calendar.day;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Calendar>(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(backgroundColor),
        foregroundColor: WidgetStateProperty.all(accentColor),
      ),
      segments: const <ButtonSegment<Calendar>>[
        ButtonSegment<Calendar>(
            value: Calendar.day,
            label: Text('Lernziele'),
            icon: Icon(Icons.lightbulb)),
        ButtonSegment<Calendar>(
            value: Calendar.week,
            label: Text('Kompetenzen'),
            icon: Icon(Icons.calendar_view_week)),
        ButtonSegment<Calendar>(
            value: Calendar.month,
            label: Text('Arbeitshefte'),
            icon: Icon(Icons.calendar_view_month)),
        ButtonSegment<Calendar>(
            value: Calendar.year,
            label: Text('Lesen'),
            icon: Icon(Icons.calendar_today)),
      ],
      selected: <Calendar>{calendarView},
      onSelectionChanged: (Set<Calendar> newSelection) {
        setState(() {
          // By default there is only a single segment that can be
          // selected at one time, so its value is always the first
          // item in the selected set.
          calendarView = newSelection.first;
        });
      },
    );
  }
}
