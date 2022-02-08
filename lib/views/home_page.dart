import 'package:flutter/material.dart';
import 'package:later_flutter/views/folder_list.dart';

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
            Container(
                width: 310,
                child: const DrawerHeader(
                    decoration: BoxDecoration(color: Colors.orange),
                    child: Text("Later",
                        style: TextStyle(color: Colors.white, fontSize: 24)))),
            const Expanded(child: FolderList())
          ],
        ),
      ),
      body: const Text("Home"),
    );
  }
}
