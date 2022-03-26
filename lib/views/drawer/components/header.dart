import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StandardDrawerHeader extends StatelessWidget {
  const StandardDrawerHeader({
    Key? key,
    required this.headerImageDark,
    required this.headerImageLight,
  }) : super(key: key);

  final Image headerImageDark;
  final Image headerImageLight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 310,
      height: 170,
      child: DrawerHeader(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: MediaQuery.of(context).platformBrightness == Brightness.dark
                ? headerImageDark.image
                : headerImageLight.image,
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            const Text(
              'Later',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
            Text(
              FirebaseAuth.instance.currentUser!.displayName ??
                  'Set a display name in Account Settings',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
