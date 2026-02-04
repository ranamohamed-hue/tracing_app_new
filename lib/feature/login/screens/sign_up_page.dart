import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracing_app_new/core/theming/app_styles.dart';
import 'package:tracing_app_new/core/widgets/appbar_part.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_state.dart';
import 'package:tracing_app_new/feature/auth/data/models/user_model.dart';
import 'package:tracing_app_new/feature/login/widgets/login_prompt_widget.dart';
import 'package:tracing_app_new/feature/login/widgets/text_form_field_widget.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _useremail = TextEditingController();
  final TextEditingController _userpassword = TextEditingController();

  String _userRole = 'طالب';

  @override
  void dispose() {
    _username.dispose();
    _useremail.dispose();
    _userpassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // *** التعديل الرئيسي: BlocListener يتعامل فقط مع الأخطاء ***
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // عند حدوث خطأ، اعرض رسالة
        if (state is SignUpErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppbarPart(title: " انشاء حساب جديد"),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormFieldWidget(
                      title: "اسم المستخدم",
                      hinttext: "أدخل اسم المستخدم",
                      keyboardtype: TextInputType.name,
                      controller: _username,
                      icon: Icons.person,
                      validatorr: (value) {
                        if (value == null || value.isEmpty) {
                          return "من فضلك أدخل اسم المستخدم";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    TextFormFieldWidget(
                      title: "البريد الإلكتروني",
                      hinttext: "أدخل البريد الإلكتروني",
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
                          return "البريد الإلكتروني غير صالح";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    TextFormFieldWidget(
                      title: "كلمة المرور",
                      hinttext: "أدخل كلمة المرور",
                      keyboardtype: TextInputType.visiblePassword,
                      controller: _userpassword,
                      icon: Icons.lock,
                      obscureText: true,
                      // *** تعديل: تقليل الحد الأدنى لكلمة المرور إلى 6 ***
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

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "نوع المستخدم",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RadioListTile<String>(
                            title: const Text("طالب"),
                            secondary: Icon(
                              Icons.school,
                              color: Theme.of(context).primaryColor,
                            ),
                            value: 'طالب',
                            groupValue: _userRole,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value) {
                              setState(() {
                                _userRole = value!;
                              });
                            },
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 0,
                            ),
                          ),
                          RadioListTile<String>(
                            title: const Text("ولي أمر"),
                            secondary: Icon(
                              Icons.family_restroom,
                              color: Theme.of(context).primaryColor,
                            ),
                            value: 'ولي أمر',
                            groupValue: _userRole,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value) {
                              setState(() {
                                _userRole = value!;
                              });
                            },
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        if (state is SignUpLoadingState) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          );
                        }

                        return Center(
                          child: SizedBox(
                            width: 200,
                            height: 50,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.person_add_outlined),
                              label: const Text("إنشاء حساب جديد"),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  final newUser = UserModel(
                                    uid: '', // سيتم ملؤه في الـ Repo
                                    username: _username.text,
                                    email: _useremail.text,
                                    userType: _userRole,
                                  );

                                  context.read<AuthCubit>().signUp(
                                        userModel: newUser,
                                        password: _userpassword.text,
                                      );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // *** تعديل: استخدام Navigator.pop() للعودة للخلف ***
                    LoginPromptWidget(
                      comment: "هل لديك حساب من قبل؟",
                      action: "قم بتسجيل الدخول الآن",
                      onPressed: () {
                        Navigator.of(context).pop(); // العودة للشاشة السابقة (SignInPage)
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}