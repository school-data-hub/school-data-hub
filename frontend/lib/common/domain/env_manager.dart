import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:schuldaten_hub/common/domain/models/enums.dart';
import 'package:schuldaten_hub/common/domain/models/env.dart';
import 'package:schuldaten_hub/common/domain/session_helper_functions.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/common/utils/secure_storage.dart';
import 'package:schuldaten_hub/features/authorizations/domain/authorization_manager.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_manager.dart';
import 'package:schuldaten_hub/features/learning_support/domain/learning_support_manager.dart';
import 'package:schuldaten_hub/features/main_menu/widgets/landing_bottom_nav_bar.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_identity_manager.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';
import 'package:schuldaten_hub/features/school_lists/domain/school_list_manager.dart';
import 'package:schuldaten_hub/features/schooldays/domain/schoolday_manager.dart';
import 'package:schuldaten_hub/features/users/domain/user_manager.dart';
import 'package:schuldaten_hub/features/workbooks/domain/workbook_manager.dart';

class EnvManager {
  final _dependentMangagersRegistered = ValueNotifier<bool>(false);
  ValueListenable<bool> get dependentManagersRegistered =>
      _dependentMangagersRegistered;

  Env? _activeEnv;

  Env? get env => _activeEnv;

  Map<String, Env> _environments = {};
  Map<String, Env> get envs => _environments;

  String _defaultEnv = '';
  String get defaultEnv => _defaultEnv;

  final _envReady = ValueNotifier<bool>(false);
  ValueListenable<bool> get envReady => _envReady;

  final _packageInfo = ValueNotifier<PackageInfo>(PackageInfo(
    appName: '',
    packageName: '',
    version: '',
    buildNumber: '',
    buildSignature: '',
  ));

  ValueListenable<PackageInfo> get packageInfo => _packageInfo;

  Future<EnvManager> init() async {
    await firstRun();
    return this;
  }

  void setDependentManagersRegistered(bool value) {
    _dependentMangagersRegistered.value = value;
    log('message: dependentManagersRegistered: $value');
  }

  Future<void> firstRun() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _packageInfo.value = packageInfo;

    final EnvsInStorage? environmentsObject = await environmentsInStorage();

    if (environmentsObject == null) {
      _envReady.value = false;
      return;
    }

    _defaultEnv = environmentsObject.defalutEnv;

    _environments = environmentsObject.environmentsMap;

    _activeEnv = environmentsObject.environmentsMap[_defaultEnv];

    log('Default Environment: $_defaultEnv');

    // set the base url for the api client

    // locator<ApiClient>().setBaseUrl(_activeEnv!.serverUrl);

    _envReady.value = true;

    return;
  }

  Future<EnvsInStorage?> environmentsInStorage() async {
    bool environmentsInStorage =
        await AppSecureStorage.containsKey(SecureStorageKey.environments.value);

    if (environmentsInStorage == true) {
      final String? storedEnvironmentsAsString =
          await AppSecureStorage.read(SecureStorageKey.environments.value);

      try {
        final environmentsInStorage = EnvsInStorage.fromJson(
            json.decode(storedEnvironmentsAsString!) as Map<String, dynamic>);

        return environmentsInStorage;
      } catch (e) {
        logger.f('Error reading env from secureStorage: $e',
            stackTrace: StackTrace.current);

        log('deleting faulty environments from secure storage');

        await AppSecureStorage.delete(SecureStorageKey.environments.value);

        return null;
      }
    }

    // //- TODO: remove this after all users have migrated to the new env storage

    // bool legacyEnvironmentInStorage = await AppSecureStorage.containsKey(SecureStorageKey.environments'env');

    // if (legacyEnvironmentInStorage == true) {
    //   final String? storedEnvironmentAsString = await secureStorageRead('env');

    //   final Map<String, dynamic> storedEnvironmentMap =
    //       json.decode(storedEnvironmentAsString!) as Map<String, dynamic>;

    //   storedEnvironmentMap['server'] = 'Hermannschule';

    //   try {
    //     final Env legacyEnvironment = Env.fromJson(storedEnvironmentMap);

    //     final EnvsInStorage environmentsInStorage = EnvsInStorage(
    //         defalutEnv: legacyEnvironment.server!,
    //         environmentsMap: {legacyEnvironment.server!: legacyEnvironment});

    //     final String jsonEnvs = jsonEncode(environmentsInStorage);

    //     await secureStorageWrite(SecureStorageKey.environments.value, jsonEnvs);

    //     return environmentsInStorage;
    //   } catch (e) {
    //     logger.f('Error reading env from secureStorage: $e',
    //         stackTrace: StackTrace.current);

    //     // log('deleting faulty environments from secure storage');

    //     // await secureStorageDelete(SecureStorageKey.environments.value);

    //     locator<NotificationService>().showSnackBar(NotificationType.error,
    //         'Fehler beim Lesen der Umgebung aus dem sicheren Speicher');

    //     return null;
    //   }
    // }
    return null;
  }

  // set the environment from a string
  void importNewEnv(String envAsString) async {
    final Env env =
        Env.fromJson(json.decode(envAsString) as Map<String, dynamic>);

    _environments = {..._environments, env.server: env};

    _defaultEnv = env.server;

    logger.i(
        'New Env ${env.server} stored, there are now ${_environments.length} environments stored!');

    locator<NotificationService>().showSnackBar(NotificationType.success,
        'Schulschlüssel für ${env.server} gespeichert!');

    activateEnv(envName: env.server);

    return;
  }

  deleteEnv() async {
    final deletedEnvironment = _activeEnv!.server;

    // delete _env.value from _envs

    _environments.remove(_activeEnv!.server);

    // write _envs to secure storage

    final jsonEnvs = json.encode(_environments);

    await AppSecureStorage.write(SecureStorageKey.environments.value, jsonEnvs);

    // if there are environments left in _envs, set the last one as value

    if (_environments.isNotEmpty) {
      _activeEnv = _environments.values.last;

      _defaultEnv = _environments.keys.last;

      logger.i('Env $deletedEnvironment New defaultEnv: $_defaultEnv');

      //  locator<ApiClient>().setBaseUrl(_activeEnv!.serverUrl);
    } else {
      // if there are no environments left, delete the environments from secure storage

      await AppSecureStorage.delete(SecureStorageKey.environments.value);

      _activeEnv = null;

      _defaultEnv = '';

      _envReady.value = false;
    }

    locator<MainMenuBottomNavManager>().setBottomNavPage(0);
  }

  Future<void> activateEnv({required String envName}) async {
    _activeEnv = _environments[envName]!;

    final updatedEnvsForStorage = EnvsInStorage(
        defalutEnv: _activeEnv!.server, environmentsMap: _environments);

    final String jsonEnvs = jsonEncode(updatedEnvsForStorage);

    await AppSecureStorage.write(SecureStorageKey.environments.value, jsonEnvs);

    _defaultEnv = envName;

    _envReady.value = true;

    logger.i('Activated Env: ${_activeEnv!.server}');

    if (_dependentMangagersRegistered.value == true) {
      locator<NotificationService>().setNewInstanceLoadingValue(true);

      await SessionHelper.clearInstanceSessionServerData();

      locator<SessionManager>().unauthenticate();

      await locator<SessionManager>().checkStoredCredentials();

      //await propagateNewEnv();
    }
  }

  setEnvNotReady() {
    _envReady.value = false;
    _activeEnv = null;
  }

  Future<void> propagateNewEnv() async {
    await locator<PupilIdentityManager>().getPupilIdentitiesForEnv();
    await locator<UserManager>().fetchUsers();

    await locator<PupilManager>().fetchAllPupils();
    await locator<SchooldayManager>().getSchoolSemesters();
    await locator<SchooldayManager>().getSchooldays();
    await locator<LearningSupportManager>().fetchSupportCategories();
    await locator<CompetenceManager>().fetchCompetences();
    await locator<SchoolListManager>().fetchSchoolLists();
    await locator<AuthorizationManager>().fetchAuthorizations();
    await locator<WorkbookManager>().getWorkbooks();
    await locator<MainMenuBottomNavManager>().setBottomNavPage(0);
    if (locator<SessionManager>().isAdmin.value == true) {
      await locator<UserManager>().fetchUsers();
    }
    logger.i('New Env propagated');
    locator<NotificationService>().setNewInstanceLoadingValue(false);
    locator<NotificationService>().showInformationDialog(
        'Instanz "${_activeEnv!.server}" erfolgreich geladen!');
  }
}
