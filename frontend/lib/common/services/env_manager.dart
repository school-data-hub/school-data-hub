import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:schuldaten_hub/common/models/session_models/env.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/common/utils/secure_storage.dart';
import 'package:schuldaten_hub/features/main_menu_pages/widgets/landing_bottom_nav_bar.dart';

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
    bool isStoredEnv = await secureStorageContains('environments');
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _packageInfo.value = packageInfo;
    if (isStoredEnv == true) {
      _defaultEnv.value = await secureStorageRead('defaultEnv') ?? '';
      final String? storedSession = await secureStorageRead('environments');
      logger.i('environment(s) found!');
      try {
        final Map<String, Env> environmentsMap =
            (json.decode(storedSession!) as Map<String, dynamic>).map(
                (key, value) =>
                    MapEntry(key, Env.fromJson(value as Map<String, dynamic>)));
        _envs.value = environmentsMap;
        // if there are environments stored, the default environment is already set
        _env.value = environmentsMap[_defaultEnv.value] ?? Env();
        _envReady.value = true;

        return;
      } catch (e) {
        logger.f('Error reading env from secureStorage!',
            stackTrace: StackTrace.current);

        await secureStorageDelete('environments');

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
    _env.value = env;
    _envs.value = {..._envs.value, env.serverUrl!: env};
    _defaultEnv.value = env.serverUrl!;

    final jsonEnvs = json.encode(_envs.value);
    await secureStorageWrite('environments', jsonEnvs);
    await secureStorageWrite('defaultEnv', env.serverUrl!);

    _envReady.value = true;
    logger.i('Env stored');
    logger.i(jsonEnvs);
    return;
  }

  deleteEnv() async {
    // delete _env.value from _envs.value
    _envs.value.remove(_env.value.serverUrl);
    // write _envs.value to secure storage
    final jsonEnvs = json.encode(_envs.value);
    await secureStorageWrite('environments', jsonEnvs);
    // if there are environments left in _envs.value, set the last one as _env.value
    if (_envs.value.isNotEmpty) {
      _env.value = _envs.value.values.last;
      _defaultEnv.value = _envs.value.keys.last;
    } else {
      // if there are no environments left, delete the environments from secure storage
      await secureStorageDelete('environments');
      _env.value = Env();
      _defaultEnv.value = '';
      _envReady.value = false;
    }

    locator.get<BottomNavManager>().setBottomNavPage(0);
  }
}
