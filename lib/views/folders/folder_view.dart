import 'dart:io';

import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:later_flutter/services/global_variables.dart';
import 'package:later_flutter/views/links/link_detail_view.dart';
import 'package:later_flutter/views/links/new_link_sheet.dart';
import 'package:later_flutter/views/components/standard_drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class FolderView extends StatefulWidget {
  const FolderView(
      {Key? key, required this.parentFolderId, required this.parentFolderName})
      : super(key: key);

  final String parentFolderId;
  final String parentFolderName;

  @override
  State<FolderView> createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  DocumentSnapshot? _backupDocument;
  bool _showFavouritesOnly = false;

  Stream<QuerySnapshot<Object?>>? _favouriteStream() {
    return FirebaseFirestore.instance
        .collection("links")
        .where("userId", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where("parentFolderId", isEqualTo: widget.parentFolderId)
        .where("isFavourite", isEqualTo: true)
        .orderBy("title")
        .snapshots();
  }

  Stream<QuerySnapshot<Object?>>? _stream() {
    return FirebaseFirestore.instance
        .collection("links")
        .where("userId", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where("parentFolderId", isEqualTo: widget.parentFolderId)
        .orderBy("title")
        .snapshots();
  }

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
              title: Text(widget.parentFolderName),
            ),
            floatingActionButton: _speedDialButtons(context),
            drawer: displayMobileLayout
                ? const Drawer(child: StandardDrawer())
                : null,
            body: StreamBuilder<QuerySnapshot>(
                stream: _showFavouritesOnly ? _favouriteStream() : _stream(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: SelectableText("Error: ${snapshot.error}"),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return _emptyDataView(context);
                  }
                  return Column(
                    children: [
                      _favouritesToggle(),
                      const Divider(),
                      Expanded(
                        child: ListView(
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            return Column(
                              children: [
                                _linkListTile(context, document),
                                const Divider()
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                }),
          ),
        ),
      ],
    );
  }

  Widget _linkListTile(
      BuildContext context, DocumentSnapshot<Object?> document) {
    return OpenContainer(
      tappable: false,
      openElevation: 0,
      closedElevation: 0,
      closedColor: Colors.transparent,
      openColor: Colors.transparent,
      middleColor: Colors.transparent,
      openBuilder: (BuildContext context, VoidCallback _) =>
          LinkDetailView(document: document),
      closedBuilder: (BuildContext context, VoidCallback openContainer) =>
          Slidable(
        endActionPane: kIsWeb
            ? null
            : ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                      icon: Icons.open_in_new,
                      label: "Open",
                      backgroundColor: Colors.blue,
                      onPressed: (context) async => {
                            if (await canLaunch(document["url"]!))
                              {launch(document["url"], enableJavaScript: true)}
                            else
                              {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      "Could not launch ${document["url"]}"),
                                  action: SnackBarAction(
                                    label: "Close",
                                    onPressed: () {},
                                  ),
                                ))
                              }
                          }),
                  SlidableAction(
                    icon: Icons.share,
                    label: "Share",
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    onPressed: (context) async => {
                      if (kIsWeb)
                        {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text("Share not supported on web"),
                            action: SnackBarAction(
                              label: "Close",
                              onPressed: () {},
                            ),
                          ))
                        }
                      else
                        {
                          await Share.share(document["url"]!,
                              subject: document["title"]!)
                        }
                    },
                  )
                ],
              ),
        child: ListTile(
          /// The detail view is disabled on the web
          /// because it doesn't work properly
          /// and serves little purpose.
          onTap: !kIsWeb
              ? () {
                  openContainer();
                }
              : null,
          title: Text(
            document["title"],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            document["url"],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (kIsWeb || !(Platform.isAndroid || Platform.isIOS))
                IconButton(
                    tooltip: "Open in browser",
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () async {
                      if (await canLaunch(document["url"]!)) {
                        launch(document["url"], enableJavaScript: true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Could not launch ${document["url"]}"),
                          action: SnackBarAction(
                            label: "Close",
                            onPressed: () {},
                          ),
                        ));
                      }
                    }),
              IconButton(
                  tooltip: "Mark as Favourite",
                  onPressed: () async {
                    FirebaseFirestore.instance
                        .collection("links")
                        .doc(document.id)
                        .update({"isFavourite": !document["isFavourite"]});
                  },
                  icon: const Icon(Icons.star),
                  color:
                      document["isFavourite"] == true ? Colors.orange : null),
              IconButton(
                  tooltip: "Delete",
                  onPressed: () {
                    setState(() {
                      _backupDocument = document;
                    });
                    FirebaseFirestore.instance
                        .collection("links")
                        .doc(document.id)
                        .delete();
                    final deleteSnackBar = SnackBar(
                        content: const Text("Deleted"),
                        action: SnackBarAction(
                            label: "Undo",
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection("links")
                                  .doc(_backupDocument!.id)
                                  .set({
                                "dateCreated": _backupDocument!["dateCreated"]!,
                                "isFavourite": _backupDocument!["isFavourite"]!,
                                "parentFolderId":
                                    _backupDocument!["parentFolderId"]!,
                                "title": _backupDocument!["title"]!,
                                "url": _backupDocument!["url"]!,
                                "userId": FirebaseAuth.instance.currentUser!.uid
                              });
                            }));
                    ScaffoldMessenger.of(context).showSnackBar(deleteSnackBar);
                  },
                  icon: const Icon(Icons.delete))
            ],
          ),
        ),
      ),
    );
  }

  Row _favouritesToggle() {
    return Row(
      children: [
        const Spacer(),
        const Text("Show Favourites Only"),
        Switch(
            value: _showFavouritesOnly,
            onChanged: (change) {
              setState(() {
                _showFavouritesOnly = change;
              });
            }),
        const Spacer()
      ],
    );
  }

  Column _emptyDataView(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            const Text("Show Favourites Only"),
            Switch(
                value: _showFavouritesOnly,
                onChanged: (change) {
                  setState(() {
                    _showFavouritesOnly = change;
                  });
                }),
            const Spacer()
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
                child: _showFavouritesOnly
                    ? Text("You don't have any favourites!",
                        style: TextStyle(
                            fontSize: 20,
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black))
                    : RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: 'Click the ',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black)),
                            const WidgetSpan(
                              child: Padding(
                                padding: EdgeInsets.only(left: 2, right: 2),
                                child: Icon(Icons.menu),
                              ),
                            ),
                            TextSpan(
                                text: ' to add a link',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black)),
                          ],
                        ),
                      )),
          ),
        ),
      ],
    );
  }

  SpeedDial _speedDialButtons(BuildContext context) {
    return SpeedDial(
      backgroundColor: Globals.appColour,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      animatedIcon: AnimatedIcons.menu_close,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.copy),
          label: 'Add from Clipboard',
          onTap: () => showNewLinkSheet(context,
              parentFolderId: widget.parentFolderId, fromClipboard: true),
        ),
        SpeedDialChild(
          child: const Icon(Icons.add_link),
          label: 'Save Link',
          onTap: () =>
              showNewLinkSheet(context, parentFolderId: widget.parentFolderId),
        ),
      ],
    );
  }
}
