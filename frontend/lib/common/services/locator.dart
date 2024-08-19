import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:schuldaten_hub/api/services/dio/api_client_service.dart';
import 'package:schuldaten_hub/common/constants/enums.dart';
import 'package:schuldaten_hub/common/services/env_manager.dart';
import 'package:schuldaten_hub/common/services/search_textfield_manager.dart';
import 'package:schuldaten_hub/common/services/notification_manager.dart';
import 'package:schuldaten_hub/common/utils/custom_encrypter.dart';
import 'package:schuldaten_hub/features/users/services/user_manager.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/common/utils/secure_storage.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupils_filter_impl.dart';
import 'package:schuldaten_hub/features/schoolday_events/filters/schoolday_event_filter_manager.dart';
import 'package:schuldaten_hub/features/schoolday_events/services/schoolday_event_manager.dart';
import 'package:schuldaten_hub/features/authorizations/services/authorization_manager.dart';
import 'package:schuldaten_hub/features/matrix/filters/matrix_policy_filter_manager.dart';
import 'package:schuldaten_hub/features/competence/filters/competence_filter_manager.dart';
import 'package:schuldaten_hub/features/competence/services/competence_manager.dart';
import 'package:schuldaten_hub/api/services/connection_manager.dart';
import 'package:schuldaten_hub/features/matrix/services/matrix_policy_manager.dart';
import 'package:schuldaten_hub/features/learning_support/services/learning_support_manager.dart';
import 'package:schuldaten_hub/features/pupil/filters/pupil_filter_manager.dart';
import 'package:schuldaten_hub/features/pupil/services/pupil_manager.dart';

import 'package:schuldaten_hub/features/pupil/services/pupil_identity_manager.dart';
import 'package:schuldaten_hub/features/school_lists/filters/school_list_filter_manager.dart';
import 'package:schuldaten_hub/features/school_lists/services/school_list_manager.dart';
import 'package:schuldaten_hub/common/services/schoolday_manager.dart';
import 'package:schuldaten_hub/features/main_menu_pages/widgets/landing_bottom_nav_bar.dart';
import 'package:schuldaten_hub/features/workbooks/services/workbook_manager.dart';
import 'package:watch_it/watch_it.dart';

import 'package:schuldaten_hub/features/attendance/services/attendance_manager.dart';
import 'session_manager.dart';

final locator = GetIt.instance;

void registerBaseManagers() {
  logger.i('Registering base managers');

  locator.registerSingletonAsync<EnvManager>(() async {
    final envManager = EnvManager();
    await envManager.init();
    logger.i('EnvManager initialized');
    return envManager;
  });

  locator.registerSingletonAsync<ConnectionManager>(() async {
    logger.i('Registering ConnectionManager');
    final connectionManager = ConnectionManager();
    await connectionManager.checkConnectivity();
    logger.i('ConnectionManager registered');
    return connectionManager;
  });

  locator.registerSingleton<ApiClientService>(ApiClientService(Dio(), ''));

  locator.registerSingletonAsync<SessionManager>(() async {
    logger.i('Registering SessionManager');
    final sessionManager = SessionManager();
    await sessionManager.init();
    logger.i('SessionManager initialized');
    return sessionManager;
  }, dependsOn: [EnvManager, ConnectionManager]);

  locator.registerSingletonAsync<PupilIdentityManager>(() async {
    logger.i('Registering PupilIdentityManager');
    final pupilBaseManager = PupilIdentityManager();
    await pupilBaseManager.init();
    logger.i('PupilIdentityManager initialized');
    return pupilBaseManager;
  }, dependsOn: [EnvManager]);

  locator.registerSingleton<DefaultCacheManager>(DefaultCacheManager());

  locator.registerSingleton<NotificationManager>(NotificationManager());

  locator.registerSingleton<BottomNavManager>(BottomNavManager());

  locator.registerSingleton<SearchManager>(SearchManager());
}

Future registerDependentManagers() async {
  logger.i('Registering dependent managers');

  locator.registerSingletonAsync<UserManager>(() async {
    logger.i('Registering UserManager');
    final userManager = UserManager();
    await userManager.init();
    logger.i('UserManager initialized');
    return userManager;
  }, dependsOn: [SessionManager]);

  locator.registerSingletonAsync<SchooldayManager>(() async {
    logger.i('Registering SchooldayManager');
    final schooldayManager = SchooldayManager();
    await schooldayManager.init();
    logger.i('SchooldayManager initialized');
    return schooldayManager;
  }, dependsOn: [SessionManager]);

  locator.registerSingletonAsync<PupilManager>(() async {
    logger.i('Registering PupilManager');
    final pupilManager = PupilManager();
    await pupilManager.init();
    logger.i('PupilManager initialized');
    return pupilManager;
  }, dependsOn: [SessionManager, PupilIdentityManager]);

  locator.registerSingletonAsync<WorkbookManager>(() async {
    logger.i('Registering WorkbookManager');
    final workbookManager = WorkbookManager();
    await workbookManager.init();
    logger.i('WorkbookManager initialized');
    return workbookManager;
  }, dependsOn: [
    PupilManager,
    SessionManager,
  ]);

  locator.registerSingletonAsync<CompetenceManager>(() async {
    logger.i('Registering CompetenceManager');
    final competenceManager = CompetenceManager();
    await competenceManager.init();
    logger.i('CompetenceManager initialized');
    return competenceManager;
  }, dependsOn: [SessionManager]);

  locator.registerSingletonWithDependencies<CompetenceFilterManager>(
    () => CompetenceFilterManager(),
    dependsOn: [CompetenceManager],
  );

  locator.registerSingletonAsync<LearningSupportManager>(() async {
    logger.i('Registering GoalManager');
    final goalManager = LearningSupportManager();
    await goalManager.init();
    logger.i('GoalManager initialized');
    return goalManager;
  }, dependsOn: [SessionManager]);

  locator.registerSingletonAsync<AuthorizationManager>(() async {
    logger.i('Registering AuthorizationManager');
    final authorizationManager = AuthorizationManager();
    await authorizationManager.init();
    logger.i('AuthorizationManager initialized');
    return authorizationManager;
  }, dependsOn: [SessionManager]);

  locator.registerSingletonWithDependencies<PupilFilterManager>(
      () => PupilFilterManager(),
      dependsOn: [PupilManager]);

  locator.registerSingletonWithDependencies<SchooldayEventFilterManager>(() {
    logger.i('SchooldayEventFilterManager initialized');
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
    logger.i('Registering SchoolListManager');
    final schoolListManager = SchoolListManager();
    await schoolListManager.init();
    logger.i('SchoolListManager initialized');
    return schoolListManager;
  }, dependsOn: [SchoolListFilterManager, SessionManager]);

  locator.registerSingletonWithDependencies<AttendanceManager>(
      () => AttendanceManager(),
      dependsOn: [SchooldayManager, PupilsFilter]);

  locator.registerSingletonWithDependencies<SchooldayEventManager>(
      () => SchooldayEventManager(),
      dependsOn: [SchooldayManager, PupilsFilter]);

  if (await secureStorageContains('matrix')) {
    await registerMatrixPolicyManager();
  }
}

Future<bool> registerMatrixPolicyManager() async {
  if (locator.isRegistered<MatrixPolicyManager>()) {
    return true;
  }

  locator.registerSingletonAsync<MatrixPolicyManager>(() async {
    logger.i('Registering MatrixPolicyManager');
    final policyManager = MatrixPolicyManager();
    await policyManager.init();
    logger.i('MatrixPolicyManager initialized');
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
  locator.unregister<ApiClientService>();
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

  if (locator.isRegistered<MatrixPolicyManager>()) {
    locator.unregister<MatrixPolicyManager>();
    locator.unregister<MatrixPolicyFilterManager>();
  }
  locator.unregister<PupilsFilter>();
}
