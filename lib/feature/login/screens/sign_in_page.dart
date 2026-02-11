import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; 
import 'package:tracing_app_new/core/theming/app_styles.dart';
import 'package:tracing_app_new/core/widgets/appbar_part.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_state.dart';
import 'package:tracing_app_new/feature/login/screens/forgot_password_page.dart';
import 'package:tracing_app_new/feature/login/screens/sign_up_page.dart';
import 'package:tracing_app_new/feature/login/widgets/login_prompt_widget.dart';
import 'package:tracing_app_new/feature/login/widgets/text_form_field_widget.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _useremail = TextEditingController();
  final TextEditingController _userpassword = TextEditingController();

  @override
  void dispose() {
    _useremail.dispose();
    _userpassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is LoginErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppbarPart(title: "تسجيل الدخول"),
          body: Container(
            constraints: const BoxConstraints.expand(),
            decoration: AppStyles.primaryGradientDecoration,
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 40.h),
                      TextFormFieldWidget(
                        title: "البريد الإلكتروني",
                        hinttext: "(Yahoo,Gmail ,...)أدخل بريدك الإلكتروني",
                        keyboardtype: TextInputType.emailAddress,
                        controller: _useremail,
                        icon: Icons.email_outlined,
                        validatorr: (value) {
                          if (value == null || value.isEmpty) {
                            return "من فضلك أدخل البريد الإلكتروني";
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                          if (!emailRegex.hasMatch(value)) {
                            return "الرجاء إدخال بريد إلكتروني صحيح (مثل: user@yahoo.com)";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),

                      TextFormFieldWidget(
                        title: "كلمة المرور",
                        hinttext: "أدخل كلمة المرور",
                        keyboardtype: TextInputType.visiblePassword,
                        controller: _userpassword,
                        icon: Icons.lock,
                        obscureText: true,
                        validatorr: (value) {
                          if (value == null || value.isEmpty) {
                            return "من فضلك أدخل كلمة المرور";
                          }
                          if (value.length < 6) {
                            return "كلمة المرور ينبغي أن تكون على الأقل 6 أحرف";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordPage(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Text(
                            "هل نسيت كلمة المرور؟",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                              color: Colors.white,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          if (state is LoginLoadingState) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            );
                          }

                          return SizedBox(
                            width: 200.w,
                            height: 50.h,
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.login_outlined, size: 20.r),
                              label: Text(
                                "تسجيل الدخول",
                                style: TextStyle(fontSize: 16.sp),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthCubit>().login(
                                    email: _useremail.text,
                                    password: _userpassword.text,
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 25.h),

                      LoginPromptWidget(
                        comment: "ليس لديك حساب؟ ",
                        action: "قم بإنشاء حساب الآن",
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 50.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
