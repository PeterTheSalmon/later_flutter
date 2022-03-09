import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:later_flutter/services/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/services/global_variables.dart';
import 'package:later_flutter/views/account/sign_up_page.dart';
import 'package:provider/provider.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool passwordObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: kIsWeb
                ? 300
                : Platform.isMacOS
                    ? 300
                    : Platform.isWindows
                        ? 300
                        : MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                      // * Gross code to add space above the textfields
                      height: kIsWeb
                          ? MediaQuery.of(context).size.height * 0.3
                          : Platform.isIOS
                              ? 50
                              : Platform.isAndroid
                                  ? 50
                                  : MediaQuery.of(context).size.height * 0.3),
                  Text(
                    "Sign in to Later",
                    style: TextStyle(
                        color: Globals.appColour,
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
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                            icon: passwordObscured
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                            onPressed: () {
                              setState(() {
                                passwordObscured = !passwordObscured;
                              });
                            }),
                        labelText: "Password",
                        enabledBorder: const UnderlineInputBorder()),
                    controller: passwordController,
                    obscureText: passwordObscured,
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
                      builder: (context, authenticationService, child) =>
                          SizedBox(
                              height: 50,
                              child: Text(
                                  authenticationService.errorMessage ?? ""))),
                  const Spacer(),
                  const Divider(
                    thickness: 2.0,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpPage()));
                    },
                    child: const Text(
                      "NO ACCOUNT? SIGN UP INSTEAD",
                      style: TextStyle(),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
