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

class EnvManager {
  ValueListenable<bool> get dependentManagersRegistered =>
      _dependentMangagersRegistered;
  ValueListenable<Env> get env => _activeEnv;
  ValueListenable<Map<String, Env>> get envs => _environments;
  ValueListenable<String> get defaultEnv => _defaultEnv;
  ValueListenable<bool> get envReady => _envReady;
  ValueListenable<PackageInfo> get packageInfo => _packageInfo;

  final _dependentMangagersRegistered = ValueNotifier<bool>(false);
  final _activeEnv = ValueNotifier<Env>(Env());
  final _environments = ValueNotifier<Map<String, Env>>({});
  final _defaultEnv = ValueNotifier<String>('');
  final _envReady = ValueNotifier<bool>(false);
  final _packageInfo = ValueNotifier<PackageInfo>(PackageInfo(
    appName: '',
    packageName: '',
    version: '',
    buildNumber: '',
    buildSignature: '',
  ));

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
    return null;
  }

  // set the environment from a string
  void importNewEnv(String envAsString) async {
    final Env env =
        Env.fromJson(json.decode(envAsString) as Map<String, dynamic>);

    _environments.value = {..._environments.value, env.server!: env};
    final updatedEnvsForStorage = EnvsInStorage(
        defalutEnv: env.server!, environmentsMap: _environments.value);
    final String jsonEnvs = jsonEncode(updatedEnvsForStorage);

    await secureStorageWrite(SecureStorageKey.environments.value, jsonEnvs);
    logger.i(
        'New Env ${env.server} stored, there are now ${_environments.value.length} environments stored!');

    activateEnv(envName: env.server!);

    locator<NotificationManager>()
        .showSnackBar(NotificationType.success, 'Schulschlüssel gespeichert!');
    return;
  }

  deleteEnv() async {
    final deltedEnvironment = _activeEnv.value.server!;
    // delete _env.value from _envs.value
    _environments.value.remove(_activeEnv.value.server);
    // write _envs.value to secure storage
    final jsonEnvs = json.encode(_environments.value);
    await secureStorageWrite(SecureStorageKey.environments.value, jsonEnvs);
    // if there are environments left in _envs.value, set the last one as _env.value
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

    _defaultEnv.value = envName;

    _envReady.value = true;
    logger.i('Activated Env: ${_activeEnv.value.server}');
    if (_dependentMangagersRegistered.value == true) {
      locator<SessionManager>().unauthaeticate();
      await propagateNewEnv();
    }
  }

  setEnvNotReady() {
    _envReady.value = false;
    _activeEnv.value = Env();
  }

  Future<void> propagateNewEnv() async {
    await locator<DefaultCacheManager>().emptyCache();
    await locator<SessionManager>().checkStoredCredentials();
    await locator<UserManager>().fetchUsers();
    await locator<PupilIdentityManager>().getPupilIdentitiesForEnv();
    locator<PupilManager>().clearData();
    locator<PupilsFilter>().clearFilteredPupils;
    await locator<PupilManager>().fetchAllPupils();
    await locator<SchooldayManager>().getSchoolSemesters();
    await locator<SchooldayManager>().getSchooldays();
    await locator<LearningSupportManager>().fetchGoalCategories();
    await locator<CompetenceManager>().fetchCompetences();
    await locator<SchoolListManager>().fetchSchoolLists();
    await locator<AuthorizationManager>().fetchAuthorizations();
    locator<BottomNavManager>().setBottomNavPage(0);
  }
}
