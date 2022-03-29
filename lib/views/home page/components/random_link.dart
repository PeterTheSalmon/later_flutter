import 'dart:math';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RandomLink extends StatefulWidget {
  const RandomLink({
    Key? key,
  }) : super(key: key);

  @override
  State<RandomLink> createState() => _RandomLinkState();
}

class _RandomLinkState extends State<RandomLink> {
  DocumentSnapshot? _randomLink;

  /// Fetches a random link from firebase
  /// The list of folders is fetched first for efficiency
  /// Instead of reading every link a user has, a random folder is chosen and, from there,
  /// a link is selected at random. This reduces the number of reads to firebase.
  void setRandomLink() async {
    final QuerySnapshot folderDocs = await FirebaseFirestore.instance
        .collection('folders')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    final List<DocumentSnapshot> folderList = folderDocs.docs;

    int attempts = 0;
    Future<DocumentSnapshot?> _selectLink() async {
      // Choose a random folder
      final DocumentSnapshot folder =
          folderList[Random().nextInt(folderList.length)];

      // Get the list of links in the folder
      final QuerySnapshot linkDocs = await FirebaseFirestore.instance
          .collection('links')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('parentFolderId', isEqualTo: folder.id)
          .get();
      final List<DocumentSnapshot> links = linkDocs.docs;

      if (links.isEmpty && attempts > 10) {
        attempts++;
        _selectLink();
      } else {
        return links[Random().nextInt(links.length)];
      }
      return null;
    }

    final finalLink = await _selectLink();

    setState(() {
      _randomLink = finalLink;
    });
  }

  @override
  void initState() {
    super.initState();
    setRandomLink();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _randomLink == null
          ? const Card()
          : SizedBox(
              height: kIsWeb ? 72 : 260,
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      onTap: () => _launchURL(_randomLink!),
                      leading: SizedBox(
                        height: 48,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Open in browser',
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () => _launchURL(_randomLink!),
                        ),
                      ),
                      title: Text(
                        _randomLink!['title'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        _randomLink!['url'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!kIsWeb)
                      SizedBox(
                        height: 180,
                        child: AnyLinkPreview(
                          link: _randomLink!['url'] as String,
                          borderRadius: 0,
                          boxShadow: const [],
                          bodyMaxLines: 2,
                          backgroundColor:
                              MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark
                                  ? const Color.fromARGB(255, 66, 66, 66)
                                  : const Color.fromARGB(255, 243, 243, 243),
                          titleStyle: TextStyle(
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                          placeholderWidget: Container(
                            decoration: BoxDecoration(
                              color: MediaQuery.of(context)
                                          .platformBrightness ==
                                      Brightness.dark
                                  ? const Color.fromARGB(255, 66, 66, 66)
                                  : const Color.fromARGB(255, 243, 243, 243),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: Container(
                            decoration: BoxDecoration(
                              color: MediaQuery.of(context)
                                          .platformBrightness ==
                                      Brightness.dark
                                  ? const Color.fromARGB(255, 66, 66, 66)
                                  : const Color.fromARGB(255, 243, 243, 243),
                            ),
                            child: const Center(
                              child: Text('No Preview Available :('),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  void _launchURL(DocumentSnapshot randomLink) async {
    if (await canLaunch(randomLink['url'] as String)) {
      launch(
        randomLink['url'] as String,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Could not launch ${randomLink["url"]}"),
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {},
          ),
        ),
      );
    }
  }
}
