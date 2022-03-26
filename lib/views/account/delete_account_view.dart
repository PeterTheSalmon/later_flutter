import 'package:flutter/material.dart';
import 'package:later_flutter/services/authentication_service.dart';
import 'package:later_flutter/services/authentication_wrapper.dart';
import 'package:provider/provider.dart';

class DeleteAccountView extends StatefulWidget {
  const DeleteAccountView({Key? key}) : super(key: key);

  @override
  State<DeleteAccountView> createState() => _DeleteAccountViewState();
}

class _DeleteAccountViewState extends State<DeleteAccountView> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _titleText(),
              _passwordText(_passwordController),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: ElevatedButton(
                      child: const Text('Delete Account'),
                      onPressed: () {
                        _deleteAccount(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteAccount(BuildContext context) async {
    await context.read<AuthenticationService>().reauthenticate(
          _passwordController.text,
        );
    if (context.read<AuthenticationService>().errorMessage == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Are you sure?'),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: const Text(
              'All account data will be lost. This action cannot be undone. Are you sure you want to delete your account?',
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Delete'),
              onPressed: () async {
                await context.read<AuthenticationService>().deleteAccount();
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuthenticationWrapper(),
                  ),
                );
              },
            ),
          ],
        ),
      );
    } else {
      // show a snackbar
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(context.read<AuthenticationService>().errorMessage!),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  Container _passwordText(TextEditingController passwordController) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: TextField(
        controller: passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Password',
        ),
      ),
    );
  }

  Container _titleText() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: const Text(
        'Enter your password to delete your account',
        style: TextStyle(fontSize: 24),
        textAlign: TextAlign.center,
      ),
    );
  }
}
