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
        actions: [
          IconButton(
              onPressed: () {
                showNewLinkSheet(context);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      drawer: const Drawer(child: StandardDrawer()),
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

Future<void> showNewLinkSheet(BuildContext context) {
  TextEditingController titleController = TextEditingController();
  TextEditingController urlController = TextEditingController();

  return showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  const Text(
                    "Add New Link",
                    style: TextStyle(fontSize: 18),
                  ),
                  const Spacer(),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close))
                ],
              ),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.title),
                    labelText: "Title",
                    enabledBorder: UnderlineInputBorder()),
              ),
              TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.link),
                      labelText: "URL",
                      enabledBorder: UnderlineInputBorder())),
              DropdownButton(
                
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("First")),
                    DropdownMenuItem(value: 2, child: Text("Second"))
                  ],
                  onChanged: (value) {}),
              Center(
                  child: ElevatedButton(
                      onPressed: () {}, child: const Text("SAVE")))
            ],
          ),
        ),
      );
    },
  );
}
