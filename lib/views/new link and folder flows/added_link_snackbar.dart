import 'package:flutter/material.dart';

void showAddedLinkSnackbar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text("Added!"),
      action: SnackBarAction(
        label: "Close",
        onPressed: () {},
      ),
    ),
  );
}
