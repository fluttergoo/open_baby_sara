import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/baby_repository.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/baby_repsitory_impl.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/caregiver_repository.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/caregiver_repository_impl.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/user_repository.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/user_repository_impl.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/services/firebase/auth_service.dart';
import 'package:get_it/get_it.dart';

final getIt =GetIt.instance;
void setupLocator(){
  getIt.registerLazySingleton<AuthService>(()=>AuthService());
  getIt.registerLazySingleton<UserRepository>(()=>UserRepositoryImpl());
  getIt.registerLazySingleton<BabyRepository>(()=>BabyRepositoryImpl());
  getIt.registerLazySingleton<CaregiverRepository>(()=>CaregiverRepositoryImpl());

}