import 'package:equatable/equatable.dart';
import 'package:tracing_app_new/feature/auth/data/models/user_model.dart';

// --- الحالات الأساسية للمصادقة ---
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthCheckingState extends AuthState {}

class AuthenticatedState extends AuthState {
  final UserModel userModel;
  final List<UserModel> children;

  const AuthenticatedState(this.userModel, {this.children = const []});

  @override
  List<Object> get props => [userModel, children];
}

// --- حالات إنشاء الحساب (Sign Up) ---
class SignUpLoadingState extends AuthState {}

class SignUpVerificationSentState extends AuthState {
  final String message;
  const SignUpVerificationSentState(this.message);

  @override
  List<Object> get props => [message];
}

class SignUpErrorState extends AuthState {
  final String error;
  const SignUpErrorState(this.error);

  @override
  List<Object> get props => [error];
}

// --- حالات تسجيل الدخول (Login) ---
class LoginLoadingState extends AuthState {}

class LoginErrorState extends AuthState {
  final String error;
  const LoginErrorState(this.error);

  @override
  List<Object> get props => [error];
}

// --- حالات تسجيل الخروج (Logout) ---
class LogoutLoadingState extends AuthState {}

class LogoutErrorState extends AuthState {
  final String error;
  const LogoutErrorState(this.error);

  @override
  List<Object> get props => [error];
}
// حالات استعادة كلمة المرور
class PasswordResetLoadingState extends AuthState {}
class PasswordResetSuccessState extends AuthState {
  final String message;
  PasswordResetSuccessState(this.message);
}
class PasswordResetErrorState extends AuthState {
  final String error;
  PasswordResetErrorState(this.error);
}