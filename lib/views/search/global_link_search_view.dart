import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/models/link.dart';
import 'package:later_flutter/views/drawer/standard_drawer.dart';
import 'package:later_flutter/views/links/link_detail_view.dart';
import 'package:url_launcher/url_launcher.dart';

class GlobalLinkSearchView extends StatefulWidget {
  const GlobalLinkSearchView({Key? key}) : super(key: key);

  @override
  State<GlobalLinkSearchView> createState() => _GlobalLinkSearchViewState();
}

class _GlobalLinkSearchViewState extends State<GlobalLinkSearchView> {
  final TextEditingController _searchController = TextEditingController();

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _allResults = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _resultsList = [];

  late Future<bool> resultsLoaded;

  Future<bool> getLinks() async {
    final QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore
        .instance
        .collection('links')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .orderBy('title')
        .get();
    setState(() {
      _allResults = data.docs;
    });
    searchResultsList();
    return true;
  }

  void searchResultsList() {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> showResults = [];

    if (_searchController.text != '') {
      // we have a search parameter
      for (final linkSnapshot in _allResults) {
        final String title =
            Link.fromMap(map: linkSnapshot.data()).title.toLowerCase();
        final String url =
            Link.fromMap(map: linkSnapshot.data()).url.toLowerCase();

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
    // ! For some reason, this line of code makes search work
    // I have no idea why. All that's happening is changing a bool
    resultsLoaded = getLinks();
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
                  hintText: 'Search everywhere',
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

class LinkSearchTile extends StatelessWidget {
  const LinkSearchTile({Key? key, required this.linkSnapshot})
      : super(key: key);
  final DocumentSnapshot<Map<String, dynamic>> linkSnapshot;

  @override
  Widget build(BuildContext context) {
    final Link link = Link.fromMap(map: linkSnapshot.data()!);
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
                      content: Text('Could not launch ${link.url}'),
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
