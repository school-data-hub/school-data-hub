import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_content.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expasion_tile_hook.dart';
import 'package:schuldaten_hub/features/competence/presentation/learning_pupil_list_page/widgets/pupil_learning_content/pupil_learning_content_books.dart';
import 'package:schuldaten_hub/features/competence/presentation/learning_pupil_list_page/widgets/pupil_learning_content/pupil_learning_content_competence_goals.dart';
import 'package:schuldaten_hub/features/competence/presentation/learning_pupil_list_page/widgets/pupil_learning_content/pupil_learning_content_competence_statuses.dart';
import 'package:schuldaten_hub/features/competence/presentation/learning_pupil_list_page/widgets/pupil_learning_content/pupil_learning_content_workbooks.dart';
import 'package:schuldaten_hub/features/pupil/domain/models/pupil_proxy.dart';

enum SelectedContent {
  competenceStatuses,
  competenceGoals,
  workbooks,
  books,
  none,
}

class SelectedContentNotifier extends StateNotifier<SelectedContent> {
  SelectedContentNotifier() : super(SelectedContent.none);

  void select(SelectedContent content) {
    state = content;
  }
}

final selectedContentProvider =
    StateNotifierProvider.autoDispose<SelectedContentNotifier, SelectedContent>(
  (ref) => SelectedContentNotifier(),
);

class PupilLearningContentExpansionTileNavBar extends HookConsumerWidget {
  final PupilProxy pupil;

  const PupilLearningContentExpansionTileNavBar(
      {required this.pupil, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedContent = ref.watch(selectedContentProvider);
    final tileController = useCustomExpansionTileController();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              isSelected: selectedContent == SelectedContent.competenceStatuses,
              icon: const Icon(
                Icons.lightbulb,
                color: AppColors.interactiveColor,
              ),
              selectedIcon: const Icon(
                Icons.lightbulb,
                color: AppColors.accentColor,
              ),
              onPressed: () {
                if (selectedContent != SelectedContent.competenceStatuses) {
                  if (tileController.isExpanded) {
                    tileController.collapse();
                    ref
                        .read(selectedContentProvider.notifier)
                        .select(SelectedContent.competenceStatuses);
                    tileController.expand();
                    return;
                  }
                  ref
                      .read(selectedContentProvider.notifier)
                      .select(SelectedContent.competenceStatuses);

                  tileController.expand();
                  return;
                }
                tileController.isExpanded
                    ? tileController.collapse()
                    : tileController.expand();
              },
            ),
            IconButton(
              isSelected: selectedContent == SelectedContent.competenceGoals,
              icon: const Icon(
                Icons.emoji_nature_rounded,
                color: AppColors.interactiveColor,
              ),
              selectedIcon: const Icon(
                Icons.emoji_nature_rounded,
                color: AppColors.accentColor,
              ),
              onPressed: () {
                if (selectedContent != SelectedContent.competenceGoals) {
                  if (tileController.isExpanded) {
                    tileController.collapse();
                    ref
                        .read(selectedContentProvider.notifier)
                        .select(SelectedContent.competenceGoals);
                    tileController.expand();
                    return;
                  }
                  ref
                      .read(selectedContentProvider.notifier)
                      .select(SelectedContent.competenceGoals);

                  tileController.expand();
                  return;
                }
                tileController.isExpanded
                    ? tileController.collapse()
                    : tileController.expand();
              },
            ),
            IconButton(
              isSelected: selectedContent == SelectedContent.workbooks,
              icon: const Icon(
                Icons.note_alt,
                color: AppColors.interactiveColor,
              ),
              selectedIcon: const Icon(
                Icons.note_alt,
                color: AppColors.accentColor,
              ),
              onPressed: () {
                if (selectedContent != SelectedContent.workbooks) {
                  if (tileController.isExpanded) {
                    tileController.collapse();
                    ref
                        .read(selectedContentProvider.notifier)
                        .select(SelectedContent.workbooks);
                    tileController.expand();
                    return;
                  }
                  ref
                      .read(selectedContentProvider.notifier)
                      .select(SelectedContent.workbooks);

                  tileController.expand();
                  return;
                }
                tileController.isExpanded
                    ? tileController.collapse()
                    : tileController.expand();
              },
            ),
            IconButton(
              isSelected: selectedContent == SelectedContent.books,
              icon: const Icon(
                Icons.book,
                color: AppColors.interactiveColor,
              ),
              selectedIcon: const Icon(
                Icons.book,
                color: AppColors.accentColor,
              ),
              onPressed: () {
                if (selectedContent != SelectedContent.books) {
                  if (tileController.isExpanded) {
                    tileController.collapse();
                    ref
                        .read(selectedContentProvider.notifier)
                        .select(SelectedContent.books);
                    tileController.expand();
                    return;
                  }
                  ref
                      .read(selectedContentProvider.notifier)
                      .select(SelectedContent.books);

                  tileController.expand();
                  return;
                }
                tileController.isExpanded
                    ? tileController.collapse()
                    : tileController.expand();
              },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: CustomExpansionTileContent(
              title: null,
              tileController: tileController,
              widgetList: [
                if (selectedContent == SelectedContent.competenceStatuses)
                  PupilLearningContentCompetenceStatuses(pupil: pupil),
                if (selectedContent == SelectedContent.competenceGoals)
                  PupilLearningContentCompetenceGoals(pupil: pupil),
                if (selectedContent == SelectedContent.workbooks)
                  PupilLearningContentWorkbooks(pupil: pupil),
                if (selectedContent == SelectedContent.books)
                  PupilLearningContentBooks(pupil: pupil)
              ]),
        )
      ],
    );
  }
}
