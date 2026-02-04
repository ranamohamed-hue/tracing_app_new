import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:tracing_app_new/core/theming/app_styles.dart';
import 'package:tracing_app_new/core/widgets/appbar_part.dart';
import 'package:tracing_app_new/feature/auth/cubit/parent_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_state.dart';
// *** التعديل 1: إضافة استيراد ParentState ***
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
      body: BlocListener<ParentCubit, ParentState>( // *** التعديل 2: تغيير AuthState إلى ParentState ***
        listener: (context, state) {
          if (state is InviteCodeErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Container(
          decoration: AppStyles.primaryGradientDecoration,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                BlocBuilder<ParentCubit, ParentState>( // *** التعديل 3: تغيير AuthState إلى ParentState ***
                  builder: (context, state) {
                    if (state is InviteCodeLoadingState) {
                      return _buildLoadingCard();
                    }
                    if (state is InviteCodeGeneratedState) {
                      return _buildInviteCodeCard(context, state.code);
                    }
                    // في حالة عدم وجود كود بعد، لا تعرض شيئًا
                    return const SizedBox.shrink(); 
                  },
                ),

                const Spacer(),

                BlocBuilder<ParentCubit, ParentState>( // *** التعديل 4: تغيير AuthState إلى ParentState ***
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
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Icon(hasCode ? Icons.refresh : Icons.qr_code_2),
                      label: isLoading
                          ? 'جاري الإنشاء...'
                          : (hasCode ? 'إعادة إنشاء كود' : 'إنشاء كود الدعوة'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // ... باقي الدوال (_buildInviteCodeCard, _buildLoadingCard, _buildPrimaryButton) كما هي بدون تغيير ...
}


  Widget _buildInviteCodeCard(BuildContext context, String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'كود الدعوة الخاص بك',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              code,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 4.0,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.copy_all_rounded),
              label: const Text('نسخ الكود'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            strokeWidth: 4,
          ),
          SizedBox(height: 20),
          Text(
            'جاري إنشاء الكود...',
            style: TextStyle(
              fontSize: 18,
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade700,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
