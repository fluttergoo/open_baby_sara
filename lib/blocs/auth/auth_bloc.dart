import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:open_baby_sara/core/constant/message_constants.dart';
import 'package:open_baby_sara/data/repositories/locator.dart';
import 'package:open_baby_sara/data/models/invite_model.dart';
import 'package:open_baby_sara/data/models/user_model.dart';
import 'package:open_baby_sara/data/repositories/caregiver_repository.dart';
import 'package:open_baby_sara/data/repositories/user_repository.dart';
import 'package:open_baby_sara/data/services/firebase/auth_service.dart';
import 'package:open_baby_sara/core/utils/firebase_auth_errors.dart';

import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService = getIt<AuthService>();
  final UserRepository _userRepository = getIt<UserRepository>();

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
        emit(Authenticated(userModel: userModel));
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
        await Future.delayed(Duration(milliseconds: 300));
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await Future.delayed(Duration(milliseconds: 300));
          final userModel = await _userRepository.getCurrentUser();

          emit(Authenticated(userModel: userModel!));
        } else {
          emit(AuthFailure('User not found'));
        }
      } on FirebaseAuthException catch (e) {
        final errorMessage = getFirebaseAuthErrorMessage(e.code);
        emit(AuthFailure(errorMessage));
      } catch (e) {
        emit(AuthFailure('Error ${e.toString()}'));
      }
    });
    on<SignInWithGoogle>((event, emit) async {
      emit(AuthLoading());
      try {
        debugPrint('AuthBloc: Starting Google Sign-In...');
        final user = await _authService.signInWithGoogle();
        if (user == null) {
          // User cancelled Google Sign-In, return to unauthenticated state
          debugPrint('AuthBloc: Google Sign-In cancelled by user');
          emit(Unauthenticated());
          return;
        }

        debugPrint('AuthBloc: Google Sign-In successful, user ID: ${user.uid}');
        await Future.delayed(Duration(milliseconds: 300));
        
        // Check if user exists in Firestore
        var userModel = await _userRepository.getCurrentUser();
        
        // If user doesn't exist in Firestore, create new user
        if (userModel == null) {
          debugPrint('AuthBloc: User not found in Firestore, creating new user...');
          final displayName = user.displayName ?? 'User';
          final firstName = displayName.split(' ').first;
          
          userModel = UserModel(
            userID: user.uid,
            email: user.email ?? '',
            parentID: Uuid().v4(),
            firstName: firstName,
            caregivers: [],
            createdAt: DateTime.now(),
          );
          await _userRepository.createUserInFireStore(userModel);
          debugPrint('AuthBloc: New user created in Firestore');
        } else {
          debugPrint('AuthBloc: Existing user found in Firestore');
        }
        
        emit(Authenticated(userModel: userModel));
        debugPrint('AuthBloc: Authentication successful');
      } on FirebaseAuthException catch (e) {
        debugPrint('AuthBloc: FirebaseAuthException: ${e.code} - ${e.message}');
        final errorMessage = getFirebaseAuthErrorMessage(e.code);
        emit(AuthFailure(errorMessage));
      } catch (e) {
        debugPrint('AuthBloc: Google Sign-In Error: ${e.toString()}');
        emit(AuthFailure('Google Sign-In Error: ${e.toString()}'));
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
        emit(AuthFailure("Error"));
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

    on<DeleteUser>((event, emit) async {
      emit(AuthLoading());
      try {
        await _userRepository.deleteUser();
        emit(UserDeleted());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<ForgotPasswordUser>((event, emit) async {
      emit(AuthLoading());
      try {
        await _userRepository.forgotPassword(event.email);
        emit(ForgotPasswordSuccess());
      } catch (e) {
        emit(AuthFailure('Error $e'));
      }
    });
  }
}
