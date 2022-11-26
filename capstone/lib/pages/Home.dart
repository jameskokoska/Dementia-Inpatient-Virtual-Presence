import 'dart:async';
import 'dart:typed_data';

import 'package:capstone/database/tables.dart';
import 'package:capstone/pages/CreateUserPage.dart';
import 'package:capstone/pages/Face%20Scanner.dart';
import 'package:capstone/pages/RecordAudio.dart';
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
              child: const Icon(CupertinoIcons.plus_app),
              onPressed: () {
                Navigator.push(context,
                    CupertinoPageRoute<Widget>(builder: (BuildContext context) {
                  return CreateUserPage();
                }));
              },
              padding: EdgeInsets.zero,
            ),
          ),
          // SliverToBoxAdapter(
          //   child: RecordAudio(),
          // ),
          // SliverToBoxAdapter(
          //   child: CupertinoButton(
          //     onPressed: () {
          //       Navigator.push(context,
          //           CupertinoPageRoute<Widget>(builder: (BuildContext context) {
          //         return FaceScannerPage();
          //       }));
          //     },
          //     child: Container(
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.end,
          //         children: <Widget>[
          //           Icon(CupertinoIcons.camera),
          //           Text("Scan Face"),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          StreamBuilder<List<User>>(
            stream: database.watchUsers(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
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
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        if (index == 0) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: TextFont(
                                text: "Tap a user to start a call",
                                textAlign: TextAlign.center,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }
                        return UserEntry(
                            user: snapshot.data![index - 1], setUser: setUser);
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
