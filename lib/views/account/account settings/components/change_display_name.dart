import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DisplayNameButton extends StatelessWidget {
  const DisplayNameButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.person),
      title: const Text("Change Display Name"),
      onTap: () {
        final TextEditingController nameController = TextEditingController();
        showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                  child: Container(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Change Display Name",
                          style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: "New Display Name",
                        ),
                        controller: nameController,
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton(
                        onPressed: () {
                          if (FirebaseAuth.instance.currentUser == null) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Error: no user found!")));
                            return;
                          }
                          FirebaseAuth.instance.currentUser
                              ?.updateDisplayName(nameController.text);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Display Name Changed!")));
                        },
                        child: const Text("Change"),
                      ),
                    ],
                  ),
                ),
              ));
            });
      },
    );
  }
}
