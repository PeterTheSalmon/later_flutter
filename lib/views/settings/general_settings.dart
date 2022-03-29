import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:later_flutter/intro_screen/intro_screen.dart';
import 'package:later_flutter/views/drawer/standard_drawer.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({Key? key, this.highlightPlatforms = false})
      : super(key: key);
  final bool highlightPlatforms;

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
    fToast = FToast();
    fToast.init(context);
    _handleOverlays();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  int _tapCount = 0;
  late FToast fToast;
  double opacity = 0.0;

  Future<void> _handleOverlays() async {
    if (widget.highlightPlatforms == false) return;
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity = 0.3;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      opacity = 0.1;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      opacity = 0.3;
    });
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      opacity = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool displayMobileLayout = MediaQuery.of(context).size.width < 550;
    return Row(
      children: [
        if (!displayMobileLayout) const DesktopDrawer(),
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
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.link),
                          title: Text('Later v${_packageInfo.version}'),
                          onTap: () {
                            setState(() {
                              _tapCount++;
                            });
                            if (_tapCount >= 7) {
                              fToast.showToast(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                    vertical: 12.0,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.0),
                                    color: Colors.grey,
                                  ),
                                  child: const Text(
                                    'This is not the easter egg you are looking for...',
                                  ),
                                ),
                              );
                              _tapCount = 0;
                              return;
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.info),
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'Later',
                              applicationIcon: const Image(
                                image: AssetImage('assets/Icon256x256@2x.png'),
                                height: 100,
                              ),
                              applicationVersion: _packageInfo.version,
                            );
                          },
                          title: const Text('Licenses'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.web),
                          title: const Text('Visit My Website'),
                          onTap: () {
                            launch('https://petersalmon.dev');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.code),
                          title: const Text('View Source'),
                          onTap: () {
                            launch(
                              'https://github.com/peterthesalmon/later_flutter',
                            );
                          },
                        ),
                        Stack(
                          children: [
                            Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.computer),
                                  title: const Text('Download the macOS app'),
                                  onTap: () {
                                    launch(
                                      'https://github.com/peterthesalmon/later/releases',
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.android),
                                  title: const Text('Download the Android app'),
                                  onTap: () {
                                    launch(
                                      'https://github.com/PeterTheSalmon/later_flutter/releases',
                                    );
                                  },
                                ),
                              ],
                            ),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 500),
                                  opacity: opacity,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(2.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ListTile(
                          leading: const Icon(Icons.web),
                          title: const Text('Open Web App'),
                          onTap: () {
                            launch('https://later.petersalmon.dev');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.replay),
                          title: const Text('Replay Intro'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AppIntroScreen(
                                  isAReplay: true,
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.update),
                          title: const Text('Update link format'),
                          onTap: () async {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Update link format?'),
                                content: const Text(
                                  "You should only do this once! All archived statuses will be deleted. If you don't know what this will do, do not proceed!",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      final linkQuerySnapshot =
                                          await FirebaseFirestore.instance
                                              .collection('links')
                                              .where(
                                                'userId',
                                                isEqualTo: FirebaseAuth
                                                    .instance.currentUser!.uid,
                                              )
                                              .get();
                                      for (final doc
                                          in linkQuerySnapshot.docs) {
                                        FirebaseFirestore.instance
                                            .collection('links')
                                            .doc(doc.id)
                                            .update({
                                          'archived': false,
                                        });
                                      }
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Updated link format'),
                                        ),
                                      );
                                    },
                                    child: const Text('Continue'),
                                  )
                                ],
                              ),
                            );
                          },
                        )
                      ],
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
