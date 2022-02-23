import 'package:flutter/material.dart';

var symbolNames = [
  "folder",
  "display",
  "music.note",
  "star",
  "link",
  "cloud",
  "externaldrive",
  "wrench.and.screwdriver",
];

/// Gotta say, I LOVE Copilot for situations like these: it just autofilled
/// literally everything. Pure magic.
Icon getFolderIcon(String iconName) {
  switch (iconName) {
    case 'folder':
      return const Icon(Icons.folder);
    case 'display':
      return const Icon(Icons.desktop_mac);
    case 'music.note':
      return const Icon(Icons.music_note);
    case 'star':
      return const Icon(Icons.star);
    case 'link':
      return const Icon(Icons.link);
    case 'cloud':
      return const Icon(Icons.cloud);
    case 'externaldrive':
      return const Icon(Icons.sd_storage);
    case 'wrench.and.screwdriver':
      return const Icon(Icons.build);
    default:
      return const Icon(Icons.folder);
  }
}
