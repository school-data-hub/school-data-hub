import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';

class NewSchoolSemesterPage extends StatefulWidget {
  const NewSchoolSemesterPage({super.key});

  @override
  State<NewSchoolSemesterPage> createState() => _NewSchoolSemesterPageState();
}

class _NewSchoolSemesterPageState extends State<NewSchoolSemesterPage> {
  DateTime? startDate;
  DateTime? endDate;
  DateTime? classConferenceDate;
  DateTime? reportConferenceDate;
  bool isFirst = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_view_month_rounded,
                size: 25, color: Colors.white),
            Gap(10),
            Text(
              'Neuer Schulsemester',
              style: AppStyles.appBarTextStyle,
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 10.0, top: 15.0, right: 10.00),
                child: Row(
                  children: [
                    const Text(
                      'Startdatum:',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    const Gap(10),
                    Text(
                      startDate != null
                          ? startDate.toString()
                          : 'Bitte auswählen',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 10.0, top: 15.0, right: 10.00),
                child: Row(
                  children: [
                    const Text(
                      'Enddatum:',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    const Gap(10),
                    Text(
                      endDate != null ? endDate.toString() : 'Bitte auswählen',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 10.0, top: 15.0, right: 10.00),
                child: Row(
                  children: [
                    const Text(
                      'Förderkonferenzdatum:',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    const Gap(10),
                    Text(
                      'Förderkonferendatum Platzhalter',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: const SchoolListsBottomNavBar(),
    );
  }
}
