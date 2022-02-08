import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FolderRepository {
  static List<Folder> folderList = [];

  static get() async {
    FirebaseFirestore.instance
        .collection("folders")
        .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((querySnapshot) {
      querySnapshot.docs.map((DocumentSnapshot document) {
        folderList.add(Folder(document["dateCreated"], document["iconName"],
            document["name"], document["userId"], document.id));
      });
    });
  }
}

class Folder {
  DateTime dateCreated;
  String iconName;
  String name;
  String userId;
  String id;

  Folder(this.dateCreated, this.iconName, this.name, this.userId, this.id);
}
