import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ✅ استيراد المكتبة
import 'package:latlong2/latlong.dart';

// الأساسيات
import 'package:tracing_app_new/core/widgets/appbar_part.dart';
import 'package:tracing_app_new/feature/auth/data/models/user_model.dart';
import 'package:tracing_app_new/feature/auth/data/repo/auth_repo.dart';

// --- تعديل الـ Call Repo لمنع التضارب ---
import 'package:tracing_app_new/feature/auth/data/repo/call_repo.dart'
    hide MeetingStatus;

// الـ Cubits والـ States
import 'package:tracing_app_new/feature/auth/cubit/child_tracing_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/call_cubitt/call_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/call_cubitt/call_state.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_state.dart';

// الـ Widgets
import 'package:tracing_app_new/feature/parent/widgets/action_button.dart';
import 'package:tracing_app_new/feature/parent/widgets/child_map_widget.dart';

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

    // إحداثيات مركز القاهرة (مصر)
    const double egyptLat = 30.0444;
    const double egyptLng = 31.2357;

    // إضافة تغيير طفيف جداً (حوالي 100-500 متر) لكي تلاحظي حركة الماركر على الخريطة
    final double latVariation = (random.nextDouble() - 0.5) * 0.005;
    final double lngVariation = (random.nextDouble() - 0.5) * 0.005;

    final fakeLocation = LatLng(
      egyptLat + latVariation,
      egyptLng + lngVariation,
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
                  'تم تحديث موقع ${widget.child.username} إلى القاهرة (محاكاة)',
                  style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo'),
                ),
                backgroundColor:
                    Colors.green, // غيرت اللون للأخضر ليدل على النجاح
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        })
        .catchError((error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ في التحديث: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
  }

  void _showCallOptionsDialog() {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthenticatedState) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.r),
            ), // ✅ راديوس مرن
            title: Text(
              "اختر نوع المكالمة",
              style: TextStyle(fontSize: 18.sp),
            ), // ✅ نص مرن
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.video_call,
                    color: Colors.blue,
                    size: 28.r,
                  ), // ✅ أيقونة مرنة
                  title: Text(
                    "مكالمة فيديو",
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.read<CallCubit>().startMeeting(
                      currentUser: authState.userModel,
                      isVideoCall: true,
                      calleeId: widget.child.uid,
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.call, color: Colors.green, size: 28.r),
                  title: Text(
                    "مكالمة صوتية",
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.read<CallCubit>().startMeeting(
                      currentUser: authState.userModel,
                      isVideoCall: false,
                      calleeId: widget.child.uid,
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallCubit, CallState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage!,
                style: TextStyle(fontSize: 14.sp),
              ),
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
                // 1. الخريطة (تأخذ كامل المساحة المتاحة)
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
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25.r), // ✅ زوايا علوية مرنة
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10.r,
                            spreadRadius: 2.r,
                          ),
                        ],
                      ),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: ListView(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(
                            vertical: 10.h,
                          ), // ✅ بادينج مرن
                          children: [
                            Center(
                              child: Container(
                                width: 50.w, // ✅ عرض مقبض السحب مرن
                                height: 5.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                            ListTile(
                              title: Text(
                                widget.child.username,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp, // ✅ اسم الطفل مرن
                                ),
                              ),
                              subtitle: Text(
                                _isTracking
                                    ? "بث مباشر للموقع"
                                    : "التتبع متوقف",
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              trailing: Icon(
                                Icons.circle,
                                color: _isTracking ? Colors.green : Colors.grey,
                                size: 12.r,
                              ),
                            ),
                            const Divider(),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 15.h,
                              ), // ✅ مسافات رأسية مرنة
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
                                  if (callState.status ==
                                      MeetingStatus.connecting)
                                    ActionButton(
                                      icon: Icons.phone_in_talk,
                                      label: "جاري الاتصال...",
                                      onPressed: () {},
                                    )
                                  else
                                    ActionButton(
                                      icon: Icons.call,
                                      label: "اتصال",
                                      onPressed: _showCallOptionsDialog,
                                    ),
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
