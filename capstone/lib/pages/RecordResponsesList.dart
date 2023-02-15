import 'package:capstone/colors.dart';
import 'package:capstone/database/tables.dart';
import 'package:capstone/pages/RecordResponse.dart';
import 'package:capstone/struct/databaseGlobal.dart';
import 'package:capstone/widgets/RecordResponseEntry.dart';
import 'package:capstone/widgets/TextFont.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final _formKey = GlobalKey<FormState>();

class RecordResponsesList extends StatefulWidget {
  const RecordResponsesList(
      {required this.userID, this.isEditing = false, super.key});
  final int userID;
  final bool isEditing;

  @override
  State<RecordResponsesList> createState() => _RecordResponsesListState();
}

class _RecordResponsesListState extends State<RecordResponsesList> {
  String name = "";
  String description = "";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      User user = await database.getUser(widget.userID);
      setState(() {
        name = user.name;
        description = user.description;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: StreamBuilder<User>(
        stream: database.watchUser(widget.userID),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            User user = snapshot.data!;
            return CustomScrollView(
              slivers: <Widget>[
                CupertinoSliverNavigationBar(
                  largeTitle: Text(name),
                  previousPageTitle: "Home",
                  trailing: CupertinoButton(
                    onPressed: () async {
                      bool result =
                          await confirmDelete(context, "Delete user?");
                      if (result == true) {
                        await database.deleteUser(user.id);
                        Navigator.pop(context);
                      }
                    },
                    padding: const EdgeInsets.only(
                        left: 14, right: 7, top: 12, bottom: 12),
                    child: const Icon(
                      CupertinoIcons.delete,
                      size: 20,
                    ),
                  ),
                ),
                for (String category in responses.keys)
                  SliverToBoxAdapter(
                    child: CupertinoListSection.insetGrouped(
                      header: Text(category),
                      children: [
                        for (String responseID in responses[category]!.keys)
                          RecordResponseEntry(
                            responseID: responseID,
                            response: responses[category]![responseID]!,
                            complete: user.recordings.containsKey(responseID),
                            categoryID: category,
                            user: user,
                          ),
                      ],
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(left: 22, bottom: 8),
                    child: TextFont(
                      fontWeight: FontWeight.bold,
                      text: "Details",
                      fontSize: 20,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.always,
                    onChanged: () {},
                    child: CupertinoFormSection.insetGrouped(
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
                          initialValue: user.name,
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
                          initialValue: user.description,
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
                SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoButton.filled(
                        child:
                            Text(widget.isEditing ? "Update User" : "Add User"),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(
                    child: HintText(
                  text:
                      "Record responses by tapping the respective above and add user when completed.",
                )),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
