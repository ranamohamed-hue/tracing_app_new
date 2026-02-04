// lib/core/app_styles.dart

import 'package:flutter/material.dart';

class AppStyles {
  static const BoxDecoration primaryGradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
      Color.fromARGB(6, 13, 15, 117),
         Color.fromARGB(255, 178, 198, 211),
      ],
    ),
  );
}