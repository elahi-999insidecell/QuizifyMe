import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app_2/Student/student_login_screen.dart';
import 'package:quiz_app_2/Student/student_signup_screen.dart';
import 'package:quiz_app_2/admin/add_quiz_screen.dart';
import 'package:quiz_app_2/admin/admin_auth/admin_auth_screen.dart';
import 'package:quiz_app_2/admin/admin_auth/admin_home.dart';
import 'package:quiz_app_2/admin/admin_quiz_list_screen.dart';
import 'package:quiz_app_2/firebase_options.dart';

import 'package:quiz_app_2/models/cqmodel.dart';
import 'package:quiz_app_2/models/firebase_category_model.dart';
import 'package:quiz_app_2/provider/auth_provider.dart';

import 'package:quiz_app_2/provider/quiz_provider.dart';
import 'package:quiz_app_2/provider/student_provider.dart';
import 'package:quiz_app_2/provider/subscription_provider.dart';
import 'package:quiz_app_2/provider/theme_provider.dart';
import 'package:quiz_app_2/screens/add_quiz_screen.dart';
import 'package:quiz_app_2/screens/home.dart';
import 'package:quiz_app_2/screens/subscription_screen.dart';
import 'package:quiz_app_2/screens/launcher_screen.dart';
import 'package:quiz_app_2/screens/leaderboard_screen.dart';


import 'package:quiz_app_2/screens/otp_verification_screen.dart';
import 'package:quiz_app_2/screens/real_profile.dart';
import 'package:quiz_app_2/screens/question_screen.dart';
import 'package:quiz_app_2/screens/result_screen.dart';
import 'package:quiz_app_2/screens/role_selection_screen.dart';
//import 'package:quiz_app_2/firebase_options.dart';

Future<void> main() async {
  //state ke save kore rakhi
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  runApp(
    MultiProvider(
      providers: [

        ChangeNotifierProvider(create: (context) => QuizProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => StudentSignUpProvider()),
        ChangeNotifierProvider(create: (context) => SubscriptionProvider()),
      ],
      
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'QuizifyMe App',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      
    );
  }
}

///routing by go router
final GoRouter appRouter = GoRouter(
  routes: [
    
    GoRoute(path: '/', builder: (context, state) => LauncherScreen()),

    GoRoute(
      path: '/question',
      builder: (context, state) {
        
        final category = state.extra as FirebaseCategoryModel;
        return QuestionScreen(category: category);
      },
    ),

    GoRoute(path: '/add-quiz', builder: (context, state) => AddQuizScreen()),

    GoRoute(
      path: '/result',
      builder: (context, state) {
        final category = state.extra as CategoryModel;
        return ResultScreen(category: category);
      },
    ),


    //admin auth
    GoRoute(
      path: '/admin-auth',
      builder: (context, state) => AdminAuthScreen(),
    ),

    //admin home
    GoRoute(path: '/admin-home', builder: (context, state) => AdminHome()),

    //role selection screen
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => RoleSelectionScreen(),
    ),

    //admin add quiz
    GoRoute(
      path: '/add-quiz-admin',
      builder: (context, state) => AddQuizScreenA(),
    ),

    //quiz-list-admin screen
    GoRoute(
      path: '/admin-quiz-list',
      builder: (context, state) {
        final categoru = state.extra as FirebaseCategoryModel;
        return AdminQuizListScreen(category: categoru);
      },
    ),

    //stu log
    GoRoute(
      path: '/student_login',
      builder: (context, state) => StudentLoginScreen(),
    ),
    //stu sign
    GoRoute(
      path: '/student_signup',
      builder: (context, state) => StudentSignUpScreen(),
    ),

    GoRoute(
      path: '/home',
      builder: (context, state) =>Home (),
    ),
    GoRoute(
      path: '/real-profile',
      builder: (context, state) =>RealProfile (),
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) => LeaderboardScreen(),
    ),
    GoRoute(
      path: '/subscription',
      builder: (context, state) {
        final category = state.extra as FirebaseCategoryModel?;
        return SubscriptionScreen(pendingCategory: category);
      },
    ),
    GoRoute(
      path: '/otp_verification',
      builder: (context, state) {
        final msisdn = state.extra as String;
        return OtpVerificationScreen(msisdn: msisdn);
      },
    ),
  ],
);
