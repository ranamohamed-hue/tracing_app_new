
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tracing_app_new/core/theming/app_styles.dart';
import 'package:tracing_app_new/feature/parent/screens/profile_bage.dart';
import 'package:tracing_app_new/feature/parent/screens/notification_page.dart';
import 'package:tracing_app_new/feature/student/screens/home_student_page.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  int currentIndex = 0;

  // قائمة الصفحات
  final List<Widget> pages = [
    const HomeStudentPage(),
    const NotificationPage(),
    const ProfileBage(),
  ];

  void onItemTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: AppStyles.primaryGradientDecoration,
        child: IndexedStack(index: currentIndex, children: pages),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      color: const Color.fromARGB(
        255,
        178,
        198,
        211,
      ),
      child: Container(
        height: 75.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 10.r,
              offset: Offset(0, -2.h),
              color: Colors.black12,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_rounded, 0, "الرئيسية"),
            _navItem(Icons.notifications_active_rounded, 1, "الإشعارات"),
            _navItem(Icons.person_rounded, 2, "الحساب"),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index, String label) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onItemTap(index),
      borderRadius: BorderRadius.circular(30.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 26.r,
            ),
            if (isSelected)
              Text(
                label,
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
