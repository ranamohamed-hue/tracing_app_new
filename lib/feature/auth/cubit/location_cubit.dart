import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracing_app_new/feature/auth/data/repo/auth_repo.dart';
// *** استيراد ملف الحالات المخصص للموقع ***
import 'package:tracing_app_new/feature/auth/cubit/location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final AuthRepo _authRepo;
  Timer? _locationTimer;
  bool _isTrackingActive = false;

  LocationCubit(this._authRepo) : super(LocationInitial());

  @override
  Future<void> close() {
    _locationTimer?.cancel();
    return super.close();
  }

  Future<void> updateMyLocation(String userUid) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(const LocationErrorState('خدمات الموقع معطلة. يرجى تفعيلها.'));
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
    
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final geoPoint = GeoPoint(position.latitude, position.longitude);
    
    final result = await _authRepo.updateUserLocation(userUid, geoPoint);
    result.fold(
      (error) => emit(LocationErrorState(error)),
      (_) => emit(LocationUpdatedState(geoPoint)),
    );
  }

  void _startLocationTracking(String userUid) {
    if (_isTrackingActive) return;
    _isTrackingActive = true;
    emit(TrackingStartedState());
    updateMyLocation(userUid);
    _locationTimer = Timer.periodic(const Duration(seconds: 30), (timer) => updateMyLocation(userUid));
  }

  void _stopLocationTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _isTrackingActive = false;
    emit(TrackingStoppedState());
  }

  void toggleTracking(String userUid) {
    if (_isTrackingActive) {
      _stopLocationTracking();
    } else {
      _startLocationTracking(userUid);
    }
  }
}