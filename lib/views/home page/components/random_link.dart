import 'package:any_link_preview/any_link_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RandomLink extends StatelessWidget {
  const RandomLink({
    Key? key,
    required this.randomLink,
    required this.context,
  }) : super(key: key);

  final DocumentSnapshot<Object?>? randomLink;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: randomLink == null
          ? const SizedBox(
              height: kIsWeb ? 72 : 252,
              child: Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              height: kIsWeb ? 72 : 252,
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      onTap: _launchURL,
                      leading: SizedBox(
                        height: 48,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Open in browser',
                          icon: const Icon(Icons.open_in_new),
                          onPressed: _launchURL,
                        ),
                      ),
                      title: Text(
                        randomLink!['title'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        randomLink!['url'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!kIsWeb)
                      SizedBox(
                        height: 180,
                        child: AnyLinkPreview(
                          link: randomLink!['url'] as String,
                          borderRadius: 0,
                          boxShadow: const [],
                          backgroundColor:
                              MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark
                                  ? const Color.fromARGB(255, 66, 66, 66)
                                  : const Color.fromARGB(255, 243, 243, 243),
                          titleStyle: TextStyle(
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                          placeholderWidget: Container(
                            decoration: BoxDecoration(
                              color: MediaQuery.of(context)
                                          .platformBrightness ==
                                      Brightness.dark
                                  ? const Color.fromARGB(255, 66, 66, 66)
                                  : const Color.fromARGB(255, 243, 243, 243),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: Container(
                            decoration: BoxDecoration(
                              color: MediaQuery.of(context)
                                          .platformBrightness ==
                                      Brightness.dark
                                  ? const Color.fromARGB(255, 66, 66, 66)
                                  : const Color.fromARGB(255, 243, 243, 243),
                            ),
                            child: const Center(
                              child: Text('No Preview Available :('),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
    return AnimatedOpacity(
      opacity: randomLink == null ? 0 : 1,
      duration: const Duration(milliseconds: 3000),
      child: randomLink == null
          ? const CircularProgressIndicator()
          : Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    onTap: _launchURL,
                    leading: SizedBox(
                      height: 48,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Open in browser',
                        icon: const Icon(Icons.open_in_new),
                        onPressed: _launchURL,
                      ),
                    ),
                    title: Text(
                      randomLink!['title'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      randomLink!['url'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!kIsWeb)
                    SizedBox(
                      height: 180,
                      child: AnyLinkPreview(
                        link: randomLink!['url'] as String,
                        borderRadius: 0,
                        boxShadow: const [],
                        backgroundColor:
                            MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? const Color.fromARGB(255, 66, 66, 66)
                                : const Color.fromARGB(255, 243, 243, 243),
                        titleStyle: TextStyle(
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                        placeholderWidget: Container(
                          decoration: BoxDecoration(
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? const Color.fromARGB(255, 66, 66, 66)
                                : const Color.fromARGB(255, 243, 243, 243),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: Container(
                          decoration: BoxDecoration(
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? const Color.fromARGB(255, 66, 66, 66)
                                : const Color.fromARGB(255, 243, 243, 243),
                          ),
                          child: const Center(
                            child: Text('No Preview Available :('),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  void _launchURL() async {
    if (await canLaunch(randomLink!['url'] as String)) {
      launch(
        randomLink!['url'] as String,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Could not launch ${randomLink!["url"]}"),
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {},
          ),
        ),
      );
    }
  }
}
