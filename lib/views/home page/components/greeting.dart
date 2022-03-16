import 'package:flutter/material.dart';
import 'package:later_flutter/services/global_variables.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GreetingMessage extends StatelessWidget {
  const GreetingMessage({
    Key? key,
    required this.currentTime,
    required this.morningIndex,
    required this.afternoonIndex,
    required this.eveningIndex,
  }) : super(key: key);

  final int currentTime;

  final int morningIndex;
  final int afternoonIndex;
  final int eveningIndex;

  @override
  Widget build(BuildContext context) {
    return Text(
        currentTime > 22
            ? "Don't stay up too late!"
            : currentTime < 12
                ? "${Globals.morningGreetings[morningIndex]}${FirebaseAuth.instance.currentUser?.displayName ?? "Set your display name in Account settings"}!"
                : currentTime < 17
                    ? "${Globals.afternoonGreetings[afternoonIndex]}${FirebaseAuth.instance.currentUser?.displayName ?? "Set your display name in Account settings"}."
                    : "${Globals.eveningGreetings[eveningIndex]}${FirebaseAuth.instance.currentUser?.displayName ?? "Set your display name in Account settings"}.",
        style: const TextStyle(fontSize: 20),
        textAlign: TextAlign.center);
  }
}
