import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/services/authentication_service.dart';
import 'package:later_flutter/views/folder_list.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Later"),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            SizedBox(
                width: 310,
                height: 90,
                child: DrawerHeader(
                    decoration: const BoxDecoration(color: Colors.orange),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Later",
                            style: TextStyle(fontSize: 24)),
                        Text(FirebaseAuth.instance.currentUser!.email!)
                      ],
                    ))),
            const ListTile(
              title: Text("Account"),
              leading: Icon(Icons.person),
            ),
            const ListTile(
              title: Text("Settings"),
              leading: Icon(Icons.settings),
            ),
            const ListTile(
              title: Text("Manage Folders"),
              leading: Icon(Icons.folder_open),
            ),
            const Divider(),
            const Expanded(child: FolderList())
          ],
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Center(
            child: Column(
              children: [
                const Text("Home", style: TextStyle(fontSize: 20)),
                const Text("Current Unimplemented"),
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
