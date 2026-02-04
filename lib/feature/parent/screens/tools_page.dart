import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracing_app_new/core/theming/app_styles.dart';
import 'package:tracing_app_new/core/widgets/appbar_part.dart';
import 'package:tracing_app_new/core/widgets/elevated_button_widget.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_state.dart';
import 'package:tracing_app_new/feature/auth/cubit/children_cubit.dart'; // *** استيراد ChildrenCubit ***
import 'package:tracing_app_new/feature/auth/cubit/children_state.dart'; // *** استيراد ChildrenState ***
import 'package:tracing_app_new/feature/auth/data/models/user_model.dart';
import 'package:tracing_app_new/feature/parent/screens/child_tracing_page.dart';
import 'package:tracing_app_new/feature/parent/screens/video_call_page.dart';
import 'package:tracing_app_new/feature/parent/screens/voice_call_page.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  UserModel? selectedChild;

  @override
  void initState() {
    super.initState();
    // *** تعديل: جلب الأبناء عند فتح الصفحة ***
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthenticatedState) {
        context.read<ChildrenCubit>().fetchChildren(authState.userModel.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppbarPart(title: "الأدوات العامة"),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: AppStyles.primaryGradientDecoration,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // *** تعديل: استخدام BlocBuilder منفصل لجلب اسم ولي الأمر ***
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  String parentName = 'ولي الأمر';
                  if (authState is AuthenticatedState) {
                    parentName = authState.userModel.username;
                  }
                  return Text(
                    "مرحباً : $parentName",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // *** تعديل: استخدام BlocBuilder الصحيح لجلب بيانات الأبناء ***
              Expanded(
                child: BlocBuilder<ChildrenCubit, ChildrenState>(
                  builder: (context, state) {
                    // 1. حالة التحميل
                    if (state is ChildrenLoadingState) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }

                    // 2. حالة الخطأ
                    if (state is ChildrenErrorState) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'حدث خطأ: ${state.message}',
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                final authState = context.read<AuthCubit>().state;
                                if (authState is AuthenticatedState) {
                                  context.read<ChildrenCubit>().fetchChildren(authState.userModel.uid);
                                }
                              },
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      );
                    }

                    // 3. حالة جلب البيانات بنجاح
                    if (state is ChildrenLoadedState) {
                      final children = state.children;

                      // إذا لم يكن هناك أبناء
                      if (children.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "لا يوجد أبناء مرتبطون بحسابك.",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      // إذا كان هناك أبناء، اعرض القائمة والأزرار
                      return Column(
                        children: [
                          // منطقة اختيار الطفل
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<UserModel>(
                                value: selectedChild ?? children.first,
                                isExpanded: true,
                                hint: const Text("اختر طفلاً"),
                                items: children.map((child) {
                                  return DropdownMenuItem<UserModel>(
                                    value: child,
                                    child: Text(child.username),
                                  );
                                }).toList(),
                                onChanged: (UserModel? newChild) {
                                  setState(() {
                                    selectedChild = newChild;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // زر عرض الموقع الجغرافي
                          ElevatedButtonWidget(
                            onpress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChildTracingPage(child: selectedChild ?? children.first),
                                ),
                              );
                            },
                            title: "عرض الموقع الجغرافي",
                            icon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 40),
                          Row(
                            children: [
                              // *** تعديل: تمرير الطفل المختار إلى صفحة المكالمة ***
                              ElevatedButtonWidget(
                                onpress: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VideoCallPage(),
                                    ),
                                  );
                                },
                                title: "مكالمة فيديو",
                                icon: Icons.video_call_outlined,
                              ),
                              const Spacer(),
                              ElevatedButtonWidget(
                                onpress: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VoiceCallPage(),
                                    ),
                                  );
                                },
                                title: "مكالمة صوتية",
                                icon: Icons.phone_callback,
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    // 4. حالة افتراضية (قبل التحميل)
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}