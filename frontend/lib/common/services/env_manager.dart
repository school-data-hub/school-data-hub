import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/api/services/api_client_service.dart';
import 'package:schuldaten_hub/common/models/env.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';

import 'package:schuldaten_hub/features/schooldays/services/schoolday_manager.dart';
import 'package:schuldaten_hub/common/services/session_manager.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/common/utils/secure_storage.dart';
import 'package:schuldaten_hub/features/authorizations/services/authorization_manager.dart';
import 'package:schuldaten_hub/features/competence/services/competence_manager.dart';
import 'package:schuldaten_hub/features/learning_support/services/learning_support_manager.dart';
import 'package:schuldaten_hub/features/main_menu_pages/widgets/landing_bottom_nav_bar.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_identity_manager.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';
import 'package:schuldaten_hub/features/school_lists/services/school_list_manager.dart';
import 'package:schuldaten_hub/features/users/services/user_manager.dart';
import 'package:schuldaten_hub/features/workbooks/services/workbook_manager.dart';

class EnvManager {
  final _dependentMangagersRegistered = ValueNotifier<bool>(false);
  ValueListenable<bool> get dependentManagersRegistered =>
      _dependentMangagersRegistered;

  final _activeEnv = ValueNotifier<Env>(Env());
  ValueListenable<Env> get env => _activeEnv;

  final _environments = ValueNotifier<Map<String, Env>>({});
  ValueListenable<Map<String, Env>> get envs => _environments;

  final _defaultEnv = ValueNotifier<String>('');
  ValueListenable<String> get defaultEnv => _defaultEnv;

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

  EnvManager();

  Future<EnvManager> init() async {
    await firstRun();
    return this;
  }

  void setDependentManagersRegistered(bool value) {
    _dependentMangagersRegistered.value = value;
  }

  Future<void> firstRun() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _packageInfo.value = packageInfo;

    final EnvsInStorage? environmentsObject = await environmentsInStorage();

    if (environmentsObject == null) {
      return;
    }

    _defaultEnv.value = environmentsObject.defalutEnv;
    _environments.value = environmentsObject.environmentsMap;

    _activeEnv.value =
        environmentsObject.environmentsMap[_defaultEnv.value] ?? Env();
    log('new defaultEnv: ${_defaultEnv.value}');
    // set the base url for the api client
    locator<ApiClientService>().setBaseUrl(_activeEnv.value.serverUrl!);

    _envReady.value = true;

    return;
  }

  Future<EnvsInStorage?> environmentsInStorage() async {
    bool environmentsInStorage =
        await secureStorageContainsKey(SecureStorageKey.environments.value);

    if (environmentsInStorage == true) {
      final String? storedEnvironmentsAsString =
          await secureStorageRead(SecureStorageKey.environments.value);

      try {
        final environmentsInStorage = EnvsInStorage.fromJson(
            json.decode(storedEnvironmentsAsString!) as Map<String, dynamic>);
        return environmentsInStorage;
      } catch (e) {
        logger.f('Error reading env from secureStorage: $e',
            stackTrace: StackTrace.current);
        log('deleting faulty environments from secure storage');
        await secureStorageDelete(SecureStorageKey.environments.value);

        return null;
      }
    }
    //- TODO: remove this after all users have migrated to the new env storage
    bool legacyEnvironmentInStorage = await secureStorageContainsKey('env');
    if (legacyEnvironmentInStorage == true) {
      final String? storedEnvironmentAsString = await secureStorageRead('env');
      final Map<String, dynamic> storedEnvironmentMap =
          json.decode(storedEnvironmentAsString!) as Map<String, dynamic>;
      storedEnvironmentMap['server'] = 'Hermannschule';

      try {
        final Env legacyEnvironment = Env.fromJson(storedEnvironmentMap);

        final EnvsInStorage environmentsInStorage = EnvsInStorage(
            defalutEnv: legacyEnvironment.server!,
            environmentsMap: {legacyEnvironment.server!: legacyEnvironment});

        final String jsonEnvs = jsonEncode(environmentsInStorage);

        await secureStorageWrite(SecureStorageKey.environments.value, jsonEnvs);

        return environmentsInStorage;
      } catch (e) {
        logger.f('Error reading env from secureStorage: $e',
            stackTrace: StackTrace.current);
        // log('deleting faulty environments from secure storage');
        // await secureStorageDelete(SecureStorageKey.environments.value);
        locator<NotificationManager>().showSnackBar(NotificationType.error,
            'Fehler beim Lesen der Umgebung aus dem sicheren Speicher');
        return null;
      }
    }
    return null;
  }

  // set the environment from a string
  void importNewEnv(String envAsString) async {
    final Env env =
        Env.fromJson(json.decode(envAsString) as Map<String, dynamic>);

    _environments.value = {..._environments.value, env.server!: env};
    _defaultEnv.value = env.server!;

    logger.i(
        'New Env ${env.server} stored, there are now ${_environments.value.length} environments stored!');

    locator<NotificationManager>().showSnackBar(NotificationType.success,
        'Schulschlüssel für ${env.server} gespeichert!');
    activateEnv(envName: env.server!);

    return;
  }

  deleteEnv() async {
    final deltedEnvironment = _activeEnv.value.server!;
    // delete _env.value from _envs.value
    _environments.value.remove(_activeEnv.value.server);
    // write _envs.value to secure storage
    final jsonEnvs = json.encode(_environments.value);
    await secureStorageWrite(SecureStorageKey.environments.value, jsonEnvs);
    // if there are environments left in _envs.value, set the last one as value
    if (_environments.value.isNotEmpty) {
      _activeEnv.value = _environments.value.values.last;
      _defaultEnv.value = _environments.value.keys.last;
      logger.i('Env $deltedEnvironment New defaultEnv: ${_defaultEnv.value}');
      locator<ApiClientService>().setBaseUrl(_activeEnv.value.serverUrl!);
    } else {
      // if there are no environments left, delete the environments from secure storage
      await secureStorageDelete(SecureStorageKey.environments.value);
      _activeEnv.value = Env();
      _defaultEnv.value = '';
      _envReady.value = false;
    }

    locator<BottomNavManager>().setBottomNavPage(0);
  }

  Future<void> activateEnv({required String envName}) async {
    _activeEnv.value = _environments.value[envName]!;
    locator<ApiClientService>().setBaseUrl(_activeEnv.value.serverUrl!);
    final updatedEnvsForStorage = EnvsInStorage(
        defalutEnv: _activeEnv.value.server!,
        environmentsMap: _environments.value);

    final String jsonEnvs = jsonEncode(updatedEnvsForStorage);

    await secureStorageWrite(SecureStorageKey.environments.value, jsonEnvs);

    _defaultEnv.value = envName;

    _envReady.value = true;
    logger.i('Activated Env: ${_activeEnv.value.server}');
    if (_dependentMangagersRegistered.value == true) {
      locator<NotificationManager>().heavyLoadingValue(true);
      clearInstanceSessionServerData();
      locator<SessionManager>().unauthenticate();

      await locator<SessionManager>().checkStoredCredentials();

      //await propagateNewEnv();
    }
  }

  setEnvNotReady() {
    _envReady.value = false;
    _activeEnv.value = Env();
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
    await locator<BottomNavManager>().setBottomNavPage(0);
    if (locator<SessionManager>().isAdmin.value == true) {
      await locator<UserManager>().fetchUsers();
    }
    logger.i('New Env propagated');
    locator<NotificationManager>().heavyLoadingValue(false);
  }

  Future<void> clearInstanceSessionServerData() async {
    logger.i('Clearing instance server data');
    await locator<DefaultCacheManager>().emptyCache();
    locator<PupilIdentityManager>().clearPupilIdentities();
    locator<PupilsFilter>().clearFilteredPupils();
    locator<PupilManager>().clearData();
    locator<UserManager>().clearUsers();
    locator<SchooldayManager>().clearData();
    locator<LearningSupportManager>().clearData();
    locator<CompetenceManager>().clearData();
    locator<SchoolListManager>().clearData();
    locator<AuthorizationManager>().clearData();
    locator<WorkbookManager>().clearData();
    return;
  }
}
