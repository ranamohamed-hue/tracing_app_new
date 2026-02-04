import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

// تجريد للحالات الأساسية لتتبع الطفل
abstract class ChildTrackingState extends Equatable {
  const ChildTrackingState();
  
  @override
  List<Object> get props => [];
}

// الحالة الأولية
class ChildTrackingInitial extends ChildTrackingState {}

// حالة التحميل
class ChildLocationLoadingState extends ChildTrackingState {}

// حالة تحديث الموقع بنجاح
class ChildLocationUpdatedState extends ChildTrackingState {
  final LatLng location;
  const ChildLocationUpdatedState(this.location);

  @override
  List<Object> get props => [location];
}

// حالة حدوث خطأ
class ChildLocationErrorState extends ChildTrackingState {
  final String error;
  const ChildLocationErrorState(this.error);

  @override
  List<Object> get props => [error];
}