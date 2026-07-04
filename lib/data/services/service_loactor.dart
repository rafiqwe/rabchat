import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:rabchats/data/repositories/auth_repo.dart';
import 'package:rabchats/firebase_options.dart';
import 'package:rabchats/logic/cubit/auth_cubit.dart';
import 'package:rabchats/router/app_router.dart';

final getIt = GetIt.instance;

Future<void> setUpServiceLoator() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  getIt.registerLazySingleton(() => AppRouter());
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => AuthRepo());
  getIt.registerFactory(() => AuthCubit(authRepo: AuthRepo()));
}
