import 'package:capstone/widgets/tappable.dart';
import 'package:capstone/widgets/textWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Home'),
            trailing: Icon(CupertinoIcons.add_circled),
          ),
          SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                CupertinoButton.filled(
                  onPressed: () {
                    Navigator.push(context, CupertinoPageRoute<Widget>(
                        builder: (BuildContext context) {
                      return NextPage();
                    }));
                  },
                  child: const Text('Go to Next Page'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = CupertinoTheme.brightnessOf(context);
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            largeTitle: const Text('User'),
          ),
          SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Tappable(
                  onTap: () {
                    print("object");
                  },
                  color: Colors.blue,
                  child: Container(
                    width: 100,
                    height: 100,
                    child: TextFont(text: "Hello"),
                  ),
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: CupertinoButton.filled(
                    onPressed: () => {},
                    child: const Icon(CupertinoIcons.add),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
