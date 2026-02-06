import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// استيراد مكتبة Jitsi
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

// استيراد الـ Cubits والـ Repos
import 'package:tracing_app_new/feature/auth/cubit/auth_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_state.dart';
import 'package:tracing_app_new/feature/auth/data/repo/auth_repo.dart';
import 'package:tracing_app_new/feature/auth/data/repo/auth_repo_impl.dart';
import 'package:tracing_app_new/feature/auth/cubit/call_cubitt/call_cubit.dart';
import 'package:tracing_app_new/feature/auth/data/repo/call_repo_impl.dart';
import 'package:tracing_app_new/feature/parent/logic/chat_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/children_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/location_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/parent_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/child_tracing_cubit.dart';

// استيراد الثيم والشاشات
import 'package:tracing_app_new/core/theming/app_theme.dart';
import 'package:tracing_app_new/core/theming/logic/theme_cubit.dart';
import 'package:tracing_app_new/core/theming/logic/theme_state.dart';
import 'package:tracing_app_new/feature/login/screens/splash_screen.dart';
import 'package:tracing_app_new/feature/login/screens/sign_in_page.dart';
import 'package:tracing_app_new/feature/parent/screens/parent_page.dart';
import 'package:tracing_app_new/feature/student/screens/student_page.dart';
import 'package:tracing_app_new/feature/auth/cubit/call_cubitt/incoming_call_overlay.dart'; 
import 'package:tracing_app_new/core/services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  await NotificationService.initialize();

  final authRepo = AuthRepoImpl(
    firebaseAuth: FirebaseAuth.instance,
    firebaseFirestore: FirebaseFirestore.instance,
  );
  final callRepo = CallRepoImpl();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepo>.value(value: authRepo),
        RepositoryProvider<CallRepoImpl>.value(value: callRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(create: (context) => AuthCubit(context.read<AuthRepo>())),
          BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
          BlocProvider<ChatCubit>(create: (context) => ChatCubit()),
          BlocProvider<ChildrenCubit>(create: (context) => ChildrenCubit(context.read<AuthRepo>())),
          BlocProvider<LocationCubit>(create: (context) => LocationCubit(context.read<AuthRepo>())),
          BlocProvider<ParentCubit>(create: (context) => ParentCubit(context.read<AuthRepo>())),
          BlocProvider<ChildTrackingCubit>(create: (context) => ChildTrackingCubit(context.read<AuthRepo>())),
          BlocProvider<CallCubit>(create: (context) => CallCubit(context.read<CallRepoImpl>())),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          title: 'Tracing App',
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar', 'AE')],
          locale: const Locale('ar', 'AE'),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeState.themeMode,
          home: const AuthWrapper(),
          routes: {
            '/parentHome': (context) => const ParentPage(),
            '/studentHome': (context) => const StudentPage(),
            '/callScreen': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
              return IncomingCallOverlay(
                callerName: args['callerName'] ?? 'متصل مجهول',
                isVideo: true,
                onAccept: () async {
                  try {
                    // إغلاق الأوفرلاي قبل الدخول
                    Navigator.of(context, rootNavigator: true).pop();

                    // ✅ استخدام اسم الغرفة الممرر من الـ Cubit لضمان التطابق التام
                    String roomName = args['roomName'];

                    var options = JitsiMeetConferenceOptions(
                      serverURL: "https://meet.jit.si",
                      room: roomName,
                      configOverrides: {
                        "prejoinPageEnabled": false,
                        "lobbyModeEnabled": false,
                        "disableDeepLinking": true, // يمنع التحويل للمتصفح أو المتجر
                        "startWithAudioMuted": false,
                        "startWithVideoMuted": false,
                      },
                      featureFlags: {
                        "welcomePage.enabled": false,
                        "prejoinPageEnabled": false,
                        "unsafeRoomWarning.enabled": false, // تخطي صفحة الأمان التي تعطل الـ SDK
                        "resolution": 360,
                        "pip.enabled": true,
                        "isWebviewEnabled": true, // تفعيل الـ WebView الداخلي كبديل آمن
                        "conference.enabled": true,
                      },
                    );

                    var jitsiMeet = JitsiMeet();
                    await jitsiMeet.join(options);
                  } catch (e) {
                    debugPrint("Jitsi Join Error: $e");
                  }
                },
                onDecline: () {
                  Navigator.pop(context);
                },
              );
            },
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is SignUpVerificationSentState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
        }
        if (state is SignUpErrorState || state is LogoutErrorState) {
          String errorMessage = (state is SignUpErrorState) ? state.error : "خطأ غير معروف";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthCheckingState) return const SplashScreen();

          if (state is AuthenticatedState) {
            NotificationService.listenForIncomingCalls(
              context,
              state.userModel.uid,
            );

            final String type = state.userModel.userType?.trim().toLowerCase() ?? "";
            if (type.contains('طالب') || type.contains('student')) {
              return const StudentPage();
            } else {
              return const ParentPage();
            }
          }
          return const SignInPage();
        },
      ),
    );
  }
}