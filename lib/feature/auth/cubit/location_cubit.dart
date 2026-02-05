import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracing_app_new/feature/auth/data/repo/auth_repo.dart';
// *** استيراد ملف الحالات المخصص للموقع ***
import 'package:tracing_app_new/feature/auth/cubit/location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final AuthRepo _authRepo;
  StreamSubscription<Position>? _positionStreamSubscription; // استخدام الـ Stream بدلاً من الـ Timer
  bool _isTrackingActive = false;

  LocationCubit(this._authRepo) : super(LocationInitial());

  @override
  Future<void> close() {
    _positionStreamSubscription?.cancel();
    return super.close();
  }

  // هذه الدالة أصبحت الآن تطلب الإذن وتبدأ البث
  void _startLocationTracking(String userUid) async {
    if (_isTrackingActive) return;

    // 1. التأكد من الخدمات والإذونات
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(const LocationErrorState('خدمات الموقع معطلة.'));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        emit(const LocationErrorState('تم رفض أذونات الموقع.'));
        return;
      }
    }

    _isTrackingActive = true;
    emit(TrackingStartedState());

    // 2. إعدادات البث (يرسل تحديث كلما تحرك المستخدم لمسافة 5 أمتار مثلاً)
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // تحديث كل 5 أمتار حركة
    );

    // 3. بدء الاستماع للموقع وإرساله فوراً لـ Firebase
    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) async {
      final geoPoint = GeoPoint(position.latitude, position.longitude);
      
      // تحديث Firebase في الخلفية
      await _authRepo.updateUserLocation(userUid, geoPoint);
      
      // تحديث الحالة لولي الأمر
      if (!isClosed) emit(LocationUpdatedState(geoPoint));
    });
  }

  void _stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isTrackingActive = false;
    emit(TrackingStoppedState());
  }

  void toggleTracking(String userUid) {
    print("تم الضغط على الزرار لـ UID: $userUid"); // ضيف ده
    if (_isTrackingActive) {
      _stopLocationTracking();
    } else {
      _startLocationTracking(userUid);
    }
  }
}