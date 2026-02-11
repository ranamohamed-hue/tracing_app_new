import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; 
import 'package:tracing_app_new/core/theming/app_styles.dart';
import 'package:tracing_app_new/core/widgets/appbar_part.dart';
import 'package:tracing_app_new/feature/auth/cubit/parent_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_state.dart';
import 'package:tracing_app_new/feature/auth/cubit/parent_state.dart';

class InviteCodePage extends StatefulWidget {
  const InviteCodePage({super.key});

  @override
  State<InviteCodePage> createState() => _InviteCodePageState();
}

class _InviteCodePageState extends State<InviteCodePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthenticatedState) {
        context.read<ParentCubit>().generateInviteCode(authState.userModel.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppbarPart(title: "كود الدعوة"),
      body: BlocListener<ParentCubit, ParentState>(
        listener: (context, state) {
          if (state is InviteCodeErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error, style: TextStyle(fontSize: 14.sp)),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Container(
          decoration: AppStyles.primaryGradientDecoration,
          child: Padding(
            padding: EdgeInsets.all(24.r), 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),

                BlocBuilder<ParentCubit, ParentState>(
                  builder: (context, state) {
                    if (state is InviteCodeLoadingState) {
                      return _buildLoadingCard();
                    }
                    if (state is InviteCodeGeneratedState) {
                      return _buildInviteCodeCard(context, state.code);
                    }
                    return const SizedBox.shrink(); 
                  },
                ),

                const Spacer(),

                BlocBuilder<ParentCubit, ParentState>(
                  builder: (context, state) {
                    final isLoading = state is InviteCodeLoadingState;
                    final hasCode = state is InviteCodeGeneratedState;

                    return _buildPrimaryButton(
                      context: context,
                      onPressed: isLoading ? null : () {
                        final authState = context.read<AuthCubit>().state;
                        if (authState is AuthenticatedState) {
                          context.read<ParentCubit>().generateInviteCode(authState.userModel.uid);
                        }
                      },
                      icon: isLoading
                          ? SizedBox(
                              width: 24.r,
                              height: 24.r,
                              child: CircularProgressIndicator(
                                color: Colors.blue.shade700,
                                strokeWidth: 3,
                              ),
                            )
                          : Icon(hasCode ? Icons.refresh : Icons.qr_code_2, size: 24.r),
                      label: isLoading
                          ? 'جاري الإنشاء...'
                          : (hasCode ? 'إعادة إنشاء كود' : 'إنشاء كود الدعوة'),
                    );
                  },
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInviteCodeCard(BuildContext context, String code) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'كود الدعوة الخاص بك',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 15.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Text(
              code,
              style: TextStyle(
                fontSize: 34.sp, 
                fontWeight: FontWeight.bold,
                letterSpacing: 6.0.w, 
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('تم نسخ الكود بنجاح!'),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(20.r),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                );
              },
              icon: Icon(Icons.copy_all_rounded, size: 20.r),
              label: const Text('نسخ الكود'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(40.r),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(strokeWidth: 4),
          SizedBox(height: 20.h),
          Text(
            'جاري إنشاء الكود...',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required BuildContext context,
    required VoidCallback? onPressed,
    required Widget icon,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade700,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          textStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}