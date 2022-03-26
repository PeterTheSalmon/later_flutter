import 'package:cloud_firestore/cloud_firestore.dart';

class Link {
  String title;
  String url;
  Timestamp dateCreated;
  bool isFavourite;
  String userId;
  String parentFolderId;
  bool? archived;

  Link(
      {required this.title,
      required this.url,
      required this.dateCreated,
      required this.isFavourite,
      required this.userId,
      required this.parentFolderId,
      this.archived});

  /// Used to convert the link to a json object for Firestore
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "url": url,
      "dateCreated": dateCreated,
      "isFavourite": isFavourite,
      "userId": userId,
      "parentFolderId": parentFolderId,
    };
  }

  /// Create a link from a firebase snapshot
  Link.fromMap({required Map<String, dynamic> map})
      : title = map["title"],
        url = map["url"],
        dateCreated = map["dateCreated"],
        isFavourite = map["isFavourite"],
        userId = map["userId"],
        parentFolderId = map["parentFolderId"],
        archived = map["archived"];

  @override
  String toString() {
    return 'Link{title: $title, url: $url, dateCreated: $dateCreated, isFavourite: $isFavourite, userId: $userId, parentFolderId: $parentFolderId}';
  }
}
