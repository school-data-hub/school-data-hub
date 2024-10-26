import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/api/services/api_client_service.dart';
import 'package:schuldaten_hub/common/services/api/services/connection_manager.dart';
import 'package:schuldaten_hub/common/services/env_manager.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/common/services/search_textfield_manager.dart';
import 'package:schuldaten_hub/common/services/sse.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/common/utils/secure_storage.dart';
import 'package:schuldaten_hub/features/attendance/services/attendance_manager.dart';
import 'package:schuldaten_hub/features/authorizations/services/authorization_manager.dart';
import 'package:schuldaten_hub/features/competence/filters/competence_filter_manager.dart';
import 'package:schuldaten_hub/features/competence/services/competence_manager.dart';
import 'package:schuldaten_hub/features/learning_support/services/learning_support_manager.dart';
import 'package:schuldaten_hub/features/main_menu_pages/widgets/landing_bottom_nav_bar.dart';
import 'package:schuldaten_hub/features/matrix/filters/matrix_policy_filter_manager.dart';
import 'package:schuldaten_hub/features/matrix/services/matrix_api_service.dart';
import 'package:schuldaten_hub/features/matrix/services/matrix_policy_manager.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupil_filter_manager.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter_impl.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_identity_manager.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';
import 'package:schuldaten_hub/features/school_lists/filters/school_list_filter_manager.dart';
import 'package:schuldaten_hub/features/school_lists/services/school_list_manager.dart';
import 'package:schuldaten_hub/features/schoolday_events/filters/schoolday_event_filter_manager.dart';
import 'package:schuldaten_hub/features/schoolday_events/services/schoolday_event_manager.dart';
import 'package:schuldaten_hub/features/schooldays/services/schoolday_manager.dart';
import 'package:schuldaten_hub/features/users/services/user_manager.dart';
import 'package:schuldaten_hub/features/workbooks/services/workbook_manager.dart';
import 'package:watch_it/watch_it.dart';

import 'session_manager.dart';

final locator = GetIt.instance;

void registerBaseManagers() {
  logger.i('Registering base managers');
  locator.registerSingletonAsync<ConnectionManager>(() async {
    log('Registering ConnectionManager');
    final connectionManager = ConnectionManager();
    await connectionManager.checkConnectivity();
    log('ConnectionManager registered');
    return connectionManager;
  });
  locator.registerSingletonAsync<EnvManager>(() async {
    log('Registering EnvManager');
    final envManager = EnvManager();
    await envManager.init();
    log('EnvManager registered');
    return envManager;
  }, dependsOn: [ConnectionManager]);

  locator.registerSingleton<ApiClientService>(ApiClientService(Dio(), ''));

  locator.registerSingletonAsync<SessionManager>(() async {
    log('Registering SessionManager');
    final sessionManager = SessionManager();
    await sessionManager.init();
    log('SessionManager initialized');
    return sessionManager;
  }, dependsOn: [EnvManager]);

  locator.registerSingletonAsync<PupilIdentityManager>(() async {
    log('Registering PupilIdentityManager');
    final pupilIdentityManager = PupilIdentityManager();
    await pupilIdentityManager.init();
    log('PupilIdentityManager initialized');
    return pupilIdentityManager;
  }, dependsOn: [SessionManager]);

  locator.registerSingleton<DefaultCacheManager>(DefaultCacheManager());

  locator.registerSingleton<NotificationManager>(NotificationManager());

  locator.registerSingleton<BottomNavManager>(BottomNavManager());
}

Future registerDependentManagers() async {
  if (locator<EnvManager>().dependentManagersRegistered.value) {
    locator<EnvManager>().propagateNewEnv();
    return;
  }
  logger.i('Registering dependent managers');

  locator.registerSingleton<SearchManager>(SearchManager());

  locator.registerSingletonWithDependencies<EventFluxService>(
    () => EventFluxService(),
    dependsOn: [SessionManager],
  );
  locator.registerSingletonAsync<UserManager>(() async {
    log('Registering UserManager');
    final userManager = UserManager();
    await userManager.init();
    log('UserManager initialized');
    return userManager;
  }, dependsOn: [SessionManager]);

  locator.registerSingletonAsync<SchooldayManager>(() async {
    log('Registering SchooldayManager');
    final schooldayManager = SchooldayManager();
    await schooldayManager.init();
    log('SchooldayManager initialized');
    return schooldayManager;
  }, dependsOn: [SessionManager]);

  locator.registerSingletonAsync<PupilManager>(() async {
    log('Registering PupilManager');
    final pupilManager = PupilManager();
    await pupilManager.init();
    log('PupilManager initialized');
    return pupilManager;
  }, dependsOn: [SessionManager, PupilIdentityManager]);

  locator.registerSingletonAsync<WorkbookManager>(() async {
    log('Registering WorkbookManager');
    final workbookManager = WorkbookManager();
    await workbookManager.init();
    log('WorkbookManager initialized');
    return workbookManager;
  }, dependsOn: [
    PupilManager,
    SessionManager,
  ]);

  locator.registerSingletonAsync<CompetenceManager>(() async {
    log('Registering CompetenceManager');
    final competenceManager = CompetenceManager();
    await competenceManager.init();
    log('CompetenceManager initialized');
    return competenceManager;
  }, dependsOn: [SessionManager]);

  locator.registerSingletonWithDependencies<CompetenceFilterManager>(
    () => CompetenceFilterManager(),
    dependsOn: [CompetenceManager],
  );

  locator.registerSingletonAsync<LearningSupportManager>(() async {
    log('Registering GoalManager');
    final goalManager = LearningSupportManager();
    await goalManager.init();
    log('GoalManager initialized');
    return goalManager;
  }, dependsOn: [SessionManager]);

  locator.registerSingletonAsync<AuthorizationManager>(() async {
    log('Registering AuthorizationManager');
    final authorizationManager = AuthorizationManager();
    await authorizationManager.init();
    log('AuthorizationManager initialized');
    return authorizationManager;
  }, dependsOn: [SessionManager]);

  locator.registerSingletonWithDependencies<PupilFilterManager>(
      () => PupilFilterManager(),
      dependsOn: [PupilManager]);

  locator.registerSingletonWithDependencies<SchooldayEventFilterManager>(() {
    log('SchooldayEventFilterManager initialized');
    return SchooldayEventFilterManager();
  }, dependsOn: [PupilManager, PupilFilterManager]);

  locator.registerSingletonWithDependencies<PupilsFilter>(
      () => PupilsFilterImplementation(
            locator<PupilManager>(),
          ),
      dependsOn: [
        PupilManager,
        PupilFilterManager,
        SchooldayEventFilterManager
      ]);

  locator.registerSingletonWithDependencies<SchoolListFilterManager>(
      () => SchoolListFilterManager(),
      dependsOn: [PupilsFilter]);

  locator.registerSingletonAsync<SchoolListManager>(() async {
    log('Registering SchoolListManager');
    final schoolListManager = SchoolListManager();
    await schoolListManager.init();
    log('SchoolListManager initialized');
    return schoolListManager;
  }, dependsOn: [SchoolListFilterManager, SessionManager]);

  locator.registerSingletonWithDependencies<AttendanceManager>(
      () => AttendanceManager(),
      dependsOn: [SchooldayManager, PupilsFilter]);

  locator.registerSingletonWithDependencies<SchooldayEventManager>(
      () => SchooldayEventManager(),
      dependsOn: [SchooldayManager, PupilsFilter]);

  if (await secureStorageContainsKey('matrix')) {
    await registerMatrixPolicyManager();
  }

  locator<EnvManager>().setDependentManagersRegistered(true);
}

Future<bool> registerMatrixPolicyManager() async {
  if (locator.isRegistered<MatrixPolicyManager>()) {
    return true;
  }

  locator.registerSingletonAsync<MatrixPolicyManager>(() async {
    log('Registering MatrixPolicyManager');
    final policyManager = MatrixPolicyManager();
    await policyManager.init();
    log('MatrixPolicyManager initialized');
    locator<NotificationManager>().showSnackBar(
        NotificationType.success, 'Matrix-Räumeverwaltung initialisiert');
    return policyManager;
  }, dependsOn: [SessionManager, PupilManager]);

  locator.registerSingletonWithDependencies<MatrixPolicyFilterManager>(
    () => MatrixPolicyFilterManager(),
    dependsOn: [MatrixPolicyManager],
  );

  return true;
}

Future unregisterDependentManagers() async {
  locator.unregister<UserManager>();
  locator.unregister<SchooldayManager>();
  locator.unregister<WorkbookManager>();
  locator.unregister<LearningSupportManager>();

  locator.unregister<PupilFilterManager>();
  locator.unregister<CompetenceFilterManager>();
  locator.unregister<CompetenceManager>();
  locator.unregister<SchoolListManager>();
  locator.unregister<SchoolListFilterManager>();
  locator.unregister<AuthorizationManager>();
  locator.unregister<AttendanceManager>();
  locator.unregister<SchooldayEventManager>();
  locator.unregister<SchooldayEventFilterManager>();
  locator.unregister<PupilManager>();
  locator.unregister<SearchManager>();
  if (locator.isRegistered<MatrixPolicyManager>()) {
    locator.unregister<MatrixPolicyManager>();
    locator.unregister<MatrixPolicyFilterManager>();
    locator.unregister<MatrixPolicyManager>();
    locator.unregister<MatrixApiService>();

    locator<SessionManager>().changeMatrixPolicyManagerRegistrationStatus(true);
  }
  locator.unregister<PupilsFilter>();
  locator<EnvManager>().setDependentManagersRegistered(false);
}
