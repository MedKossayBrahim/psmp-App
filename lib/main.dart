import 'package:flutter/material.dart';
import 'package:psmp_new/pages/login_page.dart';
import 'package:psmp_new/pages/splash_screen.dart';
import 'pages/driver_form_page.dart';
import 'pages/home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the .env file before the app starts
  await dotenv.load(fileName: ".env");

  runApp(const CarServicesApp());
}

class CarServicesApp extends StatelessWidget {
  const CarServicesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Services',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'SF Pro Display',
      ),
      home: const SplashScreen(),
      // home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
