import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tracing_app_new/feature/auth/cubit/child_tracing_cubit.dart';
// *** التعديل 1: استيراد ملف الحالات الصحيح ***
import 'package:tracing_app_new/feature/auth/cubit/child_tracing_state.dart';

class ChildMapWidget extends StatefulWidget {
  // *** التعديل: إعادة إضافة childUid ***
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

  // *** التعديل 3: إزالة initState و dispose لأن الودجت لم يعد يتحكم في التتبع ***
  // @override
  // void initState() { ... }
  // @override
  // void dispose() { ... }

  @override
  Widget build(BuildContext context) {
    // *** التعديل 4: تصحيح نوع الحالة في BlocBuilder ***
    return BlocBuilder<ChildTrackingCubit, ChildTrackingState>(
      builder: (context, state) {
        // 1. حالة التحميل
        if (state is ChildLocationLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. حالة الخطأ
        if (state is ChildLocationErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('خطأ في جلب الموقع: ${state.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // نطلب من الصفحة الأب إعادة المحاولة
                    context.read<ChildTrackingCubit>().startTrackingChild(widget.childUid);
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        // 3. حالة وجود تحديث للموقع
        if (state is ChildLocationUpdatedState) {
          final childLocation = state.location;

          // حرك الخريطة إلى الموقع الجديد في كل تحديث
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
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: childLocation,
                    width: 80,
                    height: 80,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.person_pin_circle,
                          color: Colors.red,
                          size: 40,
                        ),
                        Text(
                          widget.childName,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        // 4. حالة افتراضية (قبل بدء التتبع)
        return const Center(child: Text('اضغط على "بدء التتبع" لعرض الموقع.'));
      },
    );
  }
}