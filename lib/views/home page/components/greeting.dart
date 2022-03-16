import 'package:flutter/material.dart';
import 'package:later_flutter/services/global_variables.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

class GreetingMessage extends StatelessWidget {
  GreetingMessage({
    Key? key,
  }) : super(key: key);

  final int currentTime = DateTime.now().hour;

  final morningIndex = Random().nextInt(Globals.morningGreetings.length);
  final afternoonIndex = Random().nextInt(Globals.afternoonGreetings.length);
  final eveningIndex = Random().nextInt(Globals.eveningGreetings.length);

  @override
  Widget build(BuildContext context) {
    return Text(
        currentTime > 22
            ? "Don't stay up too later!"
            : currentTime < 12
                ? "${Globals.morningGreetings[morningIndex]}${FirebaseAuth.instance.currentUser?.displayName ?? "Set your display name in Account settings"}!"
                : currentTime < 17
                    ? "${Globals.afternoonGreetings[afternoonIndex]}${FirebaseAuth.instance.currentUser?.displayName ?? "Set your display name in Account settings"}."
                    : "${Globals.eveningGreetings[eveningIndex]}${FirebaseAuth.instance.currentUser?.displayName ?? "Set your display name in Account settings"}.",
        style: const TextStyle(fontSize: 20),
        textAlign: TextAlign.center);
  }
}
