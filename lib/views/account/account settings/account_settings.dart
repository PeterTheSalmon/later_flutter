import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/services/authentication_service.dart';
import 'package:later_flutter/views/account/account%20settings/components/change_display_name.dart';
import 'package:later_flutter/views/account/account%20settings/components/delete_account_button.dart';
import 'package:later_flutter/views/account/account%20settings/components/sign_out_button.dart';
import 'package:later_flutter/views/account/delete_account_view.dart';
import 'package:later_flutter/views/drawer/standard_drawer.dart';
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
    final bool displayMobileLayout = MediaQuery.of(context).size.width < 550;
    return Row(children: [
      if (!displayMobileLayout)
        const Drawer(
          child: StandardDrawer(),
        ),
      Expanded(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Account'),
          ),
          drawer: displayMobileLayout
              ? const Drawer(child: StandardDrawer())
              : null,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // * Main content
                    const Text(
                      'Manage your account',
                      style: TextStyle(fontSize: 24),
                    ),
                    Text(FirebaseAuth.instance.currentUser?.email ?? '',
                        style: const TextStyle(fontSize: 14)),
                    const Divider(),
                    const SignOutButton(),
                    const SizedBox(height: 5),
                    const DisplayNameButton(),
                    const SizedBox(height: 5),

                    // * Password reset
                    OutlinedButton(
                      child: Text(
                        _passwordResetSent ? "Email Sent!" : "Reset Password",
                        style: TextStyle(
                            color: _passwordResetSent ? Colors.green : null),
                      ),
                      onPressed: () {
                        context
                            .read<AuthenticationService>()
                            .resetPassword(context);
                        setState(() {
                          _passwordResetSent = true;
                        });
                      },
                    ),

                    const SizedBox(height: 5),
                    const DeleteAccountButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    ]);
  }
}
