import 'package:flutter/material.dart';

class AppbarPart extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const AppbarPart({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,

      toolbarHeight: 120.0,
      backgroundColor: Colors.transparent,
      elevation: 0,

      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ),
          const SizedBox(width: 80),

          SizedBox(
            height: 100,
            width: 70,
            child: Image.asset("assets/logoi.png"),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(120.0);
}
