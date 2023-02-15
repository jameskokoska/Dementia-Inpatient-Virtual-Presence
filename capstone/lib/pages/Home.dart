import 'dart:async';
import 'dart:typed_data';

import 'package:capstone/database/tables.dart';
import 'package:capstone/pages/CreateUserPage.dart';
import 'package:capstone/pages/Face%20Scanner.dart';
import 'package:capstone/pages/Model.dart';
import 'package:capstone/pages/RecordAudio.dart';
import 'package:capstone/pages/RecordResponsesList.dart';
import 'package:capstone/struct/databaseGlobal.dart';
import 'package:capstone/widgets/TextFont.dart';
import 'package:capstone/widgets/UserEntry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mic_stream/mic_stream.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.setUser, super.key});

  final Function(User) setUser;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Home'),
            trailing: CupertinoButton(
              child: const Icon(CupertinoIcons.plus),
              onPressed: () {
                Navigator.push(context,
                    CupertinoPageRoute<Widget>(builder: (BuildContext context) {
                  return CreateUserPage();
                }));
              },
              padding: EdgeInsets.zero,
            ),
          ),
          StreamBuilder<List<User>>(
            stream: database.watchUsers(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print(snapshot.data);
                if (snapshot.data!.length <= 0) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Column(
                        children: [
                          const Center(
                              child: TextFont(text: "No users found.")),
                          const SizedBox(height: 15),
                          CupertinoButton.filled(
                            child: const Text("Create User"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute<Widget>(
                                  builder: (BuildContext context) {
                                    return const CreateUserPage();
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        if (index == snapshot.data?.length) {
                          return const HintText(
                            text: "Tap a user to start a call",
                          );
                        }
                        return UserEntry(
                            user: snapshot.data![index], setUser: setUser);
                      },
                      childCount: (snapshot.data?.length)! + 1,
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
        ],
      ),
    );
  }
}
