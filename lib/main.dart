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

// استيراد الإعدادات والخدمات
import 'firebase_options.dart';
import 'package:tracing_app_new/core/services/notification_service.dart';

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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  if (message.data['type'] == 'incoming_call') {
    NotificationService.showCallNotification(message);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // تهيئة خدمات الإشعارات (Awesome Notifications)
  await NotificationService.initialize();
  
  // تهيئة مستمعي الرسائل في الواجهة (Foreground)
  NotificationService.initializeFcmListeners();
  
  // تفعيل معالج الخلفية
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // إعداد المستودعات
  final authRepo = AuthRepoImpl(
    firebaseAuth: FirebaseAuth.instance,
    firebaseFirestore: FirebaseFirestore.instance,
  );
  final callRepo = CallRepoImpl();

  // إعدادات الشاشة (System UI)
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
              navigatorKey: navigatorKey, // ربط المفتاح العالمي هنا
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
              builder: (context, widget) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
                  child: widget!,
                );
              },
              home: const AuthWrapper(),
              routes: {
                '/parentHome': (context) => const ParentPage(),
                '/studentHome': (context) => const StudentPage(),
                '/callScreen': (context) {
                  final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
                  return IncomingCallOverlay(
                    callerName: args['callerName'] ?? 'متصل مجهول',
                    roomName: args['roomName'],
                    isVideo: true,
                    onAccept: () {
                      // الحفاظ على اتساق اسم الغرفة عبر الـ Cubit
                      context.read<CallCubit>().joinIncomingCall(
                        roomName: args['roomName'],
                        userName: "مستخدم", 
                      );
                    },
                    onDecline: () => Navigator.pop(context),
                  );
                },
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
  
  // حفظ توكن FCM في Firestore
  void _saveDeviceToken(String userId) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'fcmToken': token,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint("FCM Token Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is SignUpVerificationSentState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthCheckingState) return const SplashScreen();

          if (state is AuthenticatedState) {
            // تنفيذ العمليات عند نجاح الدخول
            _saveDeviceToken(state.userModel.uid);

            // بدء مراقبة Firestore للمكالمات الواردة
            NotificationService.listenForIncomingCalls(state.userModel.uid);

            final String type = state.userModel.userType.trim().toLowerCase();
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