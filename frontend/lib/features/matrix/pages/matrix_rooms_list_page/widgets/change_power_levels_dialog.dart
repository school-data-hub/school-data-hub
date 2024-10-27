import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';

Future<int?> changePowerLevelsDialog(BuildContext context) async {
  int credit = 0;
  return await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    credit > 0 ? '+$credit' : credit.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: credit < 0
                            ? Colors.red
                            : credit > 0
                                ? Colors.green
                                : Colors.black),
                  ),
                ),
              ],
            ),
            title: const Text(
              'Guthaben ändern',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: ElevatedButton(
                        style: cancelButtonStyle,
                        onPressed: () {
                          setState(() {
                            credit--;
                          });
                        },
                        child: const Text(
                          "-1",
                          style: buttonTextStyle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: ElevatedButton(
                        style: successButtonStyle,
                        onPressed: () {
                          setState(() {
                            credit++;
                          });
                        },
                        child: const Text(
                          "+1",
                          style: buttonTextStyle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: ElevatedButton(
                        style: cancelButtonStyle,
                        onPressed: () {
                          setState(() {
                            credit = credit - 10;
                          });
                        },
                        child: const Text(
                          "-10",
                          style: buttonTextStyle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: ElevatedButton(
                        style: successButtonStyle,
                        onPressed: () {
                          setState(() {
                            credit = credit + 10;
                          });
                        },
                        child: const Text(
                          "+10",
                          style: buttonTextStyle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: ElevatedButton(
                  style: actionButtonStyle,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "ABBRECHEN",
                    style: buttonTextStyle,
                  ),
                ),
              ),
              ElevatedButton(
                style: successButtonStyle,
                onPressed: () {
                  Navigator.of(context).pop(credit);
                },
                child: const Text(
                  "SENDEN",
                  style: buttonTextStyle,
                ),
              ),
            ],
          );
        });
      });
}
