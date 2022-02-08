import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LaterApp());
}

class LaterApp extends StatelessWidget {
  const LaterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Text("Later"),
    );
  }
}
