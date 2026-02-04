import 'package:flutter/material.dart';
import 'package:tracing_app_new/core/theming/app_styles.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(constraints: const BoxConstraints.expand(),
        decoration: AppStyles.primaryGradientDecoration,
        child: Center(child: Text("التنبيهات "),),
      ),
    );
  }
}