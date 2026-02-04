import 'package:flutter/material.dart';
import 'package:tracing_app_new/core/theming/app_styles.dart';

class ProfileBage extends StatefulWidget {
  const ProfileBage({super.key});

  @override
  State<ProfileBage> createState() => _ProfileBageState();
}

class _ProfileBageState extends State<ProfileBage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: AppStyles.primaryGradientDecoration,
        child: Center(child: Text("الملف الشخصي"))),
    );
  }
}
