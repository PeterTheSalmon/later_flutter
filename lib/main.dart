import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:later_flutter/firebase_options.dart';
import 'package:later_flutter/services/authentication_service.dart';
import 'package:later_flutter/views/authentication_wrapper.dart';
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
    Map<int, Color> colorMap = {
      50: const Color.fromRGBO(255, 167, 38, .1),
      100: const Color.fromRGBO(255, 167, 38, .2),
      200: const Color.fromRGBO(255, 167, 38, .3),
      300: const Color.fromRGBO(255, 167, 38, .4),
      400: const Color.fromRGBO(255, 167, 38, .5),
      500: const Color.fromRGBO(255, 167, 38, .6),
      600: const Color.fromRGBO(255, 167, 38, .7),
      700: const Color.fromRGBO(255, 167, 38, .8),
      800: const Color.fromRGBO(255, 167, 38, .9),
      900: const Color.fromRGBO(255, 167, 38, 1),
    };
    MaterialColor primaryColor = MaterialColor(0xFFFFA726, colorMap);

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
              primarySwatch: Colors.orange, brightness: Brightness.light),
          darkTheme: ThemeData(
              primarySwatch: Colors.orange, brightness: Brightness.dark),
          home: const AuthenticationWrapper(),
        ));
  }
}
