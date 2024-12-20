import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/theme/colors.dart';
import 'package:watch_it/watch_it.dart';

class LoadingPage extends WatchingStatefulWidget {
  const LoadingPage({super.key});

  @override
  LoadingPageState createState() => LoadingPageState();
}

class LoadingPageState extends State<LoadingPage> {
  String actualNotificationMessage = "";
  String lastNotificationMessage = "";
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final NotificationData snackBarData =
        watchValue((NotificationService x) => x.notification);
    String newValue = snackBarData.message;

    if (newValue != actualNotificationMessage) {
      lastNotificationMessage = actualNotificationMessage;
      actualNotificationMessage = newValue;
    }

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: AppColors.backgroundColor,
        ),
        child: Center(
          child: SizedBox(
            height: 520,
            width: 600,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 300,
                  width: 300,
                  child: Image(
                    image: AssetImage('assets/foreground.png'),
                  ),
                ),
                Text(
                  locale.schoolDataHub,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                const Gap(15),
                if (locator<EnvManager>().env.value.server != null)
                  Text(
                    locator<EnvManager>().env.value.server!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                const Spacer(),
                Text(lastNotificationMessage,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const Gap(5),
                Text(actualNotificationMessage,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const Gap(30),
                const CircularProgressIndicator(
                  color: Colors.white,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
