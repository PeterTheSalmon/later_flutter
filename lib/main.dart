import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:later_flutter/firebase_options.dart';
import 'package:later_flutter/services/authentication_service.dart';
import 'package:later_flutter/services/authentication_wrapper.dart';
import 'package:later_flutter/services/global_variables.dart';
import 'package:later_flutter/services/scroll_physics.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // necessary when main is async, I believe
  WidgetsFlutterBinding.ensureInitialized();

  // initialize firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // set android nav and status bar to be transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // initialize shared prefences
  final prefs = await SharedPreferences.getInstance();

  // check if intro seen
  final bool? hasSeenIntro = prefs.getBool('hasSeenIntro');
  if (hasSeenIntro == null || hasSeenIntro == false) {
    Globals.hasSeenIntro = false;
  } else {
    Globals.hasSeenIntro = true;
  }

  // check if data has been shared
  final String? previousShared = prefs.getString('previousShared');
  if (previousShared != null) {
    Globals.sharedUrl = previousShared;
  }

  runApp(const LaterApp());
}

class LaterApp extends StatelessWidget {
  const LaterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance, null),
        ),
        StreamProvider(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        builder: (context, widget) {
          return ScrollConfiguration(
            // ? Is it unsafe to force unwrap the `widget`?
            behavior: const CustomScrollBehaviour(),
            child: widget!,
          );
        },
        debugShowCheckedModeBanner: false,
        title: 'Later',
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            color: Globals.appColour,
          ),
          primarySwatch: Globals().appSwatch(),
          brightness: Brightness.light,
          primaryColor: Globals.appColour,
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color.fromARGB(
              255,
              255,
              255,
              255,
            ),
            actionTextColor: Globals.appColour,
            contentTextStyle: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        darkTheme: ThemeData(
          primarySwatch: Globals().appSwatch(),
          brightness: Brightness.dark,
          primaryColor: Globals.appColour,
          snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            contentTextStyle: TextStyle(color: Colors.white),
            backgroundColor: Color.fromARGB(
              255,
              66,
              66,
              66,
            ),
          ),
        ),
        home: const AuthenticationWrapper(),
      ),
    );
  }
}
