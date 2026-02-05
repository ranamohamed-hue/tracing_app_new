// lib/feature/parent/screens/parent_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // *** أضف هذا السطر ***
import 'package:tracing_app_new/core/theming/app_styles.dart';
import 'package:tracing_app_new/feature/parent/screens/home_page.dart'; // صفحة لوحة التحكم
import 'package:tracing_app_new/feature/parent/screens/children_page.dart';
import 'package:tracing_app_new/feature/parent/screens/notification_page.dart';
import 'package:tracing_app_new/feature/parent/screens/profile_bage.dart';
import 'package:tracing_app_new/feature/auth/cubit/children_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_state.dart';

class ParentPage extends StatefulWidget {
  const ParentPage({super.key});

  @override
  State<ParentPage> createState() => _ParentPageState();
}

class _ParentPageState extends State<ParentPage> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchChildren();
    });
  }

  void _fetchChildren() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthenticatedState) {
      context.read<ChildrenCubit>().fetchChildren(authState.userModel.uid);
    }
  }

  void onItemTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // *** التعديل: تحديث قائمة الصفحات لتشمل كل الصفحات ***
    final pages = [
      const HomePage(),      // 0: لوحة التحكم
      const ChildrenPage(),  // 1: إدارة الأبناء
      const NotificationPage(), // 2: الإشعارات
      const ProfileBage(),   // 3: الملف الشخصي
    ];

    return Scaffold(
      body: Container(
        decoration: AppStyles.primaryGradientDecoration,
        child: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color.fromARGB(255, 178, 198, 211),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(blurRadius: 5, offset: Offset(0, 3)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              // *** التعديل: تحديث أيقونات وشريط التنقل ***
              children: [
                _navItem(Icons.home, 0, "الرئيسية"),
                _navItem(Icons.people, 1, "الأبناء"),
                _navItem(Icons.notifications, 2, "الإشعارات"),
                _navItem(Icons.person, 3, "الملف الشخصي"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // *** تعديل: إضافة تسمية توضيحية للأيقونات ***
  Widget _navItem(IconData icon, int index, String tooltip) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onItemTap(index),
      borderRadius: BorderRadius.circular(30),
      child: Tooltip(
        message: tooltip,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? const Color.fromARGB(255, 217, 218, 219)
                : Colors.transparent,
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
            size: 25,
          ),
        ),
      ),
    );
  }
}