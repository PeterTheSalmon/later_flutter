// ignore_for_file: must_be_immutable

import 'package:any_link_preview/any_link_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:later_flutter/views/links/link%20detail%20view/link_detail_bottom_nav_bar.dart';
import 'package:later_flutter/views/links/notes_dialog.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkDetailView extends StatefulWidget {
  LinkDetailView({Key? key, required this.document}) : super(key: key);

  DocumentSnapshot document;

  @override
  State<LinkDetailView> createState() => _LinkDetailViewState();
}

class _LinkDetailViewState extends State<LinkDetailView> {
  late DocumentSnapshot? _backupDocument;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document['title'] as String),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share),
            onPressed: () async {
              Share.share(
                widget.document['url'] as String,
                subject: widget.document['title'] as String,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(
                ClipboardData(text: widget.document['url'] as String),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied to Clipboard'),
                ),
              );
            },
            tooltip: 'Copy URL',
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: LinkDetailViewBottomNavBar(document: widget.document),
        // child: _bottomNavigationBar(document: widget.document),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    _websitePreview(context),
                    _notes(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _notes(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // this row forces the card to be as big as possible
            Row(),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('links')
                  .doc(widget.document.id)
                  .snapshots(),
              builder: (
                BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot,
              ) {
                final Map<String, dynamic> documentMap =
                    snapshot.data?.data() == null
                        ? {}
                        : snapshot.data!.data()! as Map<String, dynamic>;
                if (snapshot.hasError) {
                  return SizedBox(
                    height: 70,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 70,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                if (documentMap.containsKey('notes')) {
                  return Column(
                    children: [
                      Container(
                        constraints:
                            const BoxConstraints(minWidth: double.infinity),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.grey.withOpacity(0.2),
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            snapshot.data!['notes'] as String,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => NotesDialog(
                              document: widget.document,
                              initalText: documentMap['notes'] as String,
                            ),
                          );
                        },
                        child: const Text('Edit Note'),
                      ),
                    ],
                  );
                } else {
                  return SizedBox(
                    height: 70,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        child: const Text('Add a note'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => NotesDialog(
                              document: widget.document,
                              initalText: '',
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _websitePreview(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                InkWell(
                  onTap: () async {
                    if (await canLaunch(widget.document['url'] as String)) {
                      launch(widget.document['url'] as String);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Could not launch link'),
                          action: SnackBarAction(
                            label: 'Close',
                            onPressed: () {},
                          ),
                        ),
                      );
                    }
                  },
                  child: Column(
                    children: [
                      Text(
                        widget.document['title'] as String,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const Divider(
                        thickness: 2,
                      ),
                      Text(
                        widget.document['url'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: AnyLinkPreview(
              link: widget.document['url'] as String,
              borderRadius: 0,
              boxShadow: const [],
              backgroundColor:
                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? const Color.fromARGB(255, 66, 66, 66)
                      : const Color.fromARGB(255, 243, 243, 243),
              titleStyle: TextStyle(
                color:
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
              ),
              placeholderWidget: Container(
                decoration: BoxDecoration(
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                      ? const Color.fromARGB(255, 66, 66, 66)
                      : const Color.fromARGB(255, 243, 243, 243),
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: Container(
                decoration: BoxDecoration(
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                      ? const Color.fromARGB(255, 66, 66, 66)
                      : const Color.fromARGB(255, 243, 243, 243),
                ),
                child: const Center(child: Text('No Preview Available :(')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
