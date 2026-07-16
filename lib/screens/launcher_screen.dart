import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app_2/utils/shared_pref_service/shared_pref.dart';


class LauncherScreen extends StatefulWidget {
  const LauncherScreen({super.key});

  @override
  State<LauncherScreen> createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Wait for 2 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 2));

    final token = await SharedPref.getToken();
    final role = await SharedPref.getRole();

    if (mounted) {
      if (token != null && token.isNotEmpty) {
        if (role == 'admin') {
          context.go('/admin-home');
        } else {
          // Defaults to student if there's a token
          context.go('/home');
        }
      } else {
        context.go('/role-selection');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline_sharp,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'QuizifyMe',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}