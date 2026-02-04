import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracing_app_new/feature/auth/data/repo/auth_repo.dart';
// *** التعديل: استيراد ملف الحالات المخصص ***
import 'package:tracing_app_new/feature/auth/cubit/child_tracing_state.dart';

// *** التعديل: تغيير نوع الحالة إلى ChildTrackingState ***
class ChildTrackingCubit extends Cubit<ChildTrackingState> {
  final AuthRepo _authRepo;
  StreamSubscription<GeoPoint>? _childLocationSubscription;

  // *** التعديل: استخدام الحالة الأولية الجديدة ***
  ChildTrackingCubit(this._authRepo) : super(ChildTrackingInitial());

  @override
  Future<void> close() {
    _childLocationSubscription?.cancel();
    return super.close();
  }

  void startTrackingChild(String childUid) {
    // *** التعديل: استخدام حالة التحميل الجديدة ***
    emit(ChildLocationLoadingState());
    _childLocationSubscription?.cancel();

    _childLocationSubscription = _authRepo.getChildLocationStream(childUid).listen(
      (geoPointLocation) {
        final latLngLocation = LatLng(geoPointLocation.latitude, geoPointLocation.longitude);
        // *** التعديل: استخدام حالة التحديث الجديدة ***
        emit(ChildLocationUpdatedState(latLngLocation));
      },
      onError: (error) {
        // *** التعديل: استخدام حالة الخطأ الجديدة ***
        emit(ChildLocationErrorState(error.toString()));
      },
    );
  }

  void stopTrackingChild() {
    _childLocationSubscription?.cancel();
    _childLocationSubscription = null;
    // *** إضافة: إصدار حالة أولية عند الإيقاف للإشارة إلى أن التتبع توقف ***
    emit(ChildTrackingInitial());
  }
}