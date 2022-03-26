import 'package:flutter/material.dart';
import 'package:later_flutter/services/authentication_service.dart';
import 'package:provider/provider.dart';

class SignOutButton extends StatelessWidget {
  const SignOutButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.exit_to_app),
      title: const Text('Sign Out'),
      onTap: () {
        context.read<AuthenticationService>().signOut(context);
      },
    );
  }
}
