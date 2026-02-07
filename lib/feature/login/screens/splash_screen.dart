import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ✅ إضافة المكتبة
import 'package:tracing_app_new/feature/login/screens/sign_in_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _logo;

  @override
  void initState() {
    super.initState();

    _logo = VideoPlayerController.asset('assets/videosplash.mp4')
      ..initialize().then((_) {
        _logo.play();
        _logo.setLooping(false);
        setState(() {});

        _handleAppStartupLogics();
      });
  }

  Future<void> _handleAppStartupLogics() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.notification,
      Permission.locationWhenInUse,
    ].request();

    if (await Permission.systemAlertWindow.isDenied) {
      if (mounted) {
        await _showOverlayPermissionDialog();
      }
    }

    // الانتظار حتى انتهاء الفيديو
    await Future.delayed(_logo.value.duration);
    
    _navigateToSignIn();
  }

  Future<void> _showOverlayPermissionDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r), // ✅ زوايا مرنة للديالوج
        ),
        title: Text(
          "صلاحية هامة",
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold), // ✅ نص مرن
        ),
        content: Text(
          "لتتمكن من استقبال المكالمات حتى لو الموبايل مقفول، يرجى تفعيل 'الظهور فوق التطبيقات' في الصفحة التالية.",
          style: TextStyle(fontSize: 16.sp), // ✅ نص مرن
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h), // ✅ بادينج مرن للزر
            ),
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: Text("تفعيل الآن", style: TextStyle(fontSize: 14.sp)),
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
        pageBuilder: (context, animation, secondaryAnimation) => const SignInPage(),
        transitionDuration: const Duration(seconds: 1),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _logo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _logo.value.isInitialized
          ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _logo.value.size.width,
                  height: _logo.value.size.height,
                  child: VideoPlayer(_logo),
                ),
              ),
            )
          : Container(
              color: const Color.fromARGB(255, 32, 23, 163),
              child: Center(
                child: SizedBox(
                  width: 50.r, // ✅ حجم ثابت متناسق لللودينج
                  height: 50.r,
                  child: const CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
    );
  }
}