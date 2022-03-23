import 'package:flutter/material.dart';

void showAddedLinkSnackbar(BuildContext context) {
  final nav = Navigator.maybeOf(context);
  final sm = ScaffoldMessenger.maybeOf(context);

  print(context is StatefulElement ? context.state : "Not stateful");

  if (nav == null || sm == null) {
    print('Navigator or ScaffoldMessenger is null');

    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text("Added link!"),
      action: SnackBarAction(
          label: "Go to new view",
          onPressed: () {
            if (!nav.mounted) {
              return;
            }
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Scaffold(
                    body: Center(
                      child: Text("New view"),
                    ),
                  ),
                ));
          }),
    ),
  );
}
