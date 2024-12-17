import 'package:flutter/material.dart';

List<DropdownMenuItem<int>> competenceCheckDropdownItems = [
  const DropdownMenuItem(
      value: 0, child: Icon(Icons.question_mark_rounded, color: Colors.black)),
  DropdownMenuItem(
    value: 1,
    child: Image.asset('assets/growth_1-4.png'),
  ),
  DropdownMenuItem(
    value: 2,
    child: Image.asset('assets/growth_2-4.png'),
  ),
  DropdownMenuItem(
    value: 3,
    child: Image.asset('assets/growth_3-4.png'),
  ),
  DropdownMenuItem(
    value: 4,
    child: Image.asset('assets/growth_4-4.png'),
  ),
];
