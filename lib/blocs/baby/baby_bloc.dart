import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/locator.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/baby_repository.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/user_repository.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/services/firebase/auth_service.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/baby_model.dart';
import 'package:meta/meta.dart';


part 'baby_event.dart';

part 'baby_state.dart';

class BabyBloc extends Bloc<BabyEvent, BabyState> {
  final AuthService _authService = getIt<AuthService>();
  final UserRepository _userRepository = getIt<UserRepository>();
  final BabyRepository _babyRepository = getIt<BabyRepository>();





  BabyBloc() : super(BabyInitial()) {
    on<RegisterBaby>((event, emit)async {
      emit(BabyLoading());
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");
      final babyId = const Uuid().v4(); // v4 = random ID
      final baby = BabyModel(firstName: event.firstName,
          gender: event.gender,
          userID: user.uid,
          babyID: babyId,
          dateTime: event.dateTime);

      await _babyRepository.createBaby(baby);
      emit(BabySuccess());

    });
  }
}
