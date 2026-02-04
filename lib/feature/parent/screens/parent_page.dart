import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracing_app_new/core/theming/app_styles.dart';
import 'package:tracing_app_new/feature/parent/screens/home_page.dart';
import 'package:tracing_app_new/feature/parent/screens/notification_page.dart';
import 'package:tracing_app_new/feature/parent/screens/profile_bage.dart';
import 'package:tracing_app_new/feature/parent/screens/child_tracing_page.dart'; // *** استيراد صفحة التتبع ***
import 'package:tracing_app_new/feature/auth/cubit/auth_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_state.dart';
import 'package:tracing_app_new/feature/auth/cubit/children_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/children_state.dart'; // *** استيراد الحالة الصحيحة ***

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
    // نستخدم addPostFrameCallback لضمان أن الـ context جاهز
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchChildren();
    });
  }

  void _fetchChildren() {
    // نحصل على معرف المستخدم من AuthCubit
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthenticatedState) {
      // نستدعي fetchChildren من ChildrenCubit ونمرر له معرف المستخدم
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
    return Scaffold(
      body: Container(
        decoration: AppStyles.primaryGradientDecoration,
        // *** التعديل الرئيسي: تغيير نوع الحالة في BlocBuilder ***
        child: BlocBuilder<ChildrenCubit, ChildrenState>(
          builder: (context, state) {
            // الحالة الأولية أو التحميل
            if (state is ChildrenLoadingState || state is ChildrenInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            // حالة التحميل الناجح
            if (state is ChildrenLoadedState) {
              final pages = [
                HomePage(children: state.children),
                const NotificationPage(),
                const ProfileBage(),
              ];
              return pages[currentIndex];
            }

            // حالة الخطأ
            if (state is ChildrenErrorState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchChildren, // إعادة المحاولة
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            // أي حالة أخرى (للأمان)
            return const Center(child: Text('حدث خطأ غير متوقع.'));
          },
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
              children: [
                _navItem(Icons.home, 0),
                _navItem(Icons.notifications, 1),
                _navItem(Icons.person, 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onItemTap(index),
      borderRadius: BorderRadius.circular(30),
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
    );
  }
}