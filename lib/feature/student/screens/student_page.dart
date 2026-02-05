import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracing_app_new/core/theming/app_styles.dart';
import 'package:tracing_app_new/core/widgets/appbar_part.dart';
import 'package:tracing_app_new/core/widgets/elevated_button_widget.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_state.dart';
import 'package:tracing_app_new/feature/auth/cubit/parent_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/location_cubit.dart';
import 'package:tracing_app_new/feature/parent/logic/chat_cubit.dart';
import 'package:tracing_app_new/feature/parent/logic/chat_state.dart';
import 'package:tracing_app_new/feature/auth/cubit/parent_state.dart';
import 'package:tracing_app_new/feature/auth/cubit/location_state.dart';
import 'package:tracing_app_new/feature/student/screens/invite_code_page.dart';

class StudentPage extends StatelessWidget {
  const StudentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final username = (authState is AuthenticatedState) ? authState.userModel.username : 'طالب';

    return Scaffold(
      appBar: const AppbarPart(title: "راصد "),
      body: BlocListener<ParentCubit, ParentState>(
        listener: (context, state) {
          if (state is InviteCodeErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('فشل إنشاء الكود: ${state.error}'),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'إغلاق',
                  textColor: Colors.white,
                  onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                ),
              ),
            );
          }
          if (state is InviteCodeGeneratedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إنشاء كود الدعوة بنجاح!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: AppStyles.primaryGradientDecoration,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "مرحبا : $username",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 50),

                BlocBuilder<LocationCubit, LocationState>(
                  builder: (context, locationState) {
                    final isTracking = locationState is TrackingStartedState;
                    return ElevatedButtonWidget(
                      onpress: () {
                        if (authState is AuthenticatedState) {
                          context.read<LocationCubit>().toggleTracking(authState.userModel.uid);
                        }
                      },
                      title: isTracking ? "إيقاف التتبع" : "تفعيل الموقع الجغرافي",
                      icon: isTracking ? Icons.location_off : Icons.location_on_outlined,
                    );
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButtonWidget(
                  onpress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InviteCodePage()),
                    );
                  },
                  title: "كود الدعوة لولي الأمر",
                  icon: Icons.qr_code_2,
                ),
                const SizedBox(height: 30),

                // *** إضافة أزرار المكالمات المعطلة ***
                Row(
                  children: [
                    ElevatedButtonWidget(
                      // *** التعديل: تعطيل الزر بجعل onpress يساوي null ***
                      onpress: null,
                      title: "مكالمة فيديو",
                      icon: Icons.video_call_outlined,
                    ),
                    const Spacer(),
                    ElevatedButtonWidget(
                      // *** التعديل: تعطيل الزر بجعل onpress يساوي null ***
                      onpress: null,
                      title: "مكالمة صوتية",
                      icon: Icons.phone_callback,
                    ),
                  ],
                ),

                const SizedBox(height: 60),
                BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => context.read<ChatCubit>().launchChatGpt(),
                        icon: state is ChatLoading
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.link_sharp),
                        label: Text(state is ChatLoading ? 'جاري الفتح...' : 'فتح في Chat GPT'),
                      ),
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
}