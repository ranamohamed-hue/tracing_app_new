import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracing_app_new/feature/auth/data/repo/auth_repo.dart';
// استيراد ملف الحالات المخصص للموقع
import 'package:tracing_app_new/feature/auth/cubit/location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final AuthRepo _authRepo;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isTrackingActive = false;

  LocationCubit(this._authRepo) : super(LocationInitial());

  @override
  Future<void> close() {
    _positionStreamSubscription?.cancel();
    return super.close();
  }

  // دالة بدء التتبع
  void _startLocationTracking(String userUid) async {
    if (_isTrackingActive) return;

    // 1. التأكد من خدمات الموقع والإذونات
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(const LocationErrorState('خدمات الموقع معطلة، يرجى تفعيل GPS.'));
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

    if (permission == LocationPermission.deniedForever) {
      emit(const LocationErrorState('الأذونات مرفوضة بشكل دائم، يرجى تفعيلها من الإعدادات.'));
      return;
    }

    _isTrackingActive = true;
    emit(TrackingStartedState());

    // 2. إعدادات الموقع (تم تصحيح الـ const ليكون final لتجنب الخطأ الذي ظهر لك)
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, // دقة عالية لضمان موقع مصر الصحيح
      distanceFilter: 5,               // التحديث كل 5 أمتار حركة
    );

    // 3. بدء الاستماع لبث الموقع (Stream)
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) async {
      
      // التأكد من أن الإحداثيات ليست صفرية
      if (position.latitude != 0 && position.longitude != 0) {
        final geoPoint = GeoPoint(position.latitude, position.longitude);
        
        // تحديث Firebase في الخلفية
        await _authRepo.updateUserLocation(userUid, geoPoint);
        
        // تحديث الحالة الداخلية إذا كان الكيوبيت لا يزال مفتوحاً
        if (!isClosed) {
          emit(LocationUpdatedState(geoPoint));
        }
        
        print("تم تحديث الموقع الفعلي في مصر: ${position.latitude}, ${position.longitude}");
      }
    }, onError: (e) {
      emit(LocationErrorState('حدث خطأ أثناء التتبع: ${e.toString()}'));
      _stopLocationTracking(); // إيقاف التتبع في حالة حدوث خطأ مستمر
    });
  }

  // دالة إيقاف التتبع
  void _stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isTrackingActive = false;
    emit(TrackingStoppedState());
  }

  // دالة التبديل (تشغيل/إيقاف) المرتبطة بالزر
  void toggleTracking(String userUid) {
    print("Toggle Tracking for UID: $userUid");
    if (_isTrackingActive) {
      _stopLocationTracking();
    } else {
      _startLocationTracking(userUid);
    }
  }
}