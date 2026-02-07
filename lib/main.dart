import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

// Repos & Cubits
import 'package:tracing_app_new/feature/auth/data/repo/auth_repo.dart';
import 'package:tracing_app_new/feature/auth/data/repo/auth_repo_impl.dart';
import 'package:tracing_app_new/feature/auth/data/repo/call_repo_impl.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_state.dart';
import 'package:tracing_app_new/feature/auth/cubit/call_cubitt/call_cubit.dart';
import 'package:tracing_app_new/core/theming/logic/theme_cubit.dart';
import 'package:tracing_app_new/core/theming/logic/theme_state.dart';
import 'package:tracing_app_new/feature/parent/logic/chat_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/children_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/location_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/parent_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/child_tracing_cubit.dart';

// Services & Screens
import 'firebase_options.dart';
import 'package:tracing_app_new/core/services/notification_service.dart';
import 'package:tracing_app_new/core/theming/app_theme.dart';
import 'package:tracing_app_new/feature/login/screens/splash_screen.dart';
import 'package:tracing_app_new/feature/login/screens/sign_in_page.dart';
import 'package:tracing_app_new/feature/parent/screens/parent_page.dart';
import 'package:tracing_app_new/feature/student/screens/student_page.dart';
import 'package:tracing_app_new/feature/auth/cubit/call_cubitt/incoming_call_overlay.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ✅ تعديل دالة الخلفية لتكون "قوية" وتعمل بشكل مستقل
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // تهيئة Firebase ضرورية جداً داخل هذه الدالة لأنها تعمل في Process منفصل
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // تهيئة الإشعارات داخل الخلفية لضمان عمل الـ Channels
  await NotificationService.initialize();

  if (message.data['type'] == 'incoming_call') {
    // استدعاء عرض الإشعار الذي يحتوي على FullScreenIntent
    await NotificationService.showCallNotification(message);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. تهيئة خدمات الإشعارات
  await NotificationService.initialize();
  
  // 3. تفعيل معالج الخلفية (يجب أن يكون قبل أي مستمع آخر)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 4. تهيئة مستمعي الواجهة (التطبيق مفتوح)
  NotificationService.initializeFcmListeners();

  // إعداد الـ Repositories
  final authRepo = AuthRepoImpl(
    firebaseAuth: FirebaseAuth.instance,
    firebaseFirestore: FirebaseFirestore.instance,
  );
  final callRepo = CallRepoImpl();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
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
              onGenerateRoute: (settings) {
                if (settings.name == '/callScreen') {
                  final args = settings.arguments as Map<String, dynamic>;
                  return MaterialPageRoute(
                    builder: (context) => IncomingCallOverlay(
                      callerName: args['callerName'] ?? 'متصل مجهول',
                      roomName: args['roomName'], // نستخدم roomName ليتوافق مع الـ Cubit
                      isVideo: true,
                      onAccept: () {
                        // استخدام الـ roomName من الـ arguments
                        context.read<CallCubit>().joinIncomingCall(
                          roomName: args['roomName'],
                          userName: "مستخدم",
                        );
                      },
                      onDecline: () => Navigator.pop(context),
                    ),
                  );
                }
                return null;
              },
            );
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isListenerStarted = false; // لمنع تكرار المستمعين

  void _saveDeviceToken(String userId) async {
    try {
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await FirebaseFirestore.instance.collection('users').doc(userId).set({
            'fcmToken': token,
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      debugPrint("FCM Token Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthCheckingState) return const SplashScreen();

        if (state is AuthenticatedState) {
          _saveDeviceToken(state.userModel.uid);

          // تشغيل المستمع مرة واحدة فقط عند تسجيل الدخول
          if (!_isListenerStarted) {
            NotificationService.listenForIncomingCalls(state.userModel.uid);
            _isListenerStarted = true;
          }

          final String type = state.userModel.userType.trim().toLowerCase();
          if (type.contains('طالب') || type.contains('student')) {
            return const StudentPage();
          } else {
            return const ParentPage();
          }
        }
        return const SignInPage();
      },
    );
  }
}