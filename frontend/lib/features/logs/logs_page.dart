import 'package:flutter/material.dart';
import 'package:schuldaten_hub/features/logs/logs_repository.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
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
    final result = await LogsRepository().downloadLog();
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
        backgroundColor: Colors.blue,
        title: const Text(
          'Logs',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            child: Text(logs!),
          ),
        ],
      ),
    );
  }
}
