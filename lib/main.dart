import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/webview_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF10141D),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const DooballApp());
}

class DooballApp extends StatelessWidget {
  const DooballApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dooball Live',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0E14),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676), // Vibrant Neon Pitch Green
          secondary: Color(0xFF2979FF),
          surface: Color(0xFF141923),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF10141D),
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF171D29),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        useMaterial3: true,
      ),
      home: const WebViewScreen(),
    );
  }
}
