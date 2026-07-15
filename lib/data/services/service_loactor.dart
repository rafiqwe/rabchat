import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:rabchats/data/repositories/auth_repo.dart';
import 'package:rabchats/data/repositories/chat_repo.dart';
import 'package:rabchats/data/repositories/contacts_repo.dart';
import 'package:rabchats/firebase_options.dart';
import 'package:rabchats/logic/chat/chat_cubit.dart';
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
  getIt.registerLazySingleton(() => ContactsRepo());
  getIt.registerLazySingleton(() => ChatRepo());
  getIt.registerLazySingleton(() => AuthCubit(authRepo: AuthRepo()));

  getIt.registerFactory(() {
    return ChatCubit(
      chatRepo: ChatRepo(),
      currentUserId: getIt<FirebaseAuth>().currentUser?.uid ?? '',
    );
  });
}
