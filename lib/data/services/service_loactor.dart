import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:rabchats/firebase_options.dart';
import 'package:rabchats/router/app_router.dart';


final getIt = GetIt.instance;

Future<void> setUpServiceLoator() async {
  getIt.registerLazySingleton(()=> AppRouter());

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

}
