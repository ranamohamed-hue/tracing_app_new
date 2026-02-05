import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracing_app_new/core/widgets/appbar_part.dart';
import 'package:tracing_app_new/feature/auth/data/models/user_model.dart';
import 'package:tracing_app_new/feature/auth/data/repo/auth_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracing_app_new/feature/parent/widgets/action_button.dart';
import 'package:tracing_app_new/feature/parent/widgets/child_map_widget.dart';
import 'package:tracing_app_new/feature/auth/cubit/child_tracing_cubit.dart';
import 'package:latlong2/latlong.dart';

class ChildTracingPage extends StatefulWidget {
  final UserModel child;

  const ChildTracingPage({super.key, required this.child});

  @override
  State<ChildTracingPage> createState() => _ChildTracingPageState();
}

class _ChildTracingPageState extends State<ChildTracingPage> {
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    // بدء التتبع تلقائياً عند الدخول
    _startTracking();
  }

  @override
  void dispose() {
    // إيقاف التتبع عند الخروج للحفاظ على الموارد
    _stopTracking();
    super.dispose();
  }

  void _startTracking() {
    if (!_isTracking) {
      setState(() => _isTracking = true);
      context.read<ChildTrackingCubit>().startTrackingChild(widget.child.uid);
    }
  }

  void _stopTracking() {
    if (_isTracking) {
      setState(() => _isTracking = false);
      context.read<ChildTrackingCubit>().stopTrackingChild();
    }
  }

  // دالة المحاكاة (مفيدة جداً للاختبار بدون الخروج من المنزل)
  void _simulateChildLocation() {
    final random = Random();
    // إحداثيات عشوائية قريبة (يمكنك تعديلها حسب موقعك الحالي)
    final fakeLocation = LatLng(
      30.0444 + random.nextDouble() * 0.01, 
      31.2357 + random.nextDouble() * 0.01,
    );

    context.read<AuthRepo>().updateUserLocation(
      widget.child.uid,
      GeoPoint(fakeLocation.latitude, fakeLocation.longitude),
    ).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحديث موقع ${widget.child.username} (محاكاة)'),
            backgroundColor: Colors.blueAccent,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // جعل الـ AppBar شفافاً أو ملوناً حسب رغبتك
      appBar: AppbarPart(title: "تتبع ${widget.child.username}"),
      body: Stack(
        children: [
          // 1. الخريطة في الخلفية
          ChildMapWidget(
            childUid: widget.child.uid,
            childName: widget.child.username,
          ),

          // 2. اللوحة السفلية القابلة للسحب
          DraggableScrollableSheet(
            initialChildSize: 0.28,
            minChildSize: 0.15,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)
                  ],
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    children: [
                      // مقبض السحب
                      Center(
                        child: Container(
                          width: 50, height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      
                      ListTile(
                        title: Text(widget.child.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Text(_isTracking ? "بث مباشر للموقع" : "التتبع متوقف"),
                        trailing: Icon(Icons.circle, color: _isTracking ? Colors.green : Colors.grey, size: 12),
                      ),

                      const Divider(),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ActionButton(
                              icon: _isTracking ? Icons.location_disabled : Icons.location_searching,
                              label: _isTracking ? "إيقاف" : "تتبع",
                              onPressed: () => _isTracking ? _stopTracking() : _startTracking(),
                            ),
                            ActionButton(
                              icon: Icons.history,
                              label: "السجل",
                              onPressed: () {}, 
                            ),
                            ActionButton(
                              icon: Icons.vibration,
                              label: "تنبيه",
                              onPressed: () {},
                            ),
                            ActionButton(
                              icon: Icons.bug_report_outlined, // زر المحاكاة
                              label: "تجربة",
                              onPressed: _simulateChildLocation,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}