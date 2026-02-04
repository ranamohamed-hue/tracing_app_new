import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracing_app_new/feature/auth/data/models/user_model.dart';
import 'package:tracing_app_new/feature/auth/data/repo/auth_repo.dart';
// *** التعديل: استيراد ملف الحالات المخصص ***
import 'package:tracing_app_new/feature/auth/cubit/children_state.dart';

// *** التعديل: تغيير نوع الحالة إلى ChildrenState ***
class ChildrenCubit extends Cubit<ChildrenState> {
  final AuthRepo _authRepo;
  List<UserModel> _children = [];

  // *** التعديل: استخدام الحالة الأولية الجديدة ***
  ChildrenCubit(this._authRepo) : super(ChildrenInitial());

  List<UserModel> get children => _children;

  Future<void> fetchChildren(String parentUid) async {
    // هذه الحالة صحيحة وموجودة في children_state.dart
    emit(ChildrenLoadingState());

    try {
      final result = await _authRepo.getParentChildren(parentUid);
      result.fold(
        (error) => emit(ChildrenErrorState(error)),
        (children) {
          _children = children ?? [];
          // هذه الحالة صحيحة وموجودة في children_state.dart
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
    // *** التعديل: استخدام الحالة الأولية الجديدة بدلاً من AuthInitialState ***
    emit(ChildrenInitial());
  }
}