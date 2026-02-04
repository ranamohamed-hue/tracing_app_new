import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracing_app_new/feature/parent/logic/chat_cubit.dart';
import 'firebase_options.dart';

// استيراد ملفات المصادقة
import 'package:tracing_app_new/feature/auth/cubit/auth_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/auth_state.dart';
import 'package:tracing_app_new/feature/auth/data/repo/auth_repo.dart';
import 'package:tracing_app_new/feature/auth/data/repo/auth_repo_impl.dart';

// استيراد الكيوبتات الأخرى
import 'package:tracing_app_new/feature/auth/cubit/children_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/location_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/parent_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/child_tracing_cubit.dart';

// استيراد ملفات الثيم
import 'package:tracing_app_new/core/theming/app_theme.dart';
import 'package:tracing_app_new/core/theming/logic/theme_cubit.dart';
import 'package:tracing_app_new/core/theming/logic/theme_state.dart';

// استيراد الشاشات
import 'package:tracing_app_new/feature/login/screens/splash_screen.dart';
import 'package:tracing_app_new/feature/login/screens/sign_in_page.dart';
import 'package:tracing_app_new/feature/parent/screens/parent_page.dart';
import 'package:tracing_app_new/feature/student/screens/student_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  final authRepo = AuthRepoImpl(
    firebaseAuth: FirebaseAuth.instance,
    firebaseFirestore: FirebaseFirestore.instance,
  );

  runApp(
    RepositoryProvider<AuthRepo>.value(
      value: authRepo,
      child: MultiBlocProvider(
        providers: [
          // --- الكيوبتات الأساسية ---
          BlocProvider<AuthCubit>(create: (context) => AuthCubit(context.read<AuthRepo>())),
          BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
          BlocProvider<ChatCubit>(create: (context) => ChatCubit()),

          // --- الكيوبتات الأخرى ---
          BlocProvider<ChildrenCubit>(create: (context) => ChildrenCubit(context.read<AuthRepo>())),
          BlocProvider<LocationCubit>(create: (context) => LocationCubit(context.read<AuthRepo>())),
          BlocProvider<ParentCubit>(create: (context) => ParentCubit(context.read<AuthRepo>())),
          BlocProvider<ChildTrackingCubit>(create: (context) => ChildTrackingCubit(context.read<AuthRepo>())),
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
        // التعامل مع الرسائل فقط
        if (state is SignUpVerificationSentState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        if (state is SignUpErrorState || state is LogoutErrorState) {
          String errorMessage = '';
          if (state is SignUpErrorState) errorMessage = state.error;
          if (state is LogoutErrorState) errorMessage = state.error;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          // لو بيتم التحقق من المصادقة
          if (state is AuthCheckingState) {
            return const SplashScreen();
          }

          // لو تم المصادقة بنجاح
          if (state is AuthenticatedState) {
            final type = state.userModel.userType?.trim();
            if (type == 'طالب') {
              return const StudentPage();
            } else if (type == 'ولي أمر') {
              return const ParentPage();
            } else {
              return const SignInPage(); // fallback لأي قيمة غير متوقعة
            }
          }

          // لو المستخدم غير مصادق عليه
          return const SignInPage();
        },
      ),
    );
  }
}
