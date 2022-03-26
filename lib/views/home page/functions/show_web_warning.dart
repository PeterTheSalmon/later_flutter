import 'package:flutter/material.dart';

Future<dynamic> showWebWarning(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Some features aren't available on the web.",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            const Text(
              'The following are unavailable:',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('- Receiving shared links'),
                Text('- Links previews and notes'),
                Text('- Link sharing'),
                Text('- Editing links'),
              ],
            ),
            const SizedBox(height: 10),
            const SizedBox(
              width: 250,
              child: Text(
                'Please use the native versions of Later for these features.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            )
          ],
        ),
      ),
    ),
  );
}
