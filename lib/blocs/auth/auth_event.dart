part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class RegisterUser extends AuthEvent {
  final String email;
  final String password;
  final String firstname;

  RegisterUser({
    required this.email,
    required this.password,
    required this.firstname,
  });
}

class SignInWithEmailAndPassword extends AuthEvent {
  final String email;
  final String password;

  SignInWithEmailAndPassword({required this.email, required this.password});
}

class AppStarted extends AuthEvent {}

class GetUserModel extends AuthEvent {}

class SignOut extends AuthEvent {}

class ChangePassword extends AuthEvent {
  final String password;

  ChangePassword({required this.password});
}

class DeleteUser extends AuthEvent {}

class ForgotPasswordUser extends AuthEvent {
  final String email;

  ForgotPasswordUser({required this.email});
}

class SignInWithGoogleRequested extends AuthEvent {}
