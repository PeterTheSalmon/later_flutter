// folder class

import 'package:cloud_firestore/cloud_firestore.dart';

class Folder {
  String name;
  String userId;
  Timestamp dateCreated;
  String iconName;

  Folder({
    required this.name,
    required this.userId,
    required this.dateCreated,
    required this.iconName,
  });

  /// Used to convert the folder to a json object for Firestore
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "userId": userId,
      "dateCreated": dateCreated,
      "iconName": iconName,
    };
  }

  /// Create a folder from a firebase snapshot
  Folder.fromSnapshot(DocumentSnapshot snapshot)
      : name = snapshot["name"],
        userId = snapshot["userId"],
        dateCreated = snapshot["dateCreated"],
        iconName = snapshot["iconName"];

  @override
  String toString() {
    return 'Folder{name: $name, userId: $userId, dateCreated: $dateCreated, iconName: $iconName}';
  }
}
