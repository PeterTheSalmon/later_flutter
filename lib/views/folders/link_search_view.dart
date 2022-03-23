import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/models/link.dart';
import 'package:later_flutter/views/links/link_detail_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../drawer/standard_drawer.dart';

class LinkSearchView extends StatefulWidget {
  const LinkSearchView({Key? key, required this.parentFolderId})
      : super(key: key);

  final String parentFolderId;

  @override
  State<LinkSearchView> createState() => _LinkSearchViewState();
}

class _LinkSearchViewState extends State<LinkSearchView> {
  final TextEditingController _searchController = TextEditingController();

  late Future<bool> _resultsLoaded;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _allResults = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _resultsList = [];

  Future<bool> getLinks() async {
    QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance
        .collection("links")
        .where("userId", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where("parentFolderId", isEqualTo: widget.parentFolderId)
        .orderBy("title")
        .get();
    setState(() {
      _allResults = data.docs;
    });
    searchResultsList();
    return true;
  }

  void searchResultsList() {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> showResults = [];

    if (_searchController.text != "") {
      // we have a search parameter
      for (var linkSnapshot in _allResults) {
        String title =
            Link.fromSnapshot(snapshot: linkSnapshot).title.toLowerCase();
        String url =
            Link.fromSnapshot(snapshot: linkSnapshot).title.toLowerCase();

        if (title.contains(_searchController.text.toLowerCase()) ||
            url.contains(_searchController.text.toLowerCase())) {
          showResults.add(linkSnapshot);
        }
      }
    } else {
      // no search parameter
      showResults = List.from(_allResults);
    }

    setState(() {
      _resultsList = showResults;
    });
  }

  void _onSearchChanged() {
    searchResultsList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resultsLoaded = getLinks();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
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
              title: TextField(
                autofocus: true,
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                ),
              ),
            ),
            body: ListView.builder(
              itemCount: _resultsList.length,
              itemBuilder: (BuildContext context, int index) => Column(
                children: [
                  LinkSearchTile(linkSnapshot: _resultsList[index]),
                  const Divider()
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A slightly toned-down version of the [_linkListTile] widget.
class LinkSearchTile extends StatelessWidget {
  LinkSearchTile({Key? key, required this.linkSnapshot}) : super(key: key);
  DocumentSnapshot<Map<String, dynamic>> linkSnapshot;

  @override
  Widget build(BuildContext context) {
    Link link = Link.fromSnapshot(snapshot: linkSnapshot);
    return OpenContainer(
      tappable: false,
      openElevation: 0,
      closedElevation: 0,
      closedColor: Colors.transparent,
      openColor: Colors.transparent,
      middleColor: Colors.transparent,
      closedBuilder: (BuildContext context, VoidCallback openContainer) =>
          ListTile(
        /// The detail view is disabled on the web
        /// because it doesn't work properly
        /// and serves little purpose.
        onTap: !kIsWeb
            ? () {
                openContainer();
              }
            : () async {
                if (await canLaunch(link.url)) {
                  launch(link.url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Could not launch ${link.url}"),
                    ),
                  );
                }
              },
        title: Text(
          link.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          link.url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      openBuilder: (BuildContext context, VoidCallback _) =>
          LinkDetailView(document: linkSnapshot),
    );
  }
}

// Widget _linkListTile(BuildContext context, DocumentSnapshot<Object?> document) {
//   return OpenContainer(
//     tappable: false,
//     openElevation: 0,
//     closedElevation: 0,
//     closedColor: Colors.transparent,
//     openColor: Colors.transparent,
//     middleColor: Colors.transparent,
//     openBuilder: (BuildContext context, VoidCallback _) =>
//         LinkDetailView(document: document),
//     closedBuilder: (BuildContext context, VoidCallback openContainer) =>
//         Slidable(
//       endActionPane: kIsWeb
//           ? null
//           : ActionPane(
//               motion: const DrawerMotion(),
//               children: [
//                 SlidableAction(
//                     icon: Icons.open_in_new,
//                     label: "Open",
//                     backgroundColor: Colors.blue,
//                     onPressed: (context) async => {
//                           if (await canLaunch(document["url"]!))
//                             {launch(document["url"], enableJavaScript: true)}
//                           else
//                             {
//                               ScaffoldMessenger.of(context)
//                                   .showSnackBar(SnackBar(
//                                 content:
//                                     Text("Could not launch ${document["url"]}"),
//                                 action: SnackBarAction(
//                                   label: "Close",
//                                   onPressed: () {},
//                                 ),
//                               ))
//                             }
//                         }),
//                 SlidableAction(
//                   icon: Icons.share,
//                   label: "Share",
//                   backgroundColor: Colors.orange,
//                   foregroundColor: Colors.white,
//                   onPressed: (context) async => {
//                     if (kIsWeb)
//                       {
//                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                           content: const Text("Share not supported on web"),
//                           action: SnackBarAction(
//                             label: "Close",
//                             onPressed: () {},
//                           ),
//                         ))
//                       }
//                     else
//                       {
//                         await Share.share(document["url"]!,
//                             subject: document["title"]!)
//                       }
//                   },
//                 )
//               ],
//             ),
//       child: ListTile(
//         /// The detail view is disabled on the web
//         /// because it doesn't work properly
//         /// and serves little purpose.
//         onTap: !kIsWeb
//             ? () {
//                 openContainer();
//               }
//             : null,
//         title: Text(
//           document["title"],
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         subtitle: Text(
//           document["url"],
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (kIsWeb || !(Platform.isAndroid || Platform.isIOS))
//               IconButton(
//                   tooltip: "Open in browser",
//                   icon: const Icon(Icons.open_in_new),
//                   onPressed: () async {
//                     if (await canLaunch(document["url"]!)) {
//                       launch(document["url"], enableJavaScript: true);
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                         content: Text("Could not launch ${document["url"]}"),
//                         action: SnackBarAction(
//                           label: "Close",
//                           onPressed: () {},
//                         ),
//                       ));
//                     }
//                   }),
//             IconButton(
//                 tooltip: "Mark as Favourite",
//                 onPressed: () async {
//                   FirebaseFirestore.instance
//                       .collection("links")
//                       .doc(document.id)
//                       .update({"isFavourite": !document["isFavourite"]});
//                 },
//                 icon: const Icon(Icons.star),
//                 color: document["isFavourite"] == true ? Colors.orange : null),
//             IconButton(
//                 tooltip: "Delete",
//                 onPressed: () {
//                   setState(() {
//                     _backupDocument = document;
//                   });
//                   FirebaseFirestore.instance
//                       .collection("links")
//                       .doc(document.id)
//                       .delete();
//                   final deleteSnackBar = SnackBar(
//                       content: const Text("Deleted"),
//                       action: SnackBarAction(
//                           label: "Undo",
//                           onPressed: () {
//                             FirebaseFirestore.instance
//                                 .collection("links")
//                                 .doc(_backupDocument!.id)
//                                 .set({
//                               "dateCreated": _backupDocument!["dateCreated"]!,
//                               "isFavourite": _backupDocument!["isFavourite"]!,
//                               "parentFolderId":
//                                   _backupDocument!["parentFolderId"]!,
//                               "title": _backupDocument!["title"]!,
//                               "url": _backupDocument!["url"]!,
//                               "userId": FirebaseAuth.instance.currentUser!.uid
//                             });
//                           }));
//                   ScaffoldMessenger.of(context).showSnackBar(deleteSnackBar);
//                 },
//                 icon: const Icon(Icons.delete))
//           ],
//         ),
//       ),
//     ),
//   );
// }
