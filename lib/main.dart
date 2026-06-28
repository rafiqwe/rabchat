import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rabchats/config/theme/app_theme.dart';
import 'package:rabchats/data/services/service_loactor.dart';
import 'package:rabchats/pressentation/screen/login_screen.dart';
import 'package:rabchats/router/app_router.dart';

void main() async {
  await setUpServiceLoator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RabChat',
      navigatorKey: getIt<AppRouter>().navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: LoginScreen(),
    );
  }
}







