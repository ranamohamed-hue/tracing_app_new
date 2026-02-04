import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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

        // الانتقال بعد انتهاء الفيديو
        Future.delayed(_logo.value.duration, () {
          if (!mounted) return; // لو ال widget مش موجودة خلاص
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
        });
      });
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
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
    );
  }
}
