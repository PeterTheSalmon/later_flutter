import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:later_flutter/firebase_options.dart';
import 'package:later_flutter/services/authentication_service.dart';
import 'package:later_flutter/services/authentication_wrapper.dart';
import 'package:later_flutter/services/global_variables.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent));
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
          theme: ThemeData(
            appBarTheme: AppBarTheme(
              color: Globals.appColour,
            ),
            primarySwatch: Globals().appSwatch(),
            brightness: Brightness.light,
            primaryColor: Globals.appColour,
          ),
          darkTheme: ThemeData(
              primarySwatch: Globals().appSwatch(),
              brightness: Brightness.dark,
              primaryColor: Globals.appColour),
          home: const AuthenticationWrapper(),
        ));
  }
}
