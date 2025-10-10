import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:open_baby_sara/data/repositories/activity_repository_impl.dart';
import 'package:open_baby_sara/data/repositories/activity_reposityory.dart';
import 'package:open_baby_sara/data/repositories/baby_repository.dart';
import 'package:open_baby_sara/data/repositories/baby_repsitory_impl.dart';
import 'package:open_baby_sara/data/repositories/caregiver_repository.dart';
import 'package:open_baby_sara/data/repositories/caregiver_repository_impl.dart';
import 'package:open_baby_sara/data/repositories/medication_repository.dart';
import 'package:open_baby_sara/data/repositories/medication_repository_impl.dart';
import 'package:open_baby_sara/data/repositories/recipe_repository.dart';
import 'package:open_baby_sara/data/repositories/recipe_repository_impl.dart';
import 'package:open_baby_sara/data/repositories/relaxing_sound_repository.dart';
import 'package:open_baby_sara/data/repositories/relaxing_sound_repository_impl.dart';
import 'package:open_baby_sara/data/repositories/timer_repository.dart';
import 'package:open_baby_sara/data/repositories/timer_repository_impl.dart';
import 'package:open_baby_sara/data/repositories/user_repository.dart';
import 'package:open_baby_sara/data/repositories/user_repository_impl.dart';
import 'package:open_baby_sara/data/repositories/vaccination_repository.dart';
import 'package:open_baby_sara/data/repositories/vaccination_repository_impl.dart';
import 'package:open_baby_sara/data/services/firebase/activity_service.dart';
import 'package:open_baby_sara/data/services/firebase/activity_service_impl.dart';
import 'package:open_baby_sara/data/services/firebase/analytics_service.dart';
import 'package:open_baby_sara/data/services/firebase/analytics_service_impl.dart';
import 'package:open_baby_sara/data/services/firebase/auth_service.dart';
import 'package:open_baby_sara/data/services/firebase/update_service.dart';
import 'package:open_baby_sara/data/services/local_database/milestone_service.dart';
import 'package:open_baby_sara/data/services/local_database/milestone_service_impl.dart';
import 'package:get_it/get_it.dart';

import '../services/local_database/local_database_service.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  final database = await LocalDatabaseService.database;

  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl());
  getIt.registerLazySingleton<BabyRepository>(() => BabyRepositoryImpl());
  getIt.registerLazySingleton<CaregiverRepository>(
    () => CaregiverRepositoryImpl(),
  );
  getIt.registerLazySingleton<TimerRepository>(
    () => TimerRepositoryImpl(database: database),
  );
  getIt.registerLazySingleton<ActivityRepository>(
    () => ActivityRepositoryImpl(database: database),
  );
  getIt.registerLazySingleton<ActivityService>(() => ActivityServiceImpl());
  getIt.registerLazySingleton<MilestoneService>(
    () => MilestoneServiceImpl(database: database),
  );
  getIt.registerLazySingleton<MedicationRepository>(
    () => MedicationRepositoryImpl(database: database),
  );
  getIt.registerLazySingleton<VaccinationRepository>(
    () => VaccinationRepositoryImpl(database: database),
  );
  getIt.registerLazySingleton<RelaxingSoundRepository>(
    () => RelaxingSoundRepositoryImpl(database: database),
  );

  getIt.registerLazySingleton<AudioPlayer>(() => AudioPlayer());
  getIt.registerLazySingleton<RecipeRepository>(() => RecipeRepositoryImpl());
  getIt.registerLazySingleton<AnalyticsService>(() => AnalyticsServiceImpl());

  final remoteConfig = FirebaseRemoteConfig.instance;

  final updateService = UpdateService(remoteConfig);
  await updateService.initialize();

  getIt.registerSingleton<UpdateService>(updateService);
}
