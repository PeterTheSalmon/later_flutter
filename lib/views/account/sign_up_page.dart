import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:later_flutter/services/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController confirmEmailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final TextEditingController nameController = TextEditingController();

  SignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create an Account"),
      ),
      body: Center(
        child: SizedBox(
          width: kIsWeb
              ? 300
              : Platform.isMacOS
                  ? 300
                  : Platform.isWindows
                      ? 300
                      : MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: ListView(
              children: [

                // text fields
                TextFormField(
                  decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.person),
                      labelText: "Display Name",
                      enabledBorder: UnderlineInputBorder()),
                  controller: nameController,
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
                      suffixIcon: Icon(Icons.email),
                      labelText: "Confirm Email",
                      enabledBorder: UnderlineInputBorder()),
                  controller: confirmEmailController,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.lock),
                      labelText: "Password",
                      enabledBorder: UnderlineInputBorder()),
                  controller: passwordController,
                  obscureText: true,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.lock),
                      labelText: "Confirm Password",
                      enabledBorder: UnderlineInputBorder()),
                  controller: confirmPasswordController,
                  obscureText: true,
                ),

                // sign up button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<AuthenticationService>().signUp(
                            emailController.text.trim(),
                            confirmEmailController.text.trim(),
                            passwordController.text.trim(),
                            confirmPasswordController.text.trim(),
                            nameController.text.trim(),
                            context,
                          );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("START"),
                  ),
                ),

                // error message
                Consumer<AuthenticationService>(
                    builder: (context, authenticationService, child) =>
                        SizedBox(
                            height: 50,
                            child: Text(
                                authenticationService.errorMessage ?? ""))),

                // tos and user agreement
                Row(
                  children: const [
                    Spacer(),
                    Text("By creating an acount you agree to the"),
                    Spacer()
                  ],
                ),
                const TermsPrivacyLinks(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TermsPrivacyLinks extends StatelessWidget {
  const TermsPrivacyLinks({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          child: const Text("Privacy Policy",
              style: TextStyle(color: Colors.blueAccent)),
          onTap: () async {
            const url =
                "https://github.com/PeterTheSalmon/Later/blob/main/Later%20Privacy%20Policy%20-%20January%2031%202022.pdf";
            if (await canLaunch(url)) {
              launch(url, forceWebView: true, enableJavaScript: true);
            }
          },
        ),
        const Text(" and "),
        GestureDetector(
          child: const Text("Terms of Use",
              style: TextStyle(color: Colors.blueAccent)),
          onTap: () async {
            const url =
                "https://github.com/PeterTheSalmon/Later/blob/main/Later%20Terms%20of%20Use%20-%20January%2031%202022.pdf";
            if (await canLaunch(url)) {
              launch(url, forceWebView: true, enableJavaScript: true);
            }
          },
        ),
      ],
    );
  }
}
