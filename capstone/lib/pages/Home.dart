import 'package:capstone/database/tables.dart';
import 'package:capstone/struct/databaseGlobal.dart';
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
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Home'),
            trailing: CupertinoButton(
              child: Container(color: Colors.blue, width: 40, height: 40),
              onPressed: () => {
                database.createOrUpdateUser(
                  User(
                    id: DateTime.now().millisecondsSinceEpoch,
                    name: "Userrrrr",
                    description: "description",
                  ),
                )
              },
            ),
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
          StreamBuilder<List<User>>(
            stream: database.watchUsers(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SliverPadding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 13),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TextFont(
                            textColor: Colors.white,
                            text: snapshot.data![index].name,
                          ),
                        );
                      },
                      childCount: snapshot.data?.length, //snapshot.data?.length
                    ),
                  ),
                );
              } else {
                return const SliverToBoxAdapter(
                  child: SizedBox.shrink(),
                );
              }
            },
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
