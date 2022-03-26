// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/services/folder_icon_getter.dart';

List<String> symbolNames = [
  'folder',
  'display',
  'music.note',
  'star',
  'link',
  'cloud',
  'externaldrive',
  'wrench.and.screwdriver',
];

class FolderIconChooser extends StatelessWidget {
  FolderIconChooser({Key? key, required this.folder}) : super(key: key);

  DocumentSnapshot folder;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Choose an Icon',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 200),
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 0.1,
              crossAxisSpacing: 0.1,
              shrinkWrap: true,
              children: symbolNames.map((symbolName) {
                return SizedBox(
                  height: 30,
                  width: 30,
                  child: IconButton(
                    tooltip: symbolName.toLowerCase(),
                    icon: getFolderIcon(symbolName),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('folders')
                          .doc(folder.id)
                          .update({'iconName': symbolName});
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
