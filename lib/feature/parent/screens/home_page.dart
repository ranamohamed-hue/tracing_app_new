// lib/feature/parent/screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracing_app_new/core/theming/app_styles.dart';
import 'package:tracing_app_new/core/widgets/appbar_part.dart';
import 'package:tracing_app_new/core/widgets/elevated_button_widget.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_state.dart';
import 'package:tracing_app_new/feature/auth/cubit/children_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/children_state.dart';
import 'package:tracing_app_new/feature/auth/data/models/user_model.dart';
import 'package:tracing_app_new/feature/parent/screens/child_tracing_page.dart';
import 'package:tracing_app_new/feature/parent/screens/children_page.dart';
import 'package:tracing_app_new/feature/parent/screens/video_call_page.dart';
import 'package:tracing_app_new/feature/parent/screens/voice_call_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // متغير لحفظ الطفل المحدد من القائمة المنسدلة
  UserModel? selectedChild;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // *** تعديل العنوان ليعكس أنه الصفحة الرئيسية ***
      appBar: const AppbarPart(title: "لوحة التحكم"),
      body: Container(
        // *** إكمال خصائص الـ Container ***
        constraints: const BoxConstraints.expand(),
        decoration: AppStyles.primaryGradientDecoration,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              SizedBox(height: 20),
              // 1. BlocBuilder لـ AuthCubit لجلب اسم ولي الأمر
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

              Expanded(
                child: BlocBuilder<ChildrenCubit, ChildrenState>(
                  builder: (context, childrenState) {
                    // منطق التحميل
                    if (childrenState is ChildrenLoadingState) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    // منطق الخطأ
                    if (childrenState is ChildrenErrorState) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'حدث خطأ: ${childrenState.message}',
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                final authState = context
                                    .read<AuthCubit>()
                                    .state;
                                if (authState is AuthenticatedState) {
                                  context.read<ChildrenCubit>().fetchChildren(
                                    authState.userModel.uid,
                                  );
                                }
                              },
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      );
                    }

                    List<UserModel> children = [];
                    if (childrenState is ChildrenLoadedState) {
                      children = childrenState.children;
                      // تحديد أول طفل كاختيار افتراضي
                      if (selectedChild == null && children.isNotEmpty) {
                        selectedChild = children.first;
                      }
                    }

                    // حالة عدم وجود أبناء
                    if (children.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "لا يوجد أبناء مرتبطون بحسابك.\nقم بإضافة طفل أولاً.",
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // *** زر للانتقال إلى صفحة إدارة الأبناء ***
                          ElevatedButtonWidget(
                            onpress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // الانتقال إلى صفحة إدارة الأبناء
                                  builder: (context) => const ChildrenPage(),
                                ),
                              );
                            },
                            title: "إدارة الأبناء",
                            icon: Icons.people,
                          ),
                        ],
                      );
                    }

                    // إذا كان هناك أبناء، اعرض الأدوات
                    return Column(
                      children: [
                        // القائمة المنسدلة لاختيار الطفل
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<UserModel>(
                              value: selectedChild,
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
                                builder: (context) =>
                                    ChildTracingPage(child: selectedChild!),
                              ),
                            );
                          },
                          title: "عرض الموقع الجغرافي",
                          icon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            // *** تمرير الطفل المحدد إلى صفحة الفيديو ***
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
                            // *** تمرير الطفل المحدد إلى صفحة الصوت ***
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
