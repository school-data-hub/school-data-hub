import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/features/logs/logs_repository.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  final logsApiService = LogsApiService();
  String logs = "Bitte warten";
  @override
  void initState() {
    super.initState();
    setState(() {
      logs = "Bitte warten";
    });
    getLogs();
  }

  Future<void> getLogs() async {
    final result = await logsApiService.downloadLog();
    if (result != null) {
      setState(() {
        logs = result;
      });
    }
  }

  Future<void> resetLogs() async {
    final result = await logsApiService.resetLog();
    if (result != null) {
      setState(() {
        logs = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Logs', style: AppStyles.appBarTextStyle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(logs.isEmpty ? 'Keine Logs!' : logs),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
