import 'package:flutter/material.dart';

class Logo extends StatefulWidget {
  const Logo({super.key});

  @override
  State<Logo> createState() => _LogoState();
}

class _LogoState extends State<Logo> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          Icons.location_on,
          color: const Color.fromARGB(255, 18, 18, 19),
          size: 50.0,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Icon(
            Icons.directions_walk,
            color: const Color.fromARGB(221, 233, 232, 232),
            size: 50.0,
          ),
        ),
      ],
    );
  }
}
