import 'package:flutter/material.dart';
import 'package:later_flutter/views/standard_drawer.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var isDialOpen = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Later"),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Colors.orange,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add_link),
            label: "Save Link",
            onTap: () {},
          ),
          SpeedDialChild(
            child: const Icon(Icons.folder),
            label: "Create Folder",
            onTap: () {},
          ),
        ],
      ),
      drawer: const Drawer(child: StandardDrawer()),
      body: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Center(
            child: Column(
              children: const [
                Text("Home", style: TextStyle(fontSize: 20)),
                Text("Currently Unimplemented"),
              ],
            ),
          )),
    );
  }
}
