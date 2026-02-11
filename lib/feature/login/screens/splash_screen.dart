import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// تأكدي من استيراد الـ AuthWrapper أو الصفحة التالية بشكل صحيح
import 'package:tracing_app_new/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;
  bool _videoEnded = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // تهيئة الفيديو مع معالجة مشكلة اللون الأسود
    _videoController = VideoPlayerController.asset('assets/introsplash.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _videoController.play();
          _videoController.setLooping(false);
        }

        // Listener للانتقال بعد انتهاء الفيديو
        _videoController.addListener(() {
          final bool isFinished =
              _videoController.value.position >=
              _videoController.value.duration;
          if (isFinished && !_videoEnded) {
            _videoEnded = true;
            _handleAppStartupLogics();
          }
        });
      });
  }

  // منطق بدء التطبيق بعد انتهاء الفيديو
  Future<void> _handleAppStartupLogics() async {
    // 1. طلب الصلاحيات الأساسية
    await [
      Permission.camera,
      Permission.microphone,
      Permission.notification,
      Permission.locationWhenInUse,
    ].request();

    // 2. صلاحية الظهور فوق التطبيقات (Overlay) - مهمة جداً للـ CallCubit
    if (await Permission.systemAlertWindow.isDenied) {
      await _showOverlayPermissionDialog();
    }

    _navigateToSignIn();
  }

  Future<void> _showOverlayPermissionDialog() async {
    bool permissionGranted = false;
    Timer(const Duration(seconds: 5), () {
      if (!permissionGranted && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        title: Text(
          "صلاحية هامة",
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "لتتمكن من استقبال المكالمات بشكل صحيح، يرجى تفعيل 'الظهور فوق التطبيقات'.",
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              permissionGranted = true;
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text("تفعيل الآن"),
          ),
        ],
      ),
    );
  }

  void _navigateToSignIn() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthWrapper(),
        transitionDuration: const Duration(seconds: 1),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // يطابق الـ XML بتاعك
      body: Stack(
        fit: StackFit.expand,
        children: [
          // الطبقة الأولى: الخلفية واللوجو (نفس شكل الـ Native Splash تماماً)
          Positioned.fill(
            child: Image.asset(
              'assets/logoo.png',
              fit: BoxFit.cover, // يملأ الشاشة مع الحفاظ على الأبعاد
            ),
          ),
          // الطبقة الثانية: الفيديو بيظهر بـ Fade ناعم فوق اللوجو
          AnimatedOpacity(
            opacity: _isInitialized ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 400),
            child: _isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  )
                : const SizedBox.expand(),
          ),
        ],
      ),
    );
  }
}
