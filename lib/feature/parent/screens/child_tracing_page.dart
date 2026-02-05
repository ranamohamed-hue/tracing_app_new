import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracing_app_new/core/widgets/appbar_part.dart';
import 'package:tracing_app_new/feature/auth/data/models/user_model.dart';
import 'package:tracing_app_new/feature/auth/data/repo/auth_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracing_app_new/feature/auth/data/repo/call_repo.dart';
import 'package:tracing_app_new/feature/parent/widgets/action_button.dart';
import 'package:tracing_app_new/feature/parent/widgets/child_map_widget.dart';
import 'package:tracing_app_new/feature/auth/cubit/child_tracing_cubit.dart';
// --- الإضافات الجديدة للربط ---
import 'package:tracing_app_new/feature/auth/cubit/call_cubitt/call_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/call_cubitt/call_state.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_state.dart';
// -------------------------
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
    _startTracking();
  }

  @override
  void dispose() {
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

  void _simulateChildLocation() {
    final random = Random();
    final fakeLocation = LatLng(
      30.0444 + random.nextDouble() * 0.01,
      31.2357 + random.nextDouble() * 0.01,
    );

    context
        .read<AuthRepo>()
        .updateUserLocation(
          widget.child.uid,
          GeoPoint(fakeLocation.latitude, fakeLocation.longitude),
        )
        .then((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم تحديث موقع ${widget.child.username} (محاكاة)',
                ),
                backgroundColor: Colors.blueAccent,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        });
  }

  // === الإضافة الجديدة: دالة لعرض خيارات الاتصال ===
  void _showCallOptionsDialog() {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthenticatedState)
      return; // تأكد من أن المستخدم مسجل دخوله

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text("اختر نوع المكالمة"),
            content: Column(
              mainAxisSize:
                  MainAxisSize.min, // يجعل حجم الـ Dialog يتناسب مع المحتوى
              children: [
                ListTile(
                  leading: const Icon(Icons.video_call, color: Colors.blue),
                  title: const Text("مكالمة فيديو"),
                  onTap: () {
                    Navigator.of(context).pop(); // إغلاق الـ Dialog
                    // استدعاء المكالمة مع isVideoCall = true
                    context.read<CallCubit>().startMeeting(
                      currentUser: authState.userModel,
                      isVideoCall: true,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.call, color: Colors.green),
                  title: const Text("مكالمة صوتية"),
                  onTap: () {
                    Navigator.of(context).pop(); // إغلاق الـ Dialog
                    // استدعاء المكالمة مع isVideoCall = false
                    context.read<CallCubit>().startMeeting(
                      currentUser: authState.userModel,
                      isVideoCall: false,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // =============================================

  @override
  Widget build(BuildContext context) {
    // استخدمنا BlocListener هنا عشان لو حصل مشكلة في الاتصال تظهر رسالة
    return BlocListener<CallCubit, CallState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<CallCubit, CallState>(
        builder: (context, callState) {
          return Scaffold(
            appBar: AppbarPart(title: "تتبع ${widget.child.username}"),
            body: Stack(
              children: [
                // 1. الخريطة
                ChildMapWidget(
                  childUid: widget.child.uid,
                  childName: widget.child.username,
                ),

                // 2. اللوحة السفلية
                DraggableScrollableSheet(
                  initialChildSize: 0.28,
                  minChildSize: 0.15,
                  maxChildSize: 0.6,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          children: [
                            Center(
                              child: Container(
                                width: 50,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),

                            ListTile(
                              title: Text(
                                widget.child.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Text(
                                _isTracking
                                    ? "بث مباشر للموقع"
                                    : "التتبع متوقف",
                              ),
                              trailing: Icon(
                                Icons.circle,
                                color: _isTracking ? Colors.green : Colors.grey,
                                size: 12,
                              ),
                            ),

                            const Divider(),

                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ActionButton(
                                    icon: _isTracking
                                        ? Icons.location_disabled
                                        : Icons.location_searching,
                                    label: _isTracking ? "إيقاف" : "تتبع",
                                    onPressed: () => _isTracking
                                        ? _stopTracking()
                                        : _startTracking(),
                                  ),

                                  // === منطق زر الاتصال المتغير ===
                                  if (callState.status ==
                                      MeetingStatus.connecting)
                                    ActionButton(
                                      icon: Icons.phone_in_talk,
                                      label: "جاري الاتصال...",
                                      onPressed: () {}, // الزارار معطل
                                    )
                                  else
                                    ActionButton(
                                      icon: Icons.call, // أيقونة اتصال عامة
                                      label: "اتصال", // نص عام
                                      onPressed:
                                          _showCallOptionsDialog, // === استدعاء الدالة الجديدة ===
                                    ),

                                  // ==================
                                  ActionButton(
                                    icon: Icons.vibration,
                                    label: "تنبيه",
                                    onPressed: () {},
                                  ),
                                  ActionButton(
                                    icon: Icons.bug_report_outlined,
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
        },
      ),
    );
  }
}
