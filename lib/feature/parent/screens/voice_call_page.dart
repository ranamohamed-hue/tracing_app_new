import 'package:flutter/material.dart';
import 'package:tracing_app_new/core/theming/app_styles.dart';

class VoiceCallPage extends StatefulWidget {
  const VoiceCallPage({super.key});

  @override
  State<VoiceCallPage> createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(constraints: const BoxConstraints.expand(),
        decoration: AppStyles.primaryGradientDecoration,
         child: Center(
          child: Text("مكالمة صوتية ",style:TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
        ),
      ),
    );
  }
}