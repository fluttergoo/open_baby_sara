part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;

  AuthSuccess(this.user);
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}

class Authenticated extends AuthState {
  final UserModel userModel;

  Authenticated({required this.userModel});
}

class Unauthenticated extends AuthState {}

class AuthSignOut extends AuthState {}

class PasswordChanged extends AuthState {
  final String message;

  PasswordChanged(this.message);
}

class UserDeleted extends AuthState {}

class ForgotPasswordSuccess extends AuthState {}

class ForgotPasswordFailure extends AuthState {
  final String error;
  ForgotPasswordFailure(this.error);
}

class UserAlreadyExists extends AuthState {}
