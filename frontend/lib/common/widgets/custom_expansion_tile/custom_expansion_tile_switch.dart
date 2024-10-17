import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile.dart';

class CustomExpansionTileSwitch extends StatefulWidget {
  final Widget? expansionSwitchWidget;
  final CustomExpansionTileController customExpansionTileController;
  const CustomExpansionTileSwitch(
      {this.expansionSwitchWidget,
      required this.customExpansionTileController,
      super.key});

  @override
  CustomExpansionTileSwitchState createState() =>
      CustomExpansionTileSwitchState();
}

class CustomExpansionTileSwitchState extends State<CustomExpansionTileSwitch> {
  late final CustomExpansionTileController _tileController;
  bool isExpanded = false;
  @override
  void initState() {
    _tileController = widget.customExpansionTileController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          if (_tileController.isExpanded) {
            _tileController.collapse();
            setState(() {
              isExpanded = false;
            });
          } else {
            _tileController.expand();
            setState(() {
              isExpanded = true;
            });
          }
        },
        child: widget.expansionSwitchWidget ??
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.white,
            ));
  }
}
