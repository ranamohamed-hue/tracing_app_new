import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tracing_app_new/feature/auth/cubit/child_tracing_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/child_tracing_state.dart';

class ChildMapWidget extends StatefulWidget {
  final String childUid;
  final String childName;

  const ChildMapWidget({
    super.key,
    required this.childUid,
    required this.childName,
  });

  @override
  State<ChildMapWidget> createState() => _ChildMapWidgetState();
}

class _ChildMapWidgetState extends State<ChildMapWidget> {
  final MapController _mapController = MapController();
  final LatLng egyptFallback = const LatLng(30.0444, 31.2357);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildTrackingCubit, ChildTrackingState>(
      builder: (context, state) {
        // 1. حالة التحميل
        if (state is ChildLocationLoadingState) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }

        // 2. حالة الخطأ
        if (state is ChildLocationErrorState) {
          return _buildErrorWidget(state.error);
        }

        // 3. حالة وجود تحديث للموقع
        if (state is ChildLocationUpdatedState) {
          final childLocation = state.location;

          // التحقق من جودة الإحداثيات (ليست 0 وليست الموقع الافتراضي القديم)
          bool isLocationValid =
              childLocation.latitude != 0 && childLocation.longitude != 0;
          if (!isLocationValid) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text("بانتظار إشارة GPS دقيقة من جهاز الطالب..."),
                ],
              ),
            );
          }

          // تحريك الكاميرا بنعومة لموقع الطالب الجديد
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(childLocation, 16.0);
          });

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: childLocation,
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.tracing_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: childLocation,
                    width: 80,
                    height: 100,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                          child: Text(
                            widget.childName,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.person_pin_circle,
                          color: Colors.red,
                          size: 45,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        // 4. الحالة الأولية
        return const Center(
          child: Text("يرجى تفعيل الموقع من جهاز الطالب أولاً"),
        );
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 50, color: Colors.red),
          const SizedBox(height: 10),
          Text('خطأ: $error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context
                .read<ChildTrackingCubit>()
                .startTrackingChild(widget.childUid),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
