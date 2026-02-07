import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracing_app_new/feature/auth/data/models/user_model.dart';
import 'package:tracing_app_new/feature/auth/data/repo/auth_repo.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;

  AuthCubit(this._authRepo) : super(AuthInitialState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    emit(AuthCheckingState());
    final currentUser = await _authRepo.getCurrentUser();
    currentUser.fold(
      (error) => emit(AuthInitialState()),
      // *** التعديل الرئيسي: إضافة قائمة children فارغة ***
      (userModel) => emit(AuthenticatedState(userModel, children: [])),
    );
  }

  // --- مصادقة المستخدم ---
  Future<void> signUp({required UserModel userModel, required String password}) async {
    emit(SignUpLoadingState());
    final result = await _authRepo.signUp(userModel: userModel, password: password);
    result.fold(
      (error) => emit(SignUpErrorState(error)),
      (message) => emit(SignUpVerificationSentState(message)),
    );
  }

  Future<void> login({required String email, required String password}) async {
    emit(LoginLoadingState());
    final result = await _authRepo.login(email: email, password: password);
    result.fold(
      (error) => emit(LoginErrorState(error)),
      // *** التعديل الرئيسي: إضافة قائمة children فارغة ***
      (userModel) => emit(AuthenticatedState(userModel, children: [])),
    );
  }

  Future<void> resetPassword({required String email}) async {
    emit(PasswordResetLoadingState());
    final result = await _authRepo.sendPasswordResetEmail(email: email);
    result.fold(
      (error) => emit(PasswordResetErrorState(error)),
      (message) => emit(PasswordResetSuccessState(message)),
    );
  }

  Future<void> logout() async {
    emit(LogoutLoadingState());
    final result = await _authRepo.logout();
    result.fold(
      (error) => emit(LogoutErrorState(error)),
      (_) => emit(AuthInitialState()),
    );
  }
}