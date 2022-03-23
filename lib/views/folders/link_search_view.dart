import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/models/link.dart';

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
                  ListTile(
                    title: Text(
                      _resultsList[index]["title"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      _resultsList[index]["url"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
