// lib/feature/parent/screens/children_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:tracing_app_new/feature/auth/data/models/user_model.dart'; // *** إضافة استيراد UserModel ***

class ChildrenPage extends StatelessWidget {
  const ChildrenPage({super.key});

  // *** التعديل: إكمال دالة بناء بطاقة الطفل ***
  Widget _buildChildCard(BuildContext context, UserModel child) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(child.username),
        subtitle: Text('البريد: ${child.email}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // عند الضغط على البطاقة، انتقل إلى صفحة التتبع لهذا الطفل
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
            padding: const EdgeInsets.all(16.0),
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
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text("الأبناء المرتبطون بحسابك:", style: TextStyle(fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<ChildrenCubit, ChildrenState>(
                    builder: (context, childrenState) {
                      if (childrenState is ChildrenLoadingState) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }
                      if (childrenState is ChildrenErrorState) {
                        return Center(child: Text('حدث خطأ: ${childrenState.message}', style: const TextStyle(color: Colors.red)));
                      }
                      if (childrenState is ChildrenLoadedState) {
                        final children = childrenState.children;
                        if (children.isEmpty) {
                          return const Center(child: Text('لا يوجد أبناء مرتبطون حالياً.\nاستخدم الزر (+) لإضافة طفل.', style: TextStyle(color: Colors.white), textAlign: TextAlign.center));
                        }
                        return ListView.builder(
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
        child: const Icon(Icons.add, color: Colors.blue),
      ),
    );
  }
}