import 'dart:io';

import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:later_flutter/models/link.dart';
import 'package:later_flutter/services/global_variables.dart';
import 'package:later_flutter/views/drawer/standard_drawer.dart';
import 'package:later_flutter/views/folders/folder%20view/functions/archive_link.dart';
import 'package:later_flutter/views/links/link%20detail%20view/link_detail_view.dart';
import 'package:later_flutter/views/new%20link%20and%20folder%20flows/new_link_sheet.dart';
import 'package:later_flutter/views/search/link_search_view.dart';
import 'package:later_flutter/views/styles/fade_route.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class FolderView extends StatefulWidget {
  const FolderView({
    Key? key,
    required this.parentFolderId,
    required this.parentFolderName,
  }) : super(key: key);

  final String parentFolderId;
  final String parentFolderName;

  @override
  State<FolderView> createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  late DocumentSnapshot? _backupDocument;
  bool _showFavouritesOnly = false;

  Stream<QuerySnapshot<Object?>>? _favouriteStream() {
    return FirebaseFirestore.instance
        .collection('links')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where('parentFolderId', isEqualTo: widget.parentFolderId)
        .where('isFavourite', isEqualTo: true)
        .where('archived', isEqualTo: false)
        .orderBy('title')
        .snapshots();
  }

  Stream<QuerySnapshot<Object?>>? _stream() {
    return FirebaseFirestore.instance
        .collection('links')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where('parentFolderId', isEqualTo: widget.parentFolderId)
        .where('archived', isEqualTo: false)
        .orderBy('title')
        .snapshots();
  }

  Stream<QuerySnapshot<Object?>>? _archivedStream() {
    return FirebaseFirestore.instance
        .collection('links')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where('parentFolderId', isEqualTo: widget.parentFolderId)
        .where('archived', isEqualTo: true)
        .orderBy('title')
        .snapshots();
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
              title: Text(widget.parentFolderName),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    Navigator.push(
                      context,
                      displayMobileLayout
                          ? MaterialPageRoute(
                              builder: (context) => LinkSearchView(
                                parentFolderId: widget.parentFolderId,
                              ),
                            )
                          : FadeRoute(
                              page: LinkSearchView(
                                parentFolderId: widget.parentFolderId,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
            floatingActionButton: _speedDialButtons(context),
            drawer: displayMobileLayout
                ? const Drawer(child: StandardDrawer())
                : null,
            body: StreamBuilder<QuerySnapshot>(
              stream: _showFavouritesOnly ? _favouriteStream() : _stream(),
              builder: (
                BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot,
              ) {
                if (snapshot.hasError) {
                  return Center(
                    child: SelectableText('Error: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
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
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: snapshot.data!.docs.map(
                              (DocumentSnapshot document) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0,
                                  ),
                                  child: Column(
                                    children: [
                                      _linkListTile(
                                        context,
                                        Link.fromMap(
                                          map: document.data()!
                                              as Map<String, dynamic>,
                                        ),
                                        document,
                                      ),
                                      const Divider(
                                        height: 8,
                                      )
                                    ],
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                          _archivedLinks(),
                          const SizedBox(
                            height: 100,
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  ExpansionTile _archivedLinks() {
    return ExpansionTile(
      onExpansionChanged: (value) {
        if (value) {
          // TODO: code to scroll down a bit
        }
      },
      title: const Text('Archived'),
      children: [
        ListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _archivedStream(),
              builder: (
                BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot,
              ) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: SelectableText(
                        'Error: ${snapshot.error}',
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18.0),
                    child: Center(child: Text('No Links Archived')),
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: snapshot.data!.docs.map(
                    (DocumentSnapshot document) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Column(
                          children: [
                            _linkListTile(
                              context,
                              Link.fromMap(
                                map: document.data()! as Map<String, dynamic>,
                              ),
                              document,
                              isArchiveTile: true,
                            ),
                            const Divider(
                              height: 8,
                            )
                          ],
                        ),
                      );
                    },
                  ).toList(),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _linkListTile(
    BuildContext context,
    Link link,
    DocumentSnapshot document, {
    bool isArchiveTile = false,
  }) {
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
        key: UniqueKey(),
        endActionPane: kIsWeb
            ? null
            : ActionPane(
                dismissible: DismissiblePane(
                  onDismissed: () {
                    // If the link is already archived, restore it
                    archiveLink(
                      isArchiveTile: isArchiveTile,
                      linkDocument: document,
                      context: context,
                    );
                  },
                ),
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    icon: Icons.archive,
                    label: isArchiveTile ? 'Restore' : 'Archive',
                    backgroundColor: isArchiveTile ? Colors.green : Colors.grey,
                    onPressed: (_) {
                      archiveLink(
                        isArchiveTile: isArchiveTile,
                        linkDocument: document,
                        context: context,
                      );
                    },
                  ),
                ],
              ),
        startActionPane: kIsWeb
            ? null
            : isArchiveTile
                ? null
                : ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        icon: Icons.open_in_new,
                        label: 'Open',
                        backgroundColor: Colors.blue,
                        onPressed: (context) async => {
                          if (await canLaunch(link.url))
                            {launch(link.url, enableJavaScript: true)}
                          else
                            {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Could not launch ${link.url}'),
                                  action: SnackBarAction(
                                    label: 'Close',
                                    onPressed: () {},
                                  ),
                                ),
                              )
                            }
                        },
                      ),
                      SlidableAction(
                        icon: Icons.share,
                        label: 'Share',
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        onPressed: (context) async => {
                          if (kIsWeb)
                            {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      const Text('Share not supported on web'),
                                  action: SnackBarAction(
                                    label: 'Close',
                                    onPressed: () {},
                                  ),
                                ),
                              )
                            }
                          else
                            {await Share.share(link.url, subject: link.title)}
                        },
                      ),
                    ],
                  ),
        child: ListTile(
          //The detail view is disabled on the web
          // because it doesn't work properly
          // and serves little purpose.
          onTap: !kIsWeb
              ? () {
                  openContainer();
                }
              : () async {
                  if (await canLaunch(document['url'] as String)) {
                    launch(document['url'] as String);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Could not launch ${document["url"]}"),
                      ),
                    );
                  }
                },
          title: Text(
            document['title'] as String,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            document['url'] as String,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (kIsWeb)
                IconButton(
                  icon: Icon(isArchiveTile ? Icons.restore : Icons.archive),
                  tooltip: isArchiveTile ? 'Restore' : 'Archive',
                  onPressed: () {
                    archiveLink(
                      isArchiveTile: isArchiveTile,
                      linkDocument: document,
                      context: context,
                    );
                  },
                ),
              if (kIsWeb || !(Platform.isAndroid || Platform.isIOS))
                IconButton(
                  tooltip: 'Open in browser',
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () async {
                    if (await canLaunch(document['url'] as String)) {
                      launch(document['url'] as String, enableJavaScript: true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Could not launch ${document["url"]}"),
                          action: SnackBarAction(
                            label: 'Close',
                            onPressed: () {},
                          ),
                        ),
                      );
                    }
                  },
                ),
              if (!isArchiveTile)
                IconButton(
                  tooltip: 'Mark as Favourite',
                  onPressed: () async {
                    FirebaseFirestore.instance
                        .collection('links')
                        .doc(document.id)
                        .update(
                      {'isFavourite': !(document['isFavourite'] as bool)},
                    );
                  },
                  icon: const Icon(Icons.star),
                  color: document['isFavourite'] == true ? Colors.orange : null,
                ),
              IconButton(
                tooltip: 'Delete',
                onPressed: () {
                  setState(() {
                    _backupDocument = document;
                  });
                  FirebaseFirestore.instance
                      .collection('links')
                      .doc(document.id)
                      .delete();
                  final deleteSnackBar = SnackBar(
                    content: const Text('Deleted'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('links')
                            .doc(_backupDocument!.id)
                            .set({
                          'dateCreated': _backupDocument!['dateCreated']!,
                          'isFavourite': _backupDocument!['isFavourite']!,
                          'parentFolderId': _backupDocument!['parentFolderId']!,
                          'title': _backupDocument!['title']!,
                          'url': _backupDocument!['url']!,
                          'userId': FirebaseAuth.instance.currentUser!.uid
                        });
                      },
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(deleteSnackBar);
                },
                icon: const Icon(Icons.delete),
              )
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
        const Text('Show Favourites Only'),
        Switch(
          value: _showFavouritesOnly,
          onChanged: (change) {
            setState(() {
              _showFavouritesOnly = change;
            });
          },
        ),
        const Spacer()
      ],
    );
  }

  Widget _emptyDataView(BuildContext context) {
    return ListView(
      children: [
        Row(
          children: [
            const Spacer(),
            const Text('Show Favourites Only'),
            Switch(
              value: _showFavouritesOnly,
              onChanged: (change) {
                setState(() {
                  _showFavouritesOnly = change;
                });
              },
            ),
            const Spacer()
          ],
        ),
        const SizedBox(
          height: 150,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: _showFavouritesOnly
                ? Text(
                    "You don't have any favourites!",
                    style: TextStyle(
                      fontSize: 20,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  )
                : RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Click the ',
                          style: TextStyle(
                            fontSize: 20,
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        const WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(left: 2, right: 2),
                            child: Icon(
                              Icons.menu,
                              size: 20,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: ' to add a link',
                          style: TextStyle(
                            fontSize: 20,
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(
          height: 150,
        ),
        _archivedLinks(),
      ],
    );
  }

  SpeedDial _speedDialButtons(BuildContext context) {
    return SpeedDial(
      backgroundColor: Globals.appColour,
      animatedIcon: AnimatedIcons.menu_close,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.copy),
          label: 'Add from Clipboard',
          onTap: () => showNewLinkSheet(
            context,
            parentFolderId: widget.parentFolderId,
            fromClipboard: true,
          ),
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
