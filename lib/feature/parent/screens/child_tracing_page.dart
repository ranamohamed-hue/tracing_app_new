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
import 'package:tracing_app_new/feature/auth/cubit/child_tracing_state.dart';
import 'package:latlong2/latlong.dart';

class ChildTracingPage extends StatefulWidget {
  final UserModel child;

  const ChildTracingPage({super.key, required this.child});

  @override
  State<ChildTracingPage> createState() => _ChildTracingPageState();
}

class _ChildTracingPageState extends State<ChildTracingPage> {
  // متغير محلي لتتبع حالة التتبع (لتحديث واجهة المستخدم فقط)
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    // عند إنشاء الصفحة، ابدأ التتبع تلقائيًا
    _startTracking();
  }

  @override
  void dispose() {
    // عند إغلاق الصفحة، من الضروري جدًا إيقاف التتبع
    // لتجنب استهلاك البطارية والبيانات وتسرب الذاكرة
    _stopTracking();
    super.dispose();
  }

  // دالة لبدء التتبع
  void _startTracking() {
    if (!_isTracking) {
      setState(() {
        _isTracking = true;
      });
      // استدعاء الكيوبت لبدء الاستماع إلى تحديثات موقع الطفل
      context.read<ChildTrackingCubit>().startTrackingChild(widget.child.uid);
    }
  }

  // دالة لإيقاف التتبع
  void _stopTracking() {
    if (_isTracking) {
      setState(() {
        _isTracking = false;
      });
      // استدعاء الكيوبت لإيقاف الاستماع
      context.read<ChildTrackingCubit>().stopTrackingChild();
    }
  }

  // دالة لمحاكاة تحديث موقع الطفل (لأغراض الاختبار)
  void _simulateChildLocation() {
    final random = Random();
    final fakeLocation = LatLng(
      24.7136 + random.nextDouble() * 0.01, // بالقرب من الرياض
      46.6753 + random.nextDouble() * 0.01,
    );

    // تحديث الموقع مباشرة في Firestore
    context.read<AuthRepo>().updateUserLocation(
      widget.child.uid,
      GeoPoint(fakeLocation.latitude, fakeLocation.longitude),
    ).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال موقع محاكي للطفل!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppbarPart(title: "موقع ${widget.child.username}"),
      body: Stack(
        children: [
          // ويدجت الخريطة الذي يستمع إلى الكيوبت ويعرض التحديثات
 ChildMapWidget(
            childUid: widget.child.uid,
            childName: widget.child.username,
          ),
          // اللوحة السفلية القابلة للسحب
          DraggableScrollableSheet(
            initialChildSize: 0.25, // ارتفاع أولي
            minChildSize: 0.2, // أقل ارتفاع
            maxChildSize: 0.7, // أقصى ارتفاع
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: ListView(
                    controller: scrollController,
                    children: [
                      // شريط السحب المرئي
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: theme.dividerColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      // رأس اللوحة
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.child.username,
                              style: textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              _isTracking ? "جاري التتبع" : "متوقف",
                              style: textTheme.bodyMedium?.copyWith(
                                color: _isTracking ? Colors.orange : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // الأزرار الإجرائية
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // زر التحكم في التتبع
                                ActionButton(
                                  icon: _isTracking ? Icons.stop : Icons.play_arrow,
                                  label: _isTracking ? "إيقاف التتبع" : "بدء التتبع",
                                  onPressed: () {
                                    if (_isTracking) {
                                      _stopTracking();
                                    } else {
                                      _startTracking();
                                    }
                                  },
                                ),
                                ActionButton(
                                  icon: Icons.chat_bubble_outline,
                                  label: "رسالة",
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('فتح شاشة الرسائل...')),
                                    );
                                  },
                                ),
                                ActionButton(
                                  icon: Icons.notifications_outlined,
                                  label: "التنبيهات",
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('فتح إعدادات التنبيهات...')),
                                    );
                                  },
                                ),
                                // زر محاكاة الموقع (للاختبار)
                                ActionButton(
                                  icon: Icons.play_circle,
                                  label: "محاكاة",
                                  onPressed: _simulateChildLocation,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "سجل اليوم",
                              style: textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
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