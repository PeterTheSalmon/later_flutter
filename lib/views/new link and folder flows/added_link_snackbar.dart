import 'package:flutter/material.dart';

void showAddedLinkSnackbar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Added!"),
    ),
  );
}
