import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tracing_app_new/core/theming/app_styles.dart';
import 'package:tracing_app_new/core/widgets/appbar_part.dart';
import 'package:tracing_app_new/feature/login/widgets/text_form_field_widget.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدمنا GlobalKey للـ Form عشان نقدر نشغل الـ Validator
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _emailController = TextEditingController();

    return Scaffold(
      appBar: AppbarPart(title: "استعادة كلمة المرور"),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppStyles.primaryGradientDecoration,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey, // ربط الـ Form بالـ Key
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "أدخل بريدك الإلكتروني لإرسال رابط استعادة كلمة المرور",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
                SizedBox(height: 30.h),
                
                // ✅ تعديل البيانات لتناسب البريد الإلكتروني
                TextFormFieldWidget(
                  title: "البريد الإلكتروني", 
                  hinttext: "أدخل بريدك الإلكتروني",
                  keyboardtype: TextInputType.emailAddress,
                  controller: _emailController,
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
                
                SizedBox(height: 30.h),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200.w, 50.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: () {
                    // التحقق من صحة الإدخال قبل الإرسال
                    if (_formKey.currentState!.validate()) {
                      // هنا هننادي الـ Cubit لاحقاً
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("تم إرسال الرابط لبريدك الإلكتروني"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: Text("إرسال الرابط", style: TextStyle(fontSize: 16.sp)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}