import 'package:flutter/material.dart';
import 'package:later_flutter/views/standard_drawer.dart';
import 'package:package_info_plus/package_info_plus.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({Key? key}) : super(key: key);

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      drawer: const Drawer(child: StandardDrawer()),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextButton(
                  onPressed: () {
                    showAboutDialog(
                      context: context,
                      children: [const Text("Thank you for using Later!")],
                      applicationName: 'Later',
                      applicationVersion: _packageInfo.version,
                    );
                  },
                  child: const Text("About"))
            ],
          ),
        ),
      ),
    );
  }
}
