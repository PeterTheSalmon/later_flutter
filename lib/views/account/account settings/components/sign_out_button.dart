import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:later_flutter/services/authentication_service.dart';
import 'package:provider/provider.dart';

class SignOutButton extends StatelessWidget {
  const SignOutButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      child: const Text("Sign Out"),
      onPressed: () {
        context.read<AuthenticationService>().signOut(context);
      },
    );
  }
}
