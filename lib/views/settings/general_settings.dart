import 'package:flutter/material.dart';
import 'package:later_flutter/views/components/standard_drawer.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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

  bool _switchValue = false;

  @override
  Widget build(BuildContext context) {
    final bool displayMobileLayout = MediaQuery.of(context).size.width < 550;
    return Row(
      children: [
        if (!displayMobileLayout)
          const Drawer(
            child: StandardDrawer(),
          ),
        Expanded(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Settings'),
            ),
            drawer: displayMobileLayout
                ? const Drawer(child: StandardDrawer())
                : null,
            body: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 550),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Text(
                                    "Very Real Toggle Definitely Does Stuff"),
                                const Spacer(),
                                Switch(
                                    value: _switchValue,
                                    onChanged: (value) {
                                      setState(() {
                                        _switchValue = value;
                                      });
                                    }),
                              ],
                            ),
                          ),
                          const Divider(),
                          ListTile(
                              leading: const Icon(Icons.info),
                              onTap: () {
                                showAboutDialog(
                                  context: context,
                                  applicationName: 'Later',
                                  applicationIcon: const Image(
                                    image:
                                        AssetImage('assets/Icon256x256@2x.png'),
                                    height: 100,
                                  ),
                                  applicationVersion: _packageInfo.version,
                                );
                              },
                              title: const Text("About")),
                          ListTile(
                            leading: const Icon(Icons.web),
                            title: const Text("Visit My Website"),
                            onTap: () {
                              launch("https://petersalmon.dev");
                            },
                          ),
                          ListTile(
                              leading: const Icon(Icons.code),
                              title: const Text("View Source"),
                              onTap: () {
                                launch(
                                    "https://github.com/peterthesalmon/later_flutter");
                              }),
                          ListTile(
                              leading: const Icon(Icons.computer),
                              title: const Text("Download the macOS app"),
                              onTap: () {
                                launch(
                                    "https://github.com/peterthesalmon/later/releases");
                              })
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
