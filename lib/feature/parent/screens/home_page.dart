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
import 'package:tracing_app_new/feature/auth/cubit/call_cubitt/call_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/call_cubitt/call_state.dart';
import 'package:tracing_app_new/feature/auth/data/repo/call_repo.dart' hide MeetingStatus;
import 'package:tracing_app_new/feature/parent/screens/child_tracing_page.dart';
import 'package:tracing_app_new/feature/parent/screens/children_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? selectedChild;

  @override
  Widget build(BuildContext context) {
    // ✅ تم حذف BlocProvider من هنا لأننا عرفناه في main.dart
    return Scaffold(
      appBar: const AppbarPart(title: "لوحة التحكم"),
      body: BlocListener<CallCubit, CallState>(
        listener: (context, callState) {
          if (callState.errorMessage != null && callState.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(callState.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: AppStyles.primaryGradientDecoration,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // اسم ولي الأمر
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
                      if (childrenState is ChildrenLoadingState) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }

                      if (childrenState is ChildrenErrorState) {
                        return _buildErrorUI(context, childrenState.message);
                      }

                      List<UserModel> children = [];
                      if (childrenState is ChildrenLoadedState) {
                        children = childrenState.children;
                        if (selectedChild == null && children.isNotEmpty) {
                          selectedChild = children.first;
                        }
                      }

                      if (children.isEmpty) {
                        return _buildNoChildrenUI(context);
                      }

                      return Column(
                        children: [
                          // القائمة المنسدلة
                          _buildChildrenDropdown(children),
                          const SizedBox(height: 20),
                          // زر الموقع الجغرافي
                          ElevatedButtonWidget(
                            onpress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChildTracingPage(child: selectedChild!),
                                ),
                              );
                            },
                            title: "عرض الموقع الجغرافي",
                            icon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 40),
                          // أزرار المكالمات
                          _buildCallButtons(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets فرعية لتنظيم الكود ---

  Widget _buildChildrenDropdown(List<UserModel> children) {
    return Container(
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
    );
  }

  Widget _buildCallButtons() {
    return BlocBuilder<CallCubit, CallState>(
      builder: (context, callState) {
        final isConnecting = callState.status == MeetingStatus.connecting;

        return Row(
          children: [
            Expanded(
              child: ElevatedButtonWidget(
                onpress: isConnecting ? null : () => _startCall(isVideo: true),
                title: isConnecting ? "جاري الاتصال..." : "مكالمة فيديو",
                icon: Icons.video_call_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButtonWidget(
                onpress: isConnecting ? null : () => _startCall(isVideo: false),
                title: isConnecting ? "جاري الاتصال..." : "مكالمة صوتية",
                icon: Icons.phone_callback,
              ),
            ),
          ],
        );
      },
    );
  }

  // دالة بدء المكالمة (المعدلة لتستخدم الـ Cubit العالمي)
  void _startCall({required bool isVideo}) {
    if (selectedChild == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار طفل أولاً'), backgroundColor: Colors.orange),
      );
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is AuthenticatedState) {
      context.read<CallCubit>().startMeeting(
            currentUser: authState.userModel,
            isVideoCall: isVideo,
            calleeId: selectedChild!.uid,
          );
    }
  }

  Widget _buildErrorUI(BuildContext context, String message) {
     return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('حدث خطأ: $message', style: const TextStyle(color: Colors.white)),
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

  Widget _buildNoChildrenUI(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("لا يوجد أبناء مرتبطون بحسابك.", style: TextStyle(color: Colors.white)),
        const SizedBox(height: 20),
        ElevatedButtonWidget(
          onpress: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChildrenPage())),
          title: "إدارة الأبناء",
          icon: Icons.people,
        ),
      ],
    );
  }
}