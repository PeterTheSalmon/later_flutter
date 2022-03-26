// folder class

import 'package:cloud_firestore/cloud_firestore.dart';

class Folder {
  Folder({
    required this.name,
    required this.userId,
    required this.dateCreated,
    required this.iconName,
  });

  Folder.fromSnapshot(DocumentSnapshot snapshot)
      : name = snapshot['name'] as String,
        userId = snapshot['userId'] as String,
        dateCreated = snapshot['dateCreated'] as Timestamp,
        iconName = snapshot['iconName'] as String;

  String name;
  String userId;
  Timestamp dateCreated;
  String iconName;

  /// Used to convert the folder to a json object for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userId': userId,
      'dateCreated': dateCreated,
      'iconName': iconName,
    };
  }

  /// Create a folder from a firebase snapshot

  @override
  String toString() {
    return 'Folder{name: $name, userId: $userId, dateCreated: $dateCreated, iconName: $iconName}';
  }
}
