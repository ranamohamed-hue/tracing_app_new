import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracing_app_new/core/theming/app_styles.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_state.dart';

class ProfileBage extends StatelessWidget {
  const ProfileBage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // استخدام الـ Container عشان نطبق الـ Gradient بتاعك في الخلفية
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppStyles.primaryGradientDecoration,
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            // لو تم تسجيل الخروج بنجاح ورجعت الحالة للبداية
            if (state is AuthInitialState) {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            }
            // إظهار خطأ لو فشل الخروج
            if (state is LogoutErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error), backgroundColor: Colors.red),
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
                // صورة البروفايل الدائرية
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF1A237E), // لون داكن يليق مع الجراديانت
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // اسم المستخدم (يفضل استخدام ستايل من ملف الثيم هنا)
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                // الإيميل
                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                
                const SizedBox(height: 60),

                // زر تسجيل الخروج
                _buildLogoutButton(context, state is LogoutLoadingState),
              ],
            );
          },
        ),
      ),
    );
  }

  // ميثود بناء زر تسجيل الخروج بتصميم متناسق
  Widget _buildLogoutButton(BuildContext context, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.15),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 55),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Colors.white30),
          ),
        ),
        onPressed: isLoading ? null : () => _showConfirmDialog(context),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded),
                  SizedBox(width: 12),
                  Text(
                    "تسجيل الخروج",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  // ديالوج تأكيد الخروج بالعربي
  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("تنبيه", textAlign: TextAlign.right),
        content: const Text("هل تريد تسجيل الخروج من الحساب؟", textAlign: TextAlign.right),
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