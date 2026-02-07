import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ✅ إضافة المكتبة
import 'package:tracing_app_new/core/theming/app_styles.dart';
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
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
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
                // ✅ صورة البروفايل الدائرية بمقاسات مرنة
                Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 55.r, // ✅ نصف قطر مرن
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 60.r, // ✅ حجم أيقونة مرن
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                
                // ✅ اسم المستخدم
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp, // ✅ حجم خط مرن
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                // ✅ الإيميل
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16.sp,
                  ),
                ),
                
                SizedBox(height: 60.h), // ✅ مسافة مرنة قبل الزر

                // ✅ زر تسجيل الخروج
                _buildLogoutButton(context, state is LogoutLoadingState),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isLoading) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w), // ✅ بادينج عرضي مرن
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.15),
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 55.h), // ✅ ارتفاع مرن للزر
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r), // ✅ زوايا مرنة
            side: const BorderSide(color: Colors.white30),
          ),
        ),
        onPressed: isLoading ? null : () => _showConfirmDialog(context),
        child: isLoading
            ? SizedBox(
                height: 20.r,
                width: 20.r,
                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, size: 22.r),
                  SizedBox(width: 12.w),
                  Text(
                    "تسجيل الخروج",
                    style: TextStyle(
                      fontSize: 18.sp, 
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          "تنبيه", 
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "هل تريد تسجيل الخروج من الحساب؟", 
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 15.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء", style: TextStyle(fontSize: 14.sp)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
            },
            child: Text(
              "تأكيد", 
              style: TextStyle(color: Colors.red, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}