import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:open_baby_sara/data/repositories/locator.dart';
import 'package:open_baby_sara/data/models/invite_model.dart';
import 'package:open_baby_sara/data/repositories/caregiver_repository.dart';
import 'package:open_baby_sara/data/repositories/user_repository.dart';
import 'package:open_baby_sara/data/services/firebase/auth_service.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'caregiver_event.dart';

part 'caregiver_state.dart';

class CaregiverBloc extends Bloc<CaregiverEvent, CaregiverState> {
  final CaregiverRepository _caregiverRepository = getIt<CaregiverRepository>();
  final UserRepository _userRepository = getIt<UserRepository>();
  final AuthService _authService = getIt<AuthService>();

  CaregiverBloc() : super(CaregiverInitial()) {
    on<CreateCaregiver>((event, emit) async {
      emit(CaregiverLoading());
      final user = FirebaseAuth.instance.currentUser;
      var userMap =
          (await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .get())
              .data();
      final String parentID = userMap!['parentID'];

      InviteModel newCaregiver = InviteModel(
        senderID: user!.uid,
        receiverEmail: event.email,
        parentID: parentID,
        status: 'pending',
        createdAt: DateTime.now(),
        caregiverID: Uuid().v4(),
        firstName: event.firstName,
      );
      try {
        await _caregiverRepository.createCaregiver(newCaregiver);
        _userRepository.addCaregiverInUser(newCaregiver);
        emit(CaregiverAdded());
      } catch (e) {
        emit(CaregiverError(e.toString()));
      }
    });
    on<CaregiverSignUp>((event, emit) async {
      emit(CaregiverLoading());
      try {
        await _caregiverRepository.signUpCaregiverAndCheck(
          event.firstName,
          event.email,
          event.password,
        );
        emit(CaregiverSignedUp());
      } catch (e) {
        emit(CaregiverError(e.toString()));
      }
    });
    on<CaregiverSignUpWithGoogle>((event, emit) async {
      emit(CaregiverLoading());
      try {
        // First, perform Google Sign-In
        final user = await _authService.signInWithGoogle();
        if (user == null) {
          // User cancelled Google Sign-In, return to initial state
          emit(CaregiverInitial());
          return;
        }

        // Extract user information from Google account
        final email = user.email ?? '';
        if (email.isEmpty) {
          emit(CaregiverError('Email not found in Google account'));
          return;
        }

        final displayName = user.displayName ?? 'User';
        final firstName = displayName.split(' ').first;

        // Email kontrolü ve Firestore işlemlerini yap
        await _caregiverRepository.signUpCaregiverWithGoogle(
          firstName,
          email,
        );
        emit(CaregiverSignedUp());
      } catch (e) {
        emit(CaregiverError(e.toString()));
      }
    });
    on<GetCaregivers>((event, emit) async {
      final caregiverList = await _caregiverRepository.getCaregiverList();

      if (caregiverList!.isNotEmpty) {
        emit(GetCaregiverList(caregiverList: caregiverList));
      } else {
        emit(GetCaregiverList(caregiverList: caregiverList));
      }
    });

    on<DeleteCaregiver>((event, emit) async {
      try {
        await _caregiverRepository.deleteCaregiver(event.caregiverID);
        emit(CaregiverDeleted());
      } catch (e) {
        emit(CaregiverError(e.toString()));
      }
    });
  }
}
