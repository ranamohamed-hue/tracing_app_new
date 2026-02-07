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

// ... الاستيرادات كما هي

class _ChildMapWidgetState extends State<ChildMapWidget> {
  final MapController _mapController = MapController();
  final LatLng egyptFallback = const LatLng(30.0444, 31.2357);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildTrackingCubit, ChildTrackingState>(
      builder: (context, state) {
        if (state is ChildLocationLoadingState) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }

        if (state is ChildLocationErrorState) {
          return _buildErrorWidget(state.error);
        }

        if (state is ChildLocationUpdatedState) {
          final childLocation = state.location;

          // 1. فحص جودة الإحداثيات
          bool isLocationValid =
              childLocation.latitude != 0 && childLocation.longitude != 0;

          // 2. فحص المسافة (صمام الأمان لمصر)
          // إذا كانت الإحداثيات خارج حدود مصر (مثلاً واشنطن 38)، نعتبرها "بعيدة"
          final bool isWayOff =
              childLocation.latitude > 35 || childLocation.latitude < 22;

          if (!isLocationValid) {
            return const Center(child: Text("بانتظار إشارة GPS دقيقة..."));
          }

          // 3. تحريك الكاميرا (هنا يتم استخدام المنطق الجديد)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (isWayOff) {
              // إذا كانت الإحداثيات القادمة من فيربيز خاطئة أو بعيدة جداً، ابقَ في مصر
              _mapController.move(egyptFallback, 12.0);
            } else {
              // إذا كانت الإحداثيات في مصر (كما فعلتِ في فيربيز)، اذهب إليها
              _mapController.move(childLocation, 16.0);
            }
          });

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // البدء بموقع مصر الافتراضي إذا كان الموقع القادم من فيربيز غير منطقي
              initialCenter: isWayOff ? egyptFallback : childLocation,
              initialZoom: isWayOff ? 12.0 : 16.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.tracing_app',
              ),
              // أظهري الماركر فقط إذا كانت الإحداثيات داخل النطاق المصري الصحيح
              if (!isWayOff)
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
