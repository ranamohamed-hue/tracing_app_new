import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ✅ استيراد المكتبة
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
    return Scaffold(
      appBar: const AppbarPart(title: "لوحة التحكم"),
      body: BlocListener<CallCubit, CallState>(
        listener: (context, callState) {
          if (callState.errorMessage != null && callState.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(callState.errorMessage!, style: TextStyle(fontSize: 14.sp)),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: AppStyles.primaryGradientDecoration,
          child: Padding(
            padding: EdgeInsets.all(16.r), // ✅ بادينج مرن للشاشة
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                // اسم ولي الأمر
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    String parentName = 'ولي الأمر';
                    if (authState is AuthenticatedState) {
                      parentName = authState.userModel.username;
                    }
                    return Text(
                      "مرحباً : $parentName",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp, // ✅ نص ترحيبي أكبر ومرن
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                SizedBox(height: 25.h), // ✅ مسافات رأسية مرنة
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
                          SizedBox(height: 25.h),
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
                          SizedBox(height: 35.h),
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

  // --- Widgets فرعية مرنة ---

  Widget _buildChildrenDropdown(List<UserModel> children) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w), // ✅ بادينج داخلي مرن
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r), // ✅ زوايا مرنة
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UserModel>(
          value: selectedChild,
          isExpanded: true,
          iconSize: 30.r, // ✅ حجم الأيقونة مرن
          hint: Text("اختر طفلاً", style: TextStyle(fontSize: 16.sp)),
          items: children.map((child) {
            return DropdownMenuItem<UserModel>(
              value: child,
              child: Text(child.username, style: TextStyle(fontSize: 16.sp)), // ✅ نص العناصر مرن
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
                title: isConnecting ? "جاري..." : "فيديو",
                icon: Icons.video_call_outlined,
              ),
            ),
            SizedBox(width: 12.w), // ✅ مسافة أفقية مرنة
            Expanded(
              child: ElevatedButtonWidget(
                onpress: isConnecting ? null : () => _startCall(isVideo: false),
                title: isConnecting ? "جاري..." : "صوتية",
                icon: Icons.phone_callback,
              ),
            ),
          ],
        );
      },
    );
  }

  void _startCall({required bool isVideo}) {
    if (selectedChild == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء اختيار طفل أولاً', style: TextStyle(fontSize: 14.sp)),
          backgroundColor: Colors.orange,
        ),
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
          Text('حدث خطأ: $message', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
          SizedBox(height: 10.h),
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
        Text(
          "لا يوجد أبناء مرتبطون بحسابك.",
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
        SizedBox(height: 20.h),
        ElevatedButtonWidget(
          onpress: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChildrenPage())),
          title: "إدارة الأبناء",
          icon: Icons.people,
        ),
      ],
    );
  }
}