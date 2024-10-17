import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/utils/custom_expasion_tile_hook.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_content.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile_switch.dart';

class CompetenceCard extends HookWidget {
  final Color backgroundColor;
  final Widget title;
  final Widget competenceStatus;
  final List<Widget> children;

  const CompetenceCard({
    super.key,
    required this.backgroundColor,
    required this.title,
    required this.competenceStatus,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useCustomExpansionTileController();
    return Card(
      color: backgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Row(children: [
            const Gap(10),
            title,
            CustomExpansionTileSwitch(
              customExpansionTileController: controller,
              expansionSwitchWidget:
                  const Icon(Icons.arrow_drop_down, color: Colors.white),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: InkWell(
                onLongPress: () {},
                child: competenceStatus,
              ),
            ),
            const Gap(10),
          ]),
          CustomExpansionTileContent(
            tileController: controller,
            widgetList: children,
          ),
        ],
      ),
    );
  }
}
