import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LinkSearchView extends StatefulWidget {
  LinkSearchView({Key? key, required this.parentFolderId}) : super(key: key);

  String parentFolderId;

  @override
  State<LinkSearchView> createState() => _LinkSearchViewState();
}

class _LinkSearchViewState extends State<LinkSearchView> {
  final TextEditingController _searchController = TextEditingController();

  late Future<bool> _resultsLoaded;
  List _allResults = [];
  List _resultsList = [];

  void searchResultsList() {
    setState(() {
      _resultsList = _allResults;
    });
  }

  Future<bool> getLinks() async {
    QuerySnapshot data = await FirebaseFirestore.instance
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

  void _onSearchChanged() {
    print(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
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
    );
  }
}
