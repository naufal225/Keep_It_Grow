import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keep_it_grow/screens/auth/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:keep_it_grow/core/navigation/app_router.dart';
import 'screens/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await initializeDateFormatting('id_ID', null);
  AppRouter.registerLoginRedirectHandler(() {
    final navigator = AppRouter.navigatorKey.currentState;
    if (navigator == null) {
      return;
    }

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppRouter.navigatorKey,
      title: 'Aplikasi Edukasi Sekolah',
      theme: ThemeData(
        primaryColor: Color(0xFF3B82F6),
        scaffoldBackgroundColor: Color(0xFFF9FAFB),
        fontFamily: 'Inter',
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
