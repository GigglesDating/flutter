import 'package:flutter/material.dart';
import 'package:giggles/screens/auth/aadhar_verification/adhar_verification_page.dart';
import 'package:giggles/screens/splash_page.dart';
import 'package:flutter/services.dart';
import 'package:giggles/screens/user/user_profile_creation_page.dart';
import 'package:giggles/screens/user/while_waiting_events_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/appTheme.dart';
import 'constants/database/shared_preferences_service.dart';
import 'network/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPref.preferences = await SharedPreferences.getInstance();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: _themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      home:  SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
