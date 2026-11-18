import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core.dart';
import 'screens/auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF020A2A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const IncoexApp());
}

class IncoexApp extends StatelessWidget {
  const IncoexApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INCOEX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: K.navy,
        colorScheme: ColorScheme.fromSeed(seedColor: K.blue, brightness: Brightness.dark),
        textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.white),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
