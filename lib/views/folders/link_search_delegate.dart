import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LinkSearchDelegate extends SearchDelegate {
  String parentFolderId;

  LinkSearchDelegate({required this.parentFolderId});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return SearchStreamBuilder(
      query: query,
      parentFolderId: parentFolderId,
    );

    // TODO: implement buildResults
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return SearchStreamBuilder(
      query: query,
      parentFolderId: parentFolderId,
    );
  }
}

class SearchStreamBuilder extends StatefulWidget {
  const SearchStreamBuilder(
      {Key? key, required this.query, required this.parentFolderId})
      : super(key: key);

  final String query;
  final String parentFolderId;

  @override
  State<SearchStreamBuilder> createState() => _SearchStreamBuilderState();
}

class _SearchStreamBuilderState extends State<SearchStreamBuilder> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resultsLoaded = getLinks();
  }


  @override
  void initState() {
    super.initState();
    
  }

  late Future<bool> _resultsLoaded;
  List _allResults = [];
  List _resultsList = [];

  void onSearchChanged() {
    searchResultsList();
  }

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
  Widget build(BuildContext context) {
    return ListView.builder(
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
    );
    // return StreamBuilder(
    //     stream: widget.query != ""
    //         ?
    //         : FirebaseFirestore.instance
    //             .collection("links")
    //             .where("userId",
    //                 isEqualTo: FirebaseAuth.instance.currentUser?.uid)
    //             .where("parentFolderId", isEqualTo: widget.parentFolderId)
    //             .orderBy("title")
    //             .limit(10)
    //             .snapshots(),
    //     builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    //       if (snapshot.connectionState == ConnectionState.waiting &&
    //           !snapshot.hasData) {
    //         return const Center(child: CircularProgressIndicator());
    //       }
    //       if (snapshot.hasError) {
    //         return Center(
    //           child: SelectableText("Error: ${snapshot.error}"),
    //         );
    //       }

    //       if (snapshot.data!.docs.isEmpty) {
    //         return const Text("No results found");
    //       }
    //       return Column(
    //         children: [
    //           const Divider(),
    //           Expanded(
    //             child: ListView(
    //               children:
    //                   snapshot.data!.docs.map((DocumentSnapshot document) {
    //                 return Column(
    //                   children: [
    //                     ListTile(
    //                       title: Text(document["title"]),
    //                       subtitle: Text(document["url"]),
    //                     ),
    //                     const Divider()
    //                   ],
    //                 );
    //               }).toList(),
    //             ),
    //           ),
    //         ],
    //       );
    //     });
  }
}
