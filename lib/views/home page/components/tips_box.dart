import 'dart:math';

import 'package:flutter/material.dart';
import 'package:later_flutter/services/global_variables.dart';

class TipsBox extends StatefulWidget {
  const TipsBox({Key? key}) : super(key: key);

  @override
  State<TipsBox> createState() => _TipsBoxState();
}

class _TipsBoxState extends State<TipsBox> {
  int _tipIndex = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      _tipIndex = Random().nextInt(Globals.tips.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        key: ValueKey<int>(_tipIndex),
        padding: const EdgeInsets.only(top: 20.0),
        child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: IconButton(
                    icon: const Icon(Icons.lightbulb),
                    onPressed: () {},
                  ),
                  title: Text(Globals.tips[_tipIndex].title),
                ),
                const Divider(
                  thickness: 2,
                ),
                SizedBox(
                  height: 55,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Center(
                      child: Text(
                        Globals.tips[_tipIndex].content,
                        key: ValueKey<int>(_tipIndex),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                ButtonBar(
                  children: [
                    if (Globals.tips[_tipIndex].buttonAction != null)
                      TextButton(
                        child: Text(Globals.tips[_tipIndex].buttonTitle!),
                        onPressed: () {
                          Globals.tips[_tipIndex].buttonAction!();
                        },
                      ),
                    TextButton(
                      child: const Text("Next Tip"),
                      onPressed: () {
                        int previousIndex = _tipIndex;
                        while (previousIndex == _tipIndex) {
                          setState(() {
                            _tipIndex = Random().nextInt(Globals.tips.length);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
