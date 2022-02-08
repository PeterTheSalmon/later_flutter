import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/views/folder_list.dart';
import 'package:later_flutter/views/home_page.dart';

class StandardDrawer extends StatelessWidget {
  const StandardDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            width: 310,
            height: 150,
            child: DrawerHeader(
                decoration: const BoxDecoration(color: Colors.orange),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Later", style: TextStyle(fontSize: 24)),
                    Text(FirebaseAuth.instance.currentUser!.email!)
                  ],
                ))),
        ListTile(
          title: const Text("Home"),
          leading: const Icon(Icons.home),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomePage()));
          },
        ),
        const ListTile(
          title: Text("Account"),
          leading: Icon(Icons.person),
        ),
        const ListTile(
          title: Text("Settings"),
          leading: Icon(Icons.settings),
        ),
        const SizedBox(
          height: 60,
          child: ListTile(
            title: Text("Manage Folders"),
            leading: Icon(Icons.folder_open),
          ),
        ),
        const Divider(),
        const Expanded(child: FolderList())
      ],
    );
  }
}
