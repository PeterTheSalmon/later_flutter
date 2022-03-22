import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/services/authentication_service.dart';
import 'package:later_flutter/views/account/account%20settings/components/change_display_name.dart';
import 'package:later_flutter/views/account/account%20settings/components/delete_account_button.dart';
import 'package:later_flutter/views/account/account%20settings/components/sign_out_button.dart';
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
      if (!displayMobileLayout) const DesktopDrawer(),
      Expanded(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Account'),
          ),
          drawer: displayMobileLayout
              ? const Drawer(child: StandardDrawer())
              : null,
          body: SingleChildScrollView(
              child: Center(
                  child: Container(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi there, ${FirebaseAuth.instance.currentUser?.displayName ?? "User"}",
                    style: const TextStyle(fontSize: 24),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? '',
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Divider(),
                  const SignOutButton(),
                  const DisplayNameButton(),

                  // * Password reset
                  ListTile(
                    leading: const Icon(Icons.password),
                    title: Text(
                      _passwordResetSent ? "Email Sent!" : "Reset Password",
                      style: TextStyle(
                          color: _passwordResetSent ? Colors.green : null),
                    ),
                    onTap: () {
                      if (_passwordResetSent) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              const Text("Password reset email already sent"),
                          action: SnackBarAction(
                            label: "Got it!",
                            onPressed: () {},
                          ),
                        ));
                        return;
                      }
                      context
                          .read<AuthenticationService>()
                          .resetPassword(context);
                      setState(() {
                        _passwordResetSent = true;
                      });
                    },
                  ),

                  const DeleteAccountButton(),
                ],
              ),
            ),
          ))),
        ),
      )
    ]);
  }
}
