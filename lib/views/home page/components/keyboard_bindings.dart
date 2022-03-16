import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:later_flutter/views/new%20link%20and%20folder%20flows/new_folder_sheet.dart';
import 'package:later_flutter/views/new%20link%20and%20folder%20flows/new_link_sheet.dart';

Map<ShortcutActivator, VoidCallback> homeBindings(BuildContext context) {
  return {
    SingleActivator(LogicalKeyboardKey.keyN,
        meta: Platform.isMacOS ? true : false,
        control: Platform.isMacOS ? false : true,
        alt: true): () {
      showNewLinkSheet(context,
          parentFolderId: "", fromClipboard: true, useDialog: true);
    },
    SingleActivator(
      LogicalKeyboardKey.keyN,
      meta: Platform.isMacOS ? true : false,
      control: Platform.isMacOS ? false : true,
    ): () {
      showNewLinkSheet(context, parentFolderId: "", useDialog: true);
    },
    SingleActivator(LogicalKeyboardKey.keyN,
        meta: Platform.isMacOS ? true : false,
        control: Platform.isMacOS ? false : true,
        shift: true): () {
      showNewFolderSheet(context, useDialog: true);
    },
  };
}
