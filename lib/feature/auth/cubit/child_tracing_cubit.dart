import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracing_app_new/feature/auth/data/repo/auth_repo.dart';
import 'package:tracing_app_new/feature/auth/cubit/child_tracing_state.dart';

class ChildTrackingCubit extends Cubit<ChildTrackingState> {
  final AuthRepo _authRepo;
  StreamSubscription<GeoPoint>? _childLocationSubscription;

  ChildTrackingCubit(this._authRepo) : super(ChildTrackingInitial());

  @override
  Future<void> close() {
    _childLocationSubscription?.cancel();
    return super.close();
  }

  void startTrackingChild(String childUid) {
    emit(ChildLocationLoadingState());
    _childLocationSubscription?.cancel();

    _childLocationSubscription = _authRepo.getChildLocationStream(childUid).listen(
      (geoPointLocation) {
        final latLngLocation = LatLng(geoPointLocation.latitude, geoPointLocation.longitude);
        emit(ChildLocationUpdatedState(latLngLocation));
      },
      onError: (error) {
        emit(ChildLocationErrorState(error.toString()));
      },
    );
  }

  void stopTrackingChild() {
    _childLocationSubscription?.cancel();
    _childLocationSubscription = null;
    emit(ChildTrackingInitial());
  }
}