import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracing_app_new/core/theming/app_styles.dart';
import 'package:tracing_app_new/core/widgets/appbar_part.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_state.dart';
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
      // *** التعديل الرئيسي: إزالة كود التنقل والتركيز على عرض الخطأ فقط ***
      listener: (context, state) {
        // التعامل مع حالات الخطأ فقط
        if (state is LoginErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error), 
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
            resizeToAvoidBottomInset: true, // الافتراضي true
          appBar: AppbarPart(title: "تسجيل الدخول"),
          body: Container(
            constraints: const BoxConstraints.expand(),
            decoration: AppStyles.primaryGradientDecoration,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      TextFormFieldWidget(
                        title: "البريد الإلكتروني",
                        hinttext: "أدخل بريدك الإلكتروني",
                        keyboardtype: TextInputType.emailAddress,
                        controller: _useremail,
                        icon: Icons.email_outlined,
                        validatorr: (value) {
                          if (value == null || value.isEmpty) {
                            return "من فضلك أدخل البريد الإلكتروني";
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return "الرجاء إدخال بريد إلكتروني صحيح";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

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
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            print("تم الضغط على 'هل نسيت كلمة المرور؟'");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'سيتم توجيهك لصفحة استعادة كلمة المرور',
                                ),
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
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

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
                            width: 200,
                            height: 50,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.login_outlined),
                              label: const Text("تسجيل الدخول"),
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
                      const SizedBox(height: 25),

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