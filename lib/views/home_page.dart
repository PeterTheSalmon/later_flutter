import 'package:flutter/material.dart';
import 'package:later_flutter/services/authentication_service.dart';
import 'package:later_flutter/views/standard_drawer.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Later"),
      ),
      drawer: const Drawer(
        child: StandardDrawer()),
      body: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Center(
            child: Column(
              children: [
                const Text("Home", style: TextStyle(fontSize: 20)),
                const Text("Currently Unimplemented"),
                TextButton(
                    onPressed: () {
                      context.read<AuthenticationService>().signOut();
                    },
                    child: const Text("Sign Out")),
              ],
            ),
          )),
    );
  }
}

