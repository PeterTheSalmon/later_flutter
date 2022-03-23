import 'package:cloud_firestore/cloud_firestore.dart';

class Link {
  String title;
  String url;
  Timestamp dateCreated;
  bool isFavourite;
  String userId;
  String parentFolderId;

  Link({
    required this.title,
    required this.url,
    required this.dateCreated,
    required this.isFavourite,
    required this.userId,
    required this.parentFolderId,
  });

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
  Link.fromSnapshot({required DocumentSnapshot snapshot})
      : title = snapshot["title"],
        url = snapshot["url"],
        dateCreated = snapshot["dateCreated"],
        isFavourite = snapshot["isFavourite"],
        userId = snapshot["userId"],
        parentFolderId = snapshot["parentFolderId"];

  @override
  String toString() {
    return 'Link{title: $title, url: $url, dateCreated: $dateCreated, isFavourite: $isFavourite, userId: $userId, parentFolderId: $parentFolderId}';
  }
}
