import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/constant/message_constants.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/locator.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/invite_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/user_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/caregiver_repository.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/user_repository.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/services/firebase/auth_service.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/utils/firebase_auth_errors.dart';

import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService = getIt<AuthService>();
  final UserRepository _userRepository = getIt<UserRepository>();
  final CaregiverRepository _caregiverRepository = getIt<CaregiverRepository>();

  AuthBloc() : super(AuthInitial()) {
    on<RegisterUser>((event, emit) async {
      emit(AuthLoading());
      final user = await _authService.registerWithEmailAndPassword(
        event.email,
        event.password,
      );
      if (user != null) {
        final userModel = UserModel(
          userID: user.uid,
          email: event.email,
          parentID: Uuid().v4(),
          firstName: event.firstname,
          caregivers: [],
          createdAt: DateTime.now(),
        );
        await _userRepository.createUserInFireStore(userModel);
        emit(AuthSuccess(user));
      } else {
        emit(AuthFailure('Registration Failed'));
      }
    });
    on<SignInWithEmailAndPassword>((event, emit) async {
      emit(AuthLoading());
      try {
        await _userRepository.signInEmailAndPassword(
          event.email,
          event.password,
        );
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          emit(AuthSuccess(user));
        } else {
          emit(AuthFailure('User not found'));
        }
      } on FirebaseAuthException catch (e) {
        final errorMessage = getFirebaseAuthErrorMessage(e.code);
        emit(AuthFailure(errorMessage));
      } catch (e) {
        emit(AuthFailure('Beklenmeyen bir hata oluştu.'));
      }
    });
    on<AppStarted>((event, emit) async {
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(userModel: user));
      } else {
        emit(Unauthenticated());
      }
    });
    UserModel? _lastEmittedUser;
    on<GetUserModel>((event, emit) async {
      emit(AuthLoading());
      final userModel = await _userRepository.getCurrentUser();
      if (userModel != null) {
        if (userModel.userID != _lastEmittedUser?.userID) {
          _lastEmittedUser = userModel;
          emit(Authenticated(userModel: userModel));
        }
      } else {
        emit(AuthFailure("Kullanıcı verisi alınamadı."));
      }
    });
    on<SignOut>((event, emit) async {
      await _userRepository.signOut();
      emit(AuthSignOut());
    });
    on<ChangePassword>((event, emit) async {
      emit(AuthLoading());
      try {
        _userRepository.changePassword(event.password);
        emit(PasswordChanged(MessageConstants.saveSuccess));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<DeleteUser>((event, emit) async{
      emit(AuthLoading());
      try {
        await _userRepository.deleteUser();
        emit(UserDeleted());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
