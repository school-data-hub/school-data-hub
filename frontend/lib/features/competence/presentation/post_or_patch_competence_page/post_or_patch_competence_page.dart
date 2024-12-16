import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/widgets/generic_app_bar.dart';
import 'package:schuldaten_hub/common/widgets/themed_filter_chip.dart';
import 'package:schuldaten_hub/features/competence/domain/models/competence.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_manager.dart';

class PostOrPatchCompetencePage extends StatefulWidget {
  final int? parentCompetence;
  final Competence? competence;

  const PostOrPatchCompetencePage(
      {super.key, this.competence, this.parentCompetence});

  @override
  PostOrPatchCompetencePageState createState() =>
      PostOrPatchCompetencePageState();
}

class PostOrPatchCompetencePageState extends State<PostOrPatchCompetencePage> {
  late String competenceLevel;
  final TextEditingController nameFieldController = TextEditingController();

  final TextEditingController indicatorsFieldController =
      TextEditingController();
  void postNewCompetence() async {
    Navigator.pop(context);

    await locator<CompetenceManager>().postNewCompetence(
        parentCompetence: widget.parentCompetence,
        competenceLevel: competenceLevel,
        competenceName: nameFieldController.text,
        indicators: indicatorsFieldController.text);
  }

  void patchCompetence() async {
    String competenceName = nameFieldController.text;
    String newCompetenceLevel = competenceLevel;
    String text3 = indicatorsFieldController.text;
    await locator<CompetenceManager>().updateCompetenceProperty(
        competenceId: widget.competence!.competenceId,
        competenceName: competenceName,
        competenceLevel: newCompetenceLevel,
        indicators: text3);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  bool competenceLevelContainsGrade(String grade) {
    return competenceLevel.contains(grade);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      competenceLevel =
          widget.competence != null ? widget.competence!.competenceLevel! : '';
      nameFieldController.text =
          widget.competence != null ? widget.competence!.competenceName : '';
      indicatorsFieldController.text =
          widget.competence != null ? widget.competence!.indicators ?? '' : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    bool gradeE1 = competenceLevelContainsGrade('E1');
    bool gradeE2 = competenceLevelContainsGrade('E2');
    bool gradeS3 = competenceLevelContainsGrade('S3');
    bool gradeS4 = competenceLevelContainsGrade('S4');

    return Scaffold(
      appBar: GenericAppBar(
          iconData: Icons.edit_document,
          title: widget.competence != null
              ? 'Kompetenz überarbeiten'
              : 'Neue Kompetenz'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (widget.parentCompetence != null)
                  Text(
                    'Übergeordnete Kompetenz: ${locator<CompetenceManager>().getCompetence(widget.parentCompetence!).competenceName}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                const Text(
                  'Kompetenz',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Gap(10),
                TextField(
                  minLines: 1,
                  maxLines: 2,
                  controller: nameFieldController,
                  decoration: AppStyles.textFieldDecoration(
                      labelText: 'Name der Kompetenz'),
                ),
                const Gap(10),
                const Text(
                  'Kompetenzstufe',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ThemedFilterChip(
                        label: 'E1',
                        selected: gradeE1,
                        onSelected: (value) {
                          if (value) {
                            setState(() {
                              competenceLevel = '${competenceLevel}E1';
                              gradeE1 = true;
                            });
                          } else {
                            setState(() {
                              competenceLevel =
                                  competenceLevel.replaceAll('E1', '');
                              gradeE1 = false;
                            });
                          }
                        }),
                    ThemedFilterChip(
                        label: 'E2',
                        selected: gradeE2,
                        onSelected: (value) {
                          if (value) {
                            setState(() {
                              competenceLevel = '${competenceLevel}E2';
                              gradeE2 = true;
                            });
                          } else {
                            setState(() {
                              competenceLevel =
                                  competenceLevel.replaceAll('E2', '');
                              gradeE2 = false;
                            });
                          }
                        }),
                    ThemedFilterChip(
                        label: 'S3',
                        selected: gradeS3,
                        onSelected: (value) {
                          if (value) {
                            setState(() {
                              competenceLevel = '${competenceLevel}S3';
                              gradeS3 = true;
                            });
                          } else {
                            setState(() {
                              competenceLevel =
                                  competenceLevel.replaceAll('S3', '');
                              gradeS3 = false;
                            });
                          }
                        }),
                    ThemedFilterChip(
                        label: 'S4',
                        selected: gradeS4,
                        onSelected: (value) {
                          if (value) {
                            setState(() {
                              competenceLevel = '${competenceLevel}S4';
                              gradeS4 = true;
                            });
                          } else {
                            setState(() {
                              competenceLevel =
                                  competenceLevel.replaceAll('S4', '');
                              gradeS4 = false;
                            });
                          }
                        }),
                  ],
                ),
                const Gap(20),
                TextField(
                  minLines: 2,
                  maxLines: 3,
                  controller: indicatorsFieldController,
                  decoration: AppStyles.textFieldDecoration(
                    labelText: 'Indikatoren',
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 47, 202, 76),
                      minimumSize: const Size.fromHeight(60)),
                  onPressed: () {
                    widget.competence == null
                        ? postNewCompetence()
                        : patchCompetence();
                  },
                  child: const Text(
                    'SENDEN',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Gap(15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 235, 67, 67),
                      minimumSize: const Size.fromHeight(60)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'ABBRECHEN',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the tree
    nameFieldController.dispose();

    super.dispose();
  }
}
