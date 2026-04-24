import 'package:get_it/get_it.dart';
import 'package:votera_app/core/config/app_config.dart';
import 'package:votera_app/core/network/api_client.dart';
import 'package:votera_app/core/storage/local_storage.dart';
import 'package:votera_app/core/storage/secure_storage.dart';
import 'package:votera_app/core/services/push_notification_service.dart';

// Auth
import 'package:votera_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:votera_app/features/auth/data/repositories/auth_respository_impl.dart';
import 'package:votera_app/features/auth/domain/repositories/iauth_repository.dart';

// User
import 'package:votera_app/features/user/data/datasources/user_remote_datasource.dart';
import 'package:votera_app/features/user/data/repositories/user_repository_impl.dart';
import 'package:votera_app/features/user/domain/repositories/iuser_repository.dart';

// Workspace
import 'package:votera_app/features/workspace/data/datasources/workspace_remote_datasource.dart';
import 'package:votera_app/features/workspace/data/repositories/workspace_repository_impl.dart';
import 'package:votera_app/features/workspace/domain/repositories/iworkspace_repository.dart';

// Poll
import 'package:votera_app/features/poll/data/datasources/poll_remote_datasource.dart';
import 'package:votera_app/features/poll/data/repositories/poll_repository_impl.dart';
import 'package:votera_app/features/poll/domain/repositories/poll_repository.dart';

// Category
import 'package:votera_app/features/category/data/datasources/category_remote_datasource.dart';
import 'package:votera_app/features/category/data/repositories/category_repository_impl.dart';
import 'package:votera_app/features/category/domain/repositories/icategory_repository.dart';

// Comment
import 'package:votera_app/features/comment/data/datasources/comment_remote_datasource.dart';
import 'package:votera_app/features/comment/data/repositories/comment_repository_impl.dart';
import 'package:votera_app/features/comment/domain/repositories/icomment_repository.dart';

// Reaction
import 'package:votera_app/features/reaction/data/datasources/reaction_remote_datasource.dart';
import 'package:votera_app/features/reaction/data/repositories/reaction_repository_impl.dart';
import 'package:votera_app/features/reaction/domain/repositories/ireaction_repository.dart';

// Dashboard
import 'package:votera_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:votera_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:votera_app/features/dashboard/domain/repositories/idashboard_repository.dart';

// Report
import 'package:votera_app/features/report/data/datasources/report_remote_datasource.dart';
import 'package:votera_app/features/report/data/repositories/report_repository_impl.dart';
import 'package:votera_app/features/report/domain/repositories/ireport_repository.dart';

// Notification
import 'package:votera_app/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:votera_app/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:votera_app/features/notification/domain/repositories/inotification_repository.dart';
// Terms
import 'package:votera_app/features/terms/data/datasources/terms_remote_datasource.dart';
import 'package:votera_app/features/terms/data/repositories/terms_repository_impl.dart';
import 'package:votera_app/features/terms/domain/repositories/iterms_repository.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ── Storage ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  final localStorage = LocalStorageService();
  await localStorage.init();
  sl.registerSingleton<LocalStorageService>(localStorage);
  // ── Network ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));

  // ── Auth ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );

  // ── User ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<IUserRepository>(() => UserRepositoryImpl(sl()));

  // ── Workspace ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<WorkspaceRemoteDataSource>(
    () => WorkspaceRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<IWorkspaceRepository>(
    () => WorkspaceRepositoryImpl(sl()),
  );

  // ── Poll ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<PollRemoteDataSource>(
    () => PollRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<PollRepository>(() => PollRepositoryImpl(sl()));

  // ── Category ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<ICategoryRepository>(
    () => CategoryRepositoryImpl(sl()),
  );

  // ── Comment ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<CommentRemoteDataSource>(
    () => CommentRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<ICommentRepository>(
    () => CommentRepositoryImpl(sl()),
  );

  // ── Reaction ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ReactionRemoteDataSource>(
    () => ReactionRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<IReactionRepository>(
    () => ReactionRepositoryImpl(sl()),
  );

  // ── Dashboard ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<IDashboardRepository>(
    () => DashboardRepositoryImpl(sl()),
  );

  // ── Report ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<IReportRepository>(() => ReportRepositoryImpl(sl()));

  // ── Notification ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );

  // ── Terms & Conditions ───────────────────────────────────
  sl.registerLazySingleton<TermsRemoteDataSource>(
    () => TermsRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<ITermsRepository>(() => TermsRepositoryImpl(sl()));

  // ── Push notifications (FCM) ───────────────────────────────────────────
  sl.registerLazySingleton<PushNotificationService>(
    () => PushNotificationService(
      sl<SecureStorageService>(),
      sl<NotificationRemoteDataSource>(),
      vapidKey: AppConfig.firebaseVapidKey.isEmpty
          ? null
          : AppConfig.firebaseVapidKey,
    ),
  );

  // Initialize FCM after all services are registered.
  try {
    await sl<PushNotificationService>().init();
  } catch (_) {}
}
