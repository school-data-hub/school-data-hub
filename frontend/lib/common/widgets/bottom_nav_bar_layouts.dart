import 'dart:io';

import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';

class BottomNavBarLayout extends StatelessWidget {
  final Widget bottomNavBar;
  const BottomNavBarLayout({required this.bottomNavBar, super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(canvasColor: backgroundColor),
      child: Padding(
        padding: Platform.isWindows
            ? const EdgeInsets.only(left: 5, right: 5, bottom: 20)
            : const EdgeInsets.only(left: 5, right: 5, bottom: 10),
        child: SizedBox(
          height: kBottomNavigationBarHeight + 10,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: bottomNavBar),
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavBarProfileLayout extends StatelessWidget {
  final Widget bottomNavBar;
  const BottomNavBarProfileLayout({required this.bottomNavBar, super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(canvasColor: backgroundColor),
      child: Padding(
        padding: Platform.isWindows
            ? const EdgeInsets.only(left: 5, right: 5, bottom: 20)
            : const EdgeInsets.only(left: 5, right: 5, bottom: 10),
        child: SizedBox(
          height: kBottomNavigationBarHeight + 10,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  child: bottomNavBar),
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavBarMobile extends StatelessWidget {
  final Widget bottomNavBar;
  const BottomNavBarMobile({required this.bottomNavBar, super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(canvasColor: backgroundColor),
      child: bottomNavBar,
    );
  }
}
