import 'dart:io';

import 'package:camera/camera.dart';
import 'package:capstone/colors.dart';
import 'package:capstone/database/tables.dart';
import 'package:capstone/pages/Face%20Scanner.dart';
import 'package:capstone/pages/PlayBackVideo.dart';
import 'package:capstone/pages/RecordCamera.dart';
import 'package:capstone/pages/RecordResponsesList.dart';
import 'package:capstone/struct/databaseGlobal.dart';
import 'package:capstone/widgets/TextFont.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

final _formKey = GlobalKey<FormState>();

class CreateUserPage extends StatelessWidget {
  const CreateUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    String name = "";
    String description = "";

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          const CupertinoSliverNavigationBar(
            largeTitle: Text('New User'),
            previousPageTitle: "Home",
          ),
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.always,
                  onChanged: () {},
                  child: CupertinoFormSection.insetGrouped(
                    header: const Text('Details'),
                    children: [
                      CupertinoTextFormFieldRow(
                        prefix: const Text('Name'),
                        textAlign: TextAlign.end,
                        validator: (String? value) {
                          if (value == null || value.isEmpty || value == "") {
                            return 'Please enter a value';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          name = value;
                        },
                      ),
                      CupertinoTextFormFieldRow(
                        prefix: const Text('Notes'),
                        textAlign: TextAlign.end,
                        validator: (String? value) {
                          return null;
                        },
                        onChanged: (value) {
                          description = value;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                CupertinoButton.filled(
                  child: const Text("Record Responses"),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      int id = DateTime.now().millisecondsSinceEpoch;
                      await database.createOrUpdateUser(
                        User(
                          id: id,
                          name: name,
                          description: description,
                          recordings: {},
                        ),
                      );
                      User user = await database.getUser(id);
                      Navigator.pop(context);
                      Navigator.push(context, CupertinoPageRoute<Widget>(
                          builder: (BuildContext context) {
                        return RecordResponsesList(
                          userID: user.id,
                          isEditing: false,
                        );
                      }));
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
