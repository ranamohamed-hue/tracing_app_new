// lib/feature/student/screens/student_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracing_app_new/core/theming/app_styles.dart';
import 'package:tracing_app_new/core/widgets/appbar_part.dart';
import 'package:tracing_app_new/core/widgets/elevated_button_widget.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_state.dart';
import 'package:tracing_app_new/feature/auth/cubit/parent_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/location_cubit.dart';

// منع التضارب في المسميات
import 'package:tracing_app_new/feature/auth/data/repo/call_repo.dart' hide MeetingStatus;

import 'package:tracing_app_new/feature/parent/logic/chat_cubit.dart';
import 'package:tracing_app_new/feature/parent/logic/chat_state.dart';
import 'package:tracing_app_new/feature/auth/cubit/parent_state.dart';
import 'package:tracing_app_new/feature/auth/cubit/location_state.dart';
import 'package:tracing_app_new/feature/student/screens/invite_code_page.dart';
import 'package:tracing_app_new/feature/parent/screens/profile_bage.dart'; 

import 'package:tracing_app_new/feature/auth/cubit/call_cubitt/call_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/call_cubitt/call_state.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  @override
  void initState() {
    super.initState();
    // تفعيل الموقع تلقائياً عند الدخول
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _activateLocationAutomatically();
    });
  }

  void _activateLocationAutomatically() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthenticatedState) {
      final locationCubit = context.read<LocationCubit>();
      if (locationCubit.state is! TrackingStartedState &&
          locationCubit.state is! LocationUpdatedState) {
        locationCubit.toggleTracking(authState.userModel.uid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ تم حذف BlocProvider من هنا لأنه موجود في الـ main.dart
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
          BlocListener<CallCubit, CallState>(
            listener: (context, callState) {
              if (callState.errorMessage != null && callState.errorMessage!.isNotEmpty) {
                _showSnackBar(context, callState.errorMessage!, Colors.red);
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
                _buildWelcomeHeader(),
                const SizedBox(height: 30),

                // 1. زر تتبع الموقع
                _buildLocationButton(),

                const SizedBox(height: 15),

                // 2. زر الملف الشخصي
                ElevatedButtonWidget(
                  onpress: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileBage()),
                  ),
                  title: "الملف الشخصي والإعدادات",
                  icon: Icons.account_circle,
                ),

                const SizedBox(height: 15),

                // 3. زر كود الربط
                ElevatedButtonWidget(
                  onpress: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InviteCodePage()),
                  ),
                  title: "عرض كود ربط ولي الأمر",
                  icon: Icons.qr_code_scanner,
                ),

                const SizedBox(height: 15),

                // 4. أزرار المكالمات
                _buildCallOptions(),

                const SizedBox(height: 30),

                // 5. زر الذكاء الاصطناعي
                _buildAiButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets فرعية لتحسين القراءة ---

  Widget _buildWelcomeHeader() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String name = "الطالب";
        if (state is AuthenticatedState) name = state.userModel.username;
        return Text(
          "مرحباً بك : $name",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildLocationButton() {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, locationState) {
        final bool isTracking =
            locationState is TrackingStartedState ||
            locationState is LocationUpdatedState;
        return ElevatedButtonWidget(
          onpress: () {
            final authState = context.read<AuthCubit>().state;
            if (authState is AuthenticatedState) {
              context.read<LocationCubit>().toggleTracking(authState.userModel.uid);
            }
          },
          title: isTracking ? "إيقاف تتبع موقعي" : "تفعيل التتبع المباشر",
          icon: isTracking ? Icons.location_off : Icons.location_on,
        );
      },
    );
  }

  Widget _buildCallOptions() {
    return BlocBuilder<CallCubit, CallState>(
      builder: (context, callState) {
        final isConnecting = callState.status == MeetingStatus.connecting;
        return Row(
          children: [
            Expanded(
              child: ElevatedButtonWidget(
                onpress: isConnecting ? null : () => _startCall(isVideo: true),
                title: isConnecting ? "..." : "فيديو",
                icon: Icons.video_call,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButtonWidget(
                onpress: isConnecting ? null : () => _startCall(isVideo: false),
                title: isConnecting ? "..." : "صوتية",
                icon: Icons.phone,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAiButton() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.9),
              foregroundColor: Colors.blue.shade900,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => context.read<ChatCubit>().launchChatGpt(),
            icon: state is ChatLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_awesome),
            label: Text(
              state is ChatLoading ? 'جاري الاتصال...' : 'اسأل ذكاء راصد (ChatGPT)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  void _startCall({required bool isVideo}) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthenticatedState) {
      final studentUser = authState.userModel;
      final parentUid = studentUser.parentUid;

      if (parentUid == null || parentUid.isEmpty) {
        _showSnackBar(context, 'لم يتم ربطك بحساب ولي أمر بعد.', Colors.orange);
        return;
      }

      context.read<CallCubit>().startMeeting(
            currentUser: studentUser,
            isVideoCall: isVideo,
            calleeId: parentUid,
          );
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}