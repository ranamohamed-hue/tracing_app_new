import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ✅ استيراد المكتبة
import 'package:tracing_app_new/core/theming/app_styles.dart';
import 'package:tracing_app_new/core/widgets/appbar_part.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_state.dart';
import 'package:tracing_app_new/feature/auth/cubit/children_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/children_state.dart';
import 'package:tracing_app_new/feature/auth/cubit/parent_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/parent_state.dart';
import 'package:tracing_app_new/feature/auth/data/models/user_model.dart';
import 'package:tracing_app_new/feature/parent/screens/child_tracing_page.dart';
import 'package:tracing_app_new/feature/parent/widgets/link_child_dialog.dart';

class ChildrenPage extends StatelessWidget {
  const ChildrenPage({super.key});

  // ✅ تعديل بطاقة الطفل لتكون مرنة
  Widget _buildChildCard(BuildContext context, UserModel child) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0.h), // ✅ مسافة مرنة
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)), // ✅ زوايا مرنة
      elevation: 3,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h), // ✅ بادينج داخلي مرن
        leading: CircleAvatar(
          radius: 25.r, // ✅ حجم الافاتار مرن
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, color: Colors.white, size: 28.r),
        ),
        title: Text(
          child.username,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold), // ✅ نص مرن
        ),
        subtitle: Text(
          'البريد: ${child.email}',
          style: TextStyle(fontSize: 13.sp), // ✅ نص مرن
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 18.r, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChildTracingPage(child: child),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppbarPart(title: "إدارة الأبناء"),
      body: BlocListener<ParentCubit, ParentState>(
        listener: (context, parentState) {
          if (parentState is LinkingSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم ربط الطفل بنجاح!'), backgroundColor: Colors.green),
            );
            final authState = context.read<AuthCubit>().state;
            if (authState is AuthenticatedState) {
              context.read<ChildrenCubit>().fetchChildren(authState.userModel.uid);
            }
          } else if (parentState is LinkingErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(parentState.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: AppStyles.primaryGradientDecoration,
          child: Padding(
            padding: EdgeInsets.all(16.0.r), // ✅ بادينج الشاشة مرن
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    String parentName = 'ولي الأمر';
                    if (authState is AuthenticatedState) {
                      parentName = authState.userModel.username;
                    }
                    return Text(
                      "مرحباً : $parentName",
                      style: TextStyle(
                        fontSize: 22.sp, // ✅ نص ترحيبي مرن
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h), // ✅ مسافة مرنة
                Text(
                  "الأبناء المرتبطون بحسابك:",
                  style: TextStyle(fontSize: 16.sp, color: Colors.white70),
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: BlocBuilder<ChildrenCubit, ChildrenState>(
                    builder: (context, childrenState) {
                      if (childrenState is ChildrenLoadingState) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }
                      if (childrenState is ChildrenErrorState) {
                        return Center(
                          child: Text(
                            'حدث خطأ: ${childrenState.message}',
                            style: TextStyle(color: Colors.red, fontSize: 14.sp),
                          ),
                        );
                      }
                      if (childrenState is ChildrenLoadedState) {
                        final children = childrenState.children;
                        if (children.isEmpty) {
                          return Center(
                            child: Text(
                              'لا يوجد أبناء مرتبطون حالياً.\nاستخدم الزر (+) لإضافة طفل.',
                              style: TextStyle(color: Colors.white, fontSize: 15.sp),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: children.length,
                          itemBuilder: (context, index) => _buildChildCard(context, children[index]),
                        );
                      }
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => LinkChildDialog(
              onLinkSubmitted: (code) {
                final authState = context.read<AuthCubit>().state;
                if (authState is AuthenticatedState) {
                  context.read<ParentCubit>().linkParentToChild(
                        parentUid: authState.userModel.uid,
                        inviteCode: code,
                      );
                }
              },
            ),
          );
        },
        backgroundColor: Colors.white,
        child: Icon(Icons.add, color: Colors.blue, size: 30.r), // ✅ حجم الأيقونة مرن
      ),
    );
  }
}