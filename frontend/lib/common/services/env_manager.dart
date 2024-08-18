import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:schuldaten_hub/api/services/dio/dio_client.dart';
import 'package:schuldaten_hub/common/models/session_models/env.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/schoolday_manager.dart';
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
  ValueListenable<Env> get env => _env;
  ValueListenable<Map<String, Env>> get envs => _envs;
  ValueListenable<String> get defaultEnv => _defaultEnv;
  ValueListenable<bool> get envReady => _envReady;
  ValueListenable<PackageInfo> get packageInfo => _packageInfo;

  final _env = ValueNotifier<Env>(Env());
  final _envs = ValueNotifier<Map<String, Env>>({});
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
    logger.i('EnvManager constructor called!');
    await checkStoredEnv();
    logger.i('returning EnvManager instance!');
    return this;
  }

  Future<void> checkStoredEnv() async {
    bool isStoredEnv =
        await secureStorageContains(SecureStorageKey.environments.value);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _packageInfo.value = packageInfo;
    if (isStoredEnv == true) {
      _defaultEnv.value = await secureStorageRead('defaultEnv') ?? '';
      final String? storedSession =
          await secureStorageRead(SecureStorageKey.environments.value);

      try {
        final Map<String, Env> environmentsMap =
            (json.decode(storedSession!) as Map<String, dynamic>).map(
                (key, value) =>
                    MapEntry(key, Env.fromJson(value as Map<String, dynamic>)));
        _envs.value = environmentsMap;
        // if there are environments stored, the default environment is already set
        _env.value = environmentsMap[_defaultEnv.value] ?? Env();
        locator<DioClient>().setBaseUrl(_env.value.serverUrl!);
        _envReady.value = true;
        logger.i('${environmentsMap.length} environment(s) found!');
        return;
      } catch (e) {
        logger.f('Error reading env from secureStorage!',
            stackTrace: StackTrace.current);

        await secureStorageDelete(SecureStorageKey.environments.value);

        return;
      }
    } else {
      logger.i('No env found');

      return;
    }
  }

  // set the environment from a string
  void addEnv(String scanResult) async {
    final Env env =
        Env.fromJson(json.decode(scanResult) as Map<String, dynamic>);

    _envs.value = {..._envs.value, env.server!: env};

    final jsonEnvs = json.encode(_envs.value);
    await secureStorageWrite(SecureStorageKey.environments.value, jsonEnvs);
    await secureStorageWrite(SecureStorageKey.defaultEnv.value, env.server!);

    logger.i('New Env ${env.server} stored');
    logger.i(jsonEnvs);
    switchEnv(envName: env.server!);
    return;
  }

  deleteEnv() async {
    // delete _env.value from _envs.value
    _envs.value.remove(_env.value.server);
    // write _envs.value to secure storage
    final jsonEnvs = json.encode(_envs.value);
    await secureStorageWrite(SecureStorageKey.environments.value, jsonEnvs);
    // if there are environments left in _envs.value, set the last one as _env.value
    if (_envs.value.isNotEmpty) {
      _env.value = _envs.value.values.last;
      _defaultEnv.value = _envs.value.keys.last;
    } else {
      // if there are no environments left, delete the environments from secure storage
      await secureStorageDelete(SecureStorageKey.environments.value);
      _env.value = Env();
      _defaultEnv.value = '';
      _envReady.value = false;
    }

    locator<BottomNavManager>().setBottomNavPage(0);
  }

  Future<void> switchEnv({required String envName}) async {
    _envReady.value = true;
    _env.value = _envs.value[envName]!;
    locator<DioClient>().setBaseUrl(_env.value.serverUrl!);
    _defaultEnv.value = envName;
    secureStorageWrite(SecureStorageKey.defaultEnv.value, envName);
    if (!locator.isRegistered<SchooldayManager>()) {
      registerDependentManagers();
    } else {
      final cacheManager = locator<DefaultCacheManager>();
      await cacheManager.emptyCache();
      await locator<SessionManager>().checkStoredCredentials();
      await locator<UserManager>().fetchUsers();
      await locator<PupilIdentityManager>().getStoredPupilIdentities();
      await locator<PupilManager>().fetchAllPupils();
      await locator<SchooldayManager>().getSchoolSemesters();
      await locator<SchooldayManager>().getSchooldays();
      await locator<LearningSupportManager>().fetchGoalCategories();
      await locator<CompetenceManager>().fetchCompetences();
      await locator<SchoolListManager>().fetchSchoolLists();
      await locator<AuthorizationManager>().fetchAuthorizations();
    }
    locator<BottomNavManager>().setBottomNavPage(0);
  }

  setEnvNotReady() {
    _envReady.value = false;
    _env.value = Env();
  }
}
