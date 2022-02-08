import 'package:flutter/cupertino.dart';
import 'package:later_flutter/services/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/views/sign_up_page.dart';
import 'package:provider/provider.dart';

class LogInPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LogInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            const Spacer(),
            const Text(
              "Sign in to Later",
              style: TextStyle(
                  color: Colors.orange,
                  fontSize: 30,
                  fontWeight: FontWeight.w800),
            ),
            TextFormField(
              decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.email),
                  labelText: "Email",
                  enabledBorder: UnderlineInputBorder()),
              controller: emailController,
            ),
            TextFormField(
              decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.lock),
                  labelText: "Password",
                  enabledBorder: UnderlineInputBorder()),
              controller: passwordController,
              obscureText: true,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<AuthenticationService>().signIn(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text("SIGN IN"),
              ),
            ),
            Consumer<AuthenticationService>(
                builder: (context, authenticationService, child) => SizedBox(
                    height: 50,
                    child: Text(authenticationService.errorMessage ?? ""))),
            const Spacer(),
            const Divider(
              thickness: 2.0,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    CupertinoPageRoute(builder: (context) => SignUpPage()));
              },
              child: const Text(
                "NO ACCOUNT? SIGN UP INSTEAD",
                style: TextStyle(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
