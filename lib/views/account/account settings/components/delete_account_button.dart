import 'package:flutter/material.dart';
import 'package:later_flutter/views/account/delete_account_view.dart';

class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      child: const Text("Delete Account"),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return const DeleteAccountView();
            });
      },
    );
  }
}
