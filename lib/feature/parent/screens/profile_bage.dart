import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tracing_app_new/core/theming/app_styles.dart';
import 'package:tracing_app_new/core/theming/logic/theme_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_state.dart';

class ProfileBage extends StatelessWidget {
  const ProfileBage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppStyles.primaryGradientDecoration,
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthInitialState) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (route) => false);
            }
            if (state is LogoutErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error, style: TextStyle(fontSize: 14.sp)),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            String name = "مستخدم";
            String email = "";

            if (state is AuthenticatedState) {
              name = state.userModel.username;
              email = state.userModel.email;
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildThemeTile(context),
                SizedBox(height: 30.h),

                Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 55.r,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 60.r,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(color: Colors.white70, fontSize: 16.sp),
                ),

                SizedBox(height: 40.h),

                _buildLogoutButton(context, state is LogoutLoadingState),
              ],
            );
          },
        ),
      ),
    );
  }

  // (بقية الـ Widgets كما هي في كودك الأصلي...)
  Widget _buildThemeTile(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: isDarkMode ? Colors.amberAccent : Colors.white,
                  size: 22.r,
                ),
                SizedBox(width: 12.w),
                const Text(
                  "الوضع الليلي",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Switch(
              value: isDarkMode,
              activeColor: Colors.amberAccent,
              onChanged: (value) => context.read<ThemeCubit>().toggleTheme(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isLoading) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.15),
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 55.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
            side: const BorderSide(color: Colors.white30),
          ),
        ),
        onPressed: isLoading ? null : () => _showConfirmDialog(context),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded),
                  SizedBox(width: 12),
                  Text("تسجيل الخروج"),
                ],
              ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تنبيه", textAlign: TextAlign.right),
        content: const Text(
          "هل تريد تسجيل الخروج؟",
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
            },
            child: const Text("تأكيد", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
