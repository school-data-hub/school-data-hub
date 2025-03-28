import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/filters/filters_state_manager.dart';
import 'package:schuldaten_hub/common/services/api/api_client.dart';
import 'package:schuldaten_hub/common/services/connection_manager.dart';
import 'package:schuldaten_hub/common/services/notification_service.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';
import 'package:schuldaten_hub/common/utils/secure_storage.dart';
import 'package:schuldaten_hub/features/attendance/domain/attendance_manager.dart';
import 'package:schuldaten_hub/features/attendance/domain/filters/attendance_pupil_filter.dart';
import 'package:schuldaten_hub/features/authorizations/domain/authorization_manager.dart';
import 'package:schuldaten_hub/features/authorizations/domain/filters/authorization_filter_manager.dart';
import 'package:schuldaten_hub/features/authorizations/domain/filters/pupil_authorization_filter_manager.dart';
import 'package:schuldaten_hub/features/books/domain/book_manager.dart';
import 'package:schuldaten_hub/features/competence/domain/competence_manager.dart';
import 'package:schuldaten_hub/features/competence/domain/filters/competence_filter_manager.dart';
import 'package:schuldaten_hub/features/competence/presentation/widgets/pupil_learning_content_expansion_tile_nav_bar.dart';
import 'package:schuldaten_hub/features/learning_support/domain/filters/learning_support_filter_manager.dart';
import 'package:schuldaten_hub/features/learning_support/domain/learning_support_manager.dart';
import 'package:schuldaten_hub/features/main_menu/widgets/landing_bottom_nav_bar.dart';
import 'package:schuldaten_hub/features/matrix/domain/filters/matrix_policy_filter_manager.dart';
import 'package:schuldaten_hub/features/matrix/domain/matrix_policy_manager.dart';
import 'package:schuldaten_hub/features/matrix/domain/register_matrix_policy_manager.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupil_filter_manager.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupils_filter.dart';
import 'package:schuldaten_hub/features/pupil/domain/filters/pupils_filter_impl.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_identity_manager.dart';
import 'package:schuldaten_hub/features/pupil/domain/pupil_manager.dart';
import 'package:schuldaten_hub/features/school_lists/domain/filters/school_list_filter_manager.dart';
import 'package:schuldaten_hub/features/school_lists/domain/school_list_manager.dart';
import 'package:schuldaten_hub/features/schoolday_events/domain/filters/schoolday_event_filter_manager.dart';
import 'package:schuldaten_hub/features/schoolday_events/domain/schoolday_event_manager.dart';
import 'package:schuldaten_hub/features/schooldays/domain/schoolday_manager.dart';
import 'package:schuldaten_hub/features/users/domain/user_manager.dart';
import 'package:schuldaten_hub/features/workbooks/domain/workbook_manager.dart';
import 'package:watch_it/watch_it.dart';

import '../domain/session_manager.dart';

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

  locator.registerSingletonWithDependencies<ApiClient>(() => ApiClient(Dio()),
      dependsOn: [EnvManager]);

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

  locator.registerSingleton<NotificationService>(NotificationService());

  locator
      .registerSingleton<MainMenuBottomNavManager>(MainMenuBottomNavManager());

  locator.registerSingleton<FiltersStateManager>(
      FiltersStateManagerImplementation());

  // locator.registerSingletonWithDependencies<EventFluxService>(
  //   () => EventFluxService(),
  //   dependsOn: [SessionManager],
  // );
}

Future registerDependentManagers() async {
  if (locator<EnvManager>().dependentManagersRegistered.value) {
    locator<EnvManager>().propagateNewEnv();
    return;
  }
  logger.i('Registering dependent managers');

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

  locator.registerSingletonAsync<BookManager>(() async {
    log('Registering BookManager');
    final bookManager = BookManager();
    await bookManager.init();
    log('BookManager initialized');
    return bookManager;
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

  locator.registerLazySingleton<SelectedLearningContentNotifier>(
      () => SelectedLearningContentNotifier());

  locator.registerSingletonAsync<LearningSupportManager>(() async {
    log('Registering LearningSupportManager');
    final learningSupportManager = LearningSupportManager();
    await learningSupportManager.init();
    log('LearningSupportManager initialized');
    return learningSupportManager;
  }, dependsOn: [SessionManager]);

  locator.registerSingletonAsync<AuthorizationManager>(() async {
    log('Registering AuthorizationManager');
    final authorizationManager = AuthorizationManager();
    await authorizationManager.init();
    log('AuthorizationManager initialized');
    return authorizationManager;
  }, dependsOn: [SessionManager]);

  locator.registerSingletonWithDependencies<PupilAuthorizationFilterManager>(
      () => PupilAuthorizationFilterManager(),
      dependsOn: [AuthorizationManager]);

  locator.registerSingletonWithDependencies<AuthorizationFilterManager>(() {
    final authorizationFilterManager = AuthorizationFilterManager();
    return authorizationFilterManager.init();
  }, dependsOn: [AuthorizationManager]);

  locator.registerSingletonWithDependencies<PupilFilterManager>(
      () => PupilFilterManager(),
      dependsOn: [PupilManager]);

  locator.registerSingletonWithDependencies<SchooldayEventFilterManager>(() {
    log('SchooldayEventFilterManager initialized');
    return SchooldayEventFilterManager();
  }, dependsOn: [PupilManager, PupilFilterManager]);

  locator.registerSingletonWithDependencies<LearningSupportFilterManager>(
      () => LearningSupportFilterManager(),
      dependsOn: [PupilManager, PupilFilterManager]);

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

  locator.registerSingletonWithDependencies<AttendancePupilFilterManager>(
      () => AttendancePupilFilterManager(),
      dependsOn: [AttendanceManager]);

  locator.registerSingletonWithDependencies<SchooldayEventManager>(
      () => SchooldayEventManager(),
      dependsOn: [SchooldayManager, PupilsFilter]);

  if (await AppSecureStorage.containsKey(SecureStorageKey.matrix.value)) {
    registerMatrixPolicyManager();
  } else {
    log('No matrix credentials found');
  }

  locator<EnvManager>().setDependentManagersRegistered(true);
}

Future unregisterDependentManagers() async {
  locator.unregister<SelectedLearningContentNotifier>();
  locator.unregister<UserManager>();
  locator.unregister<SchooldayManager>();

  locator.unregister<WorkbookManager>();
  locator.unregister<BookManager>();

  locator.unregister<LearningSupportFilterManager>();
  locator.unregister<LearningSupportManager>();

  locator.unregister<CompetenceFilterManager>();
  locator.unregister<CompetenceManager>();

  locator.unregister<SchoolListFilterManager>();
  locator.unregister<SchoolListManager>();

  locator.unregister<PupilAuthorizationFilterManager>();
  locator.unregister<AuthorizationFilterManager>();
  locator.unregister<AuthorizationManager>();

  locator.unregister<AttendancePupilFilterManager>();
  locator.unregister<AttendanceManager>();

  locator.unregister<SchooldayEventFilterManager>();
  locator.unregister<SchooldayEventManager>();

  locator.unregister<PupilsFilter>();
  locator.unregister<PupilFilterManager>();
  locator.unregister<PupilManager>();

  if (locator.isRegistered<MatrixPolicyManager>()) {
    locator.unregister<MatrixPolicyFilterManager>();
    locator.unregister<MatrixPolicyManager>();

    locator<SessionManager>()
        .changeMatrixPolicyManagerRegistrationStatus(false);
  }

  locator<EnvManager>().setDependentManagersRegistered(false);
}
