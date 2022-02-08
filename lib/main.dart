import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/firebase_options.dart';
import 'package:later_flutter/services/authentication_service.dart';
import 'package:later_flutter/views/authentication_wrapper.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LaterApp());
}

class LaterApp extends StatelessWidget {
  const LaterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ListenableProvider<AuthenticationService>(
              create: (_) =>
                  AuthenticationService(FirebaseAuth.instance, null)),
          StreamProvider(
            create: (context) =>
                context.read<AuthenticationService>().authStateChanges,
            initialData: null,
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Later",
          theme: ThemeData(primarySwatch: Colors.orange),
          darkTheme: ThemeData(primarySwatch: Colors.orange),
          home: const AuthenticationWrapper(),
        ));
  }
}
