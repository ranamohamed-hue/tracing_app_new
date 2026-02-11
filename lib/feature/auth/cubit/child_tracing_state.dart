import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class ChildTrackingState extends Equatable {
  const ChildTrackingState();
  
  @override
  List<Object> get props => [];
}

class ChildTrackingInitial extends ChildTrackingState {}

class ChildLocationLoadingState extends ChildTrackingState {}

class ChildLocationUpdatedState extends ChildTrackingState {
  final LatLng location;
  const ChildLocationUpdatedState(this.location);

  @override
  List<Object> get props => [location];
}

class ChildLocationErrorState extends ChildTrackingState {
  final String error;
  const ChildLocationErrorState(this.error);

  @override
  List<Object> get props => [error];
}