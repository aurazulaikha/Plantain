import 'package:flutter/material.dart';
import 'package:plantain/login.dart';
import 'package:plantain/onboarding.dart';
import 'package:plantain/register.dart';
import 'package:plantain/mainNavigation.dart';
import 'package:plantain/adminNavigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF1B5E20);
    const primaryGreen = Color.fromARGB(255, 79, 149, 81);

    return MaterialApp(
      title: 'Plantain',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkGreen,
          primary: primaryGreen,
          brightness: Brightness.light,
        ),
        primaryColor: primaryGreen,
        scaffoldBackgroundColor: Colors.white,

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),

      home: const OnboardingScreen(),

      routes: {
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        "/home": (context) => const MainNavigation(),
        "/admin": (context) => const AdminNavigation(),
      },
    );
  }
}
