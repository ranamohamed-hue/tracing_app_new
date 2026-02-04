import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class LocationState extends Equatable {
  const LocationState();
  
  @override
  List<Object> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoadingState extends LocationState {}

class LocationUpdatedState extends LocationState {
  final GeoPoint location;
  const LocationUpdatedState(this.location);

  @override
  List<Object> get props => [location];
}

class LocationErrorState extends LocationState {
  final String error;
  const LocationErrorState(this.error);

  @override
  List<Object> get props => [error];
}

class TrackingStartedState extends LocationState {}

class TrackingStoppedState extends LocationState {}