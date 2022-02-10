import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/services/authentication_service.dart';
import 'package:later_flutter/views/standard_drawer.dart';
import 'package:provider/provider.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({Key? key}) : super(key: key);

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  bool _passwordResetSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      drawer: const Drawer(child: StandardDrawer()),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Account Settings',
              style: TextStyle(fontSize: 24),
            ),
            Text(FirebaseAuth.instance.currentUser?.email ?? '',
                style: const TextStyle(fontSize: 14)),
            const Divider(),
            OutlinedButton(
                onPressed: () {
                  context.read<AuthenticationService>().signOut(context);
                },
                child: const Text("Sign Out")),
            const SizedBox(height: 8),
            OutlinedButton(
                onPressed: () {
                  context.read<AuthenticationService>().resetPassword(context);
                  setState(() {
                    _passwordResetSent = true;
                  });
                },
                child: Text(
                  _passwordResetSent ? "Email Sent!" : "Reset Password",
                  style: TextStyle(
                      color: _passwordResetSent ? Colors.green : null),
                )),
          ],
        ),
      ),
    );
  }
}
