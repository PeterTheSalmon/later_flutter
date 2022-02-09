import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ! This is complete unused
class FolderRepository {
  static final folderList = <Folder>{};
  static bool hasFetchedFolders = false;

  static Future<void> get() async {
    FirebaseFirestore.instance
        .collection("folders")
        .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((querySnapshot) {
      for (var change in querySnapshot.docChanges) {
        folderList.add(Folder(change.doc["dateCreated"], change.doc["iconName"],
            change.doc["name"], change.doc["userId"], change.doc.id));
      }
    });
    hasFetchedFolders = true;
    return;
  }
}

class Folder {
  Timestamp dateCreated;
  String iconName;
  String name;
  String userId;
  String id;

  Folder(this.dateCreated, this.iconName, this.name, this.userId, this.id);
}
