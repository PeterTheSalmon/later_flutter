import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/models/folder.dart';
import 'package:later_flutter/views/drawer/standard_drawer.dart';
import 'package:later_flutter/views/folders/folder_list_tile.dart';

class FolderSearch extends StatefulWidget {
  const FolderSearch({Key? key}) : super(key: key);

  @override
  State<FolderSearch> createState() => _FolderSearchState();
}

class _FolderSearchState extends State<FolderSearch> {
  final TextEditingController _searchController = TextEditingController();

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _allResults = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _resultsList = [];

  late Future<bool> resultsLoaded;

  Future<bool> getLinks() async {
    QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance
        .collection("folders")
        .where("userId", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .orderBy("name")
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
      for (var folderSnapshot in _allResults) {
        String name = Folder.fromSnapshot(folderSnapshot).name.toLowerCase();

        if (name.contains(_searchController.text.toLowerCase())) {
          showResults.add(folderSnapshot);
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
                  hintText: 'Search folders',
                  border: InputBorder.none,
                ),
              ),
            ),
            body: ListView.builder(
              itemCount: _resultsList.length,
              itemBuilder: (BuildContext context, int index) => Column(
                children: [
                  FolderListTile(
                    document: _resultsList[index],
                    showEditDelete: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
