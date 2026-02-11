import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracing_app_new/feature/auth/data/repo/auth_repo.dart';
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

  void _startLocationTracking(String userUid) async {
    if (_isTrackingActive) return;

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

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, 
      distanceFilter: 5,               
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) async {
      
      if (position.latitude != 0 && position.longitude != 0) {
        final geoPoint = GeoPoint(position.latitude, position.longitude);
        
        await _authRepo.updateUserLocation(userUid, geoPoint);
        
        if (!isClosed) {
          emit(LocationUpdatedState(geoPoint));
        }
        
        print("تم تحديث الموقع الفعلي في مصر: ${position.latitude}, ${position.longitude}");
      }
    }, onError: (e) {
      emit(LocationErrorState('حدث خطأ أثناء التتبع: ${e.toString()}'));
      _stopLocationTracking(); 
    });
  }

  void _stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isTrackingActive = false;
    emit(TrackingStoppedState());
  }

  void toggleTracking(String userUid) {
    print("Toggle Tracking for UID: $userUid");
    if (_isTrackingActive) {
      _stopLocationTracking();
    } else {
      _startLocationTracking(userUid);
    }
  }
}