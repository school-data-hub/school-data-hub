import 'package:flutter/material.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await onInitialize();
    } finally {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> onInitialize();

  @override
  void dispose() {
    super.dispose();
  }

  bool get isInitialized => _isInitialized;
}
