import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/views/account/delete_account_view.dart';
import 'package:later_flutter/views/styles/fade_through_route.dart';

class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.no_accounts),
      title: const Text("Delete Account"),
      onTap: () {
        Navigator.push(
            context,
            fadeThrough((context, animation, secondaryAnimation) =>
                const DeleteAccountView()));
        // showDialog(
        //     context: context,
        //     builder: (context) {
        //       return const DeleteAccountView();
        //     });
      },
    );
  }
}
