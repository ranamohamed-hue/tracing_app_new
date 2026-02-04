import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracing_app_new/feature/auth/data/repo/auth_repo.dart';
// *** استيراد ملف الحالات المخصص لولي الأمر ***
import 'package:tracing_app_new/feature/auth/cubit/parent_state.dart';

class ParentCubit extends Cubit<ParentState> {
  final AuthRepo _authRepo;

  ParentCubit(this._authRepo) : super(ParentInitial());

  Future<void> generateInviteCode(String parentUid) async {
    emit(InviteCodeLoadingState());
    final result = await _authRepo.generateInviteCode(parentUid);
    result.fold(
      (error) => emit(InviteCodeErrorState(error)),
      (code) => emit(InviteCodeGeneratedState(code)),
    );
  }

  Future<void> linkParentToChild({required String parentUid, required String inviteCode}) async {
    emit(LinkingLoadingState());
    final result = await _authRepo.linkParentToChild(parentUid: parentUid, inviteCode: inviteCode);
    result.fold(
      (error) => emit(LinkingErrorState(error)),
      (_) => emit(LinkingSuccessState()),
    );
  }
}