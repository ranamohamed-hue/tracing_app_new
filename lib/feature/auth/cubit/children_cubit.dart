import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracing_app_new/feature/auth/data/models/user_model.dart';
import 'package:tracing_app_new/feature/auth/data/repo/auth_repo.dart';
import 'package:tracing_app_new/feature/auth/cubit/children_state.dart';

class ChildrenCubit extends Cubit<ChildrenState> {
  final AuthRepo _authRepo;
  List<UserModel> _children = [];

  ChildrenCubit(this._authRepo) : super(ChildrenInitial());

  List<UserModel> get children => _children;

  Future<void> fetchChildren(String parentUid) async {
    emit(ChildrenLoadingState());

    try {
      final result = await _authRepo.getParentChildren(parentUid);
      result.fold(
        (error) => emit(ChildrenErrorState(error)),
        (children) {
          _children = children ?? [];
          emit(ChildrenLoadedState(_children));
        },
      );
    } catch (e, stackTrace) {
      print('خطأ غير متوقع أثناء جلب الأبناء: $e');
      print('StackTrace: $stackTrace');
      emit(ChildrenErrorState('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  void clearChildren() {
    _children.clear();
    emit(ChildrenInitial());
  }
}