import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; 
import 'package:tracing_app_new/core/theming/app_styles.dart';
import 'package:tracing_app_new/feature/parent/screens/home_page.dart';
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
    final pages = [
      const HomePage(),
      const ChildrenPage(),
      const NotificationPage(),
      const ProfileBage(),
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
              _navItem(Icons.people_alt_rounded, 1, "الأبناء"),
              _navItem(Icons.notifications_active_rounded, 2, "الإشعارات"),
              _navItem(Icons.person_rounded, 3, "الحساب"),
            ],
          ),
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
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.1) 
              : Colors.transparent,
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