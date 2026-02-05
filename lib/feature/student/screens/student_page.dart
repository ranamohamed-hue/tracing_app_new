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

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  
  @override
  void initState() {
    super.initState();
    // استدعاء تفعيل الموقع تلقائياً فور فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _activateLocationAutomatically();
    });
  }

  void _activateLocationAutomatically() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthenticatedState) {
      final locationCubit = context.read<LocationCubit>();
      
      // لا نشغل التتبع إلا إذا كان متوقفاً (لتجنب التكرار عند عمل Rebuild)
      if (locationCubit.state is! TrackingStartedState && 
          locationCubit.state is! LocationUpdatedState) {
        locationCubit.toggleTracking(authState.userModel.uid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final username = (authState is AuthenticatedState) ? authState.userModel.username : 'طالب';
    final userUid = (authState is AuthenticatedState) ? authState.userModel.uid : '';

    return Scaffold(
      appBar: const AppbarPart(title: "لوحة الطالب"),
      body: MultiBlocListener(
        listeners: [
          BlocListener<LocationCubit, LocationState>(
            listener: (context, state) {
              if (state is LocationErrorState) {
                _showSnackBar(context, state.error, Colors.orange.shade800);
              }
              if (state is TrackingStartedState) {
                _showSnackBar(context, 'تم تفعيل تتبع الموقع تلقائياً', Colors.green);
              }
            },
          ),
          BlocListener<ParentCubit, ParentState>(
            listener: (context, state) {
              if (state is InviteCodeErrorState) {
                _showSnackBar(context, 'فشل إنشاء الكود: ${state.error}', Colors.red);
              }
              if (state is InviteCodeGeneratedState) {
                _showSnackBar(context, 'تم إنشاء كود الدعوة بنجاح!', Colors.green);
              }
            },
          ),
        ],
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: AppStyles.primaryGradientDecoration,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "مرحباً بك : $username",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 40),

                // زر التحكم اليدوي (للطوارئ)
                BlocBuilder<LocationCubit, LocationState>(
                  builder: (context, locationState) {
                    final bool isTracking = locationState is TrackingStartedState || locationState is LocationUpdatedState;
                    return ElevatedButtonWidget(
                      onpress: () => context.read<LocationCubit>().toggleTracking(userUid),
                      title: isTracking ? "إيقاف تتبع موقعي" : "تفعيل التتبع المباشر",
                      icon: isTracking ? Icons.location_off : Icons.location_on,
                    );
                  },
                ),
                
                const SizedBox(height: 20),

                ElevatedButtonWidget(
                  onpress: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InviteCodePage())),
                  title: "عرض كود ربط ولي الأمر",
                  icon: Icons.qr_code_scanner,
                ),

                const SizedBox(height: 20),

                _buildCallOptions(),

                const SizedBox(height: 40),

                _buildAiButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCallOptions() {
    return Row(
      children: [
        Expanded(child: ElevatedButtonWidget(onpress: null, title: "فيديو", icon: Icons.video_call)),
        const SizedBox(width: 10),
        Expanded(child: ElevatedButtonWidget(onpress: null, title: "صوتية", icon: Icons.phone)),
      ],
    );
  }

  Widget _buildAiButton() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity, height: 55,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.9),
              foregroundColor: Colors.blue.shade900,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => context.read<ChatCubit>().launchChatGpt(),
            icon: state is ChatLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome),
            label: Text(state is ChatLoading ? 'جاري الاتصال...' : 'اسأل ذكاء راصد (ChatGPT)', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}