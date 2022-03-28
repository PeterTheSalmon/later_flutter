import 'package:cloud_firestore/cloud_firestore.dart';

class Link {
  Link({
    required this.title,
    required this.url,
    required this.dateCreated,
    required this.isFavourite,
    required this.userId,
    required this.parentFolderId,
    required this.archived,
  });

  /// Create a link from a firebase snapshot
  Link.fromMap({required Map<String, dynamic> map})
      : title = map['title'] as String,
        url = map['url'] as String,
        dateCreated = map['dateCreated'] as Timestamp,
        isFavourite = map['isFavourite'] as bool,
        userId = map['userId'] as String,
        parentFolderId = map['parentFolderId'] as String,
        archived = map['archived'] as bool;

  String title;
  String url;
  Timestamp dateCreated;
  bool isFavourite;
  String userId;
  String parentFolderId;
  bool archived;

  /// Used to convert the link to a json object for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'url': url,
      'dateCreated': dateCreated,
      'isFavourite': isFavourite,
      'userId': userId,
      'parentFolderId': parentFolderId,
    };
  }

  @override
  String toString() {
    return 'Link{title: $title, url: $url, dateCreated: $dateCreated, isFavourite: $isFavourite, userId: $userId, parentFolderId: $parentFolderId}';
  }
}
