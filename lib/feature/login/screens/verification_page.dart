import 'package:flutter/material.dart';
import 'package:tracing_app_new/core/theming/app_styles.dart';
import 'package:tracing_app_new/core/widgets/appbar_part.dart';
import 'package:tracing_app_new/core/widgets/elevated_button_widget.dart';
import 'package:tracing_app_new/feature/login/screens/opt_field.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  //دالة الهدم
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var FocusNode in _focusNodes) {
      FocusNode.dispose();
    }
    super.dispose();
  }

  //دالة الانتقال الي الحقل التالي عند ادخال رقم
  void _nextField(int index, String value) {
    if (value.length == 1 && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
  }

  //دالة الرجوع للخلف عند حذف رقم
  void _previousField(int index) {
    if (index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  //دالة الحصول علي الرمز كامل
  String _getFullCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const AppbarPart(title: " تسجيل الدخول "),
      body: Container(constraints: const BoxConstraints.expand(),
        decoration: AppStyles.primaryGradientDecoration,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    bottom: 24,
                    right: 24,
                    left: 24,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'أدخل الكود',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return OptField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              onChange: (value) {
                                if (value.length == 1) {
                                  _nextField(index, value);
                                } else if (value.isEmpty) {
                                  _previousField(index);
                                }
                              },
                            );
                          }),
                        ),
                        const SizedBox(height: 40),

                        ElevatedButtonWidget(
                          onpress: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('جاري التحقق من الكود...'),
                                ),
                              );
                            }
                          },
                          title: "تحقق",
                          icon: Icons.check_circle_outline,
                        ),
                        const SizedBox(height: 20),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم إعادة إرسال الكود'),
                                ),
                              );
                            },
                            child: Text(
                              'لم تستلم الكود؟ أعد الإرسال',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color.fromARGB(255, 8, 8, 8),
                                decoration: TextDecoration.underline,
                                decorationColor: const Color.fromARGB(
                                  255,
                                  8,
                                  8,
                                  8,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 60),
                      ],
                    ),
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
