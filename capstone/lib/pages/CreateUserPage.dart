import 'package:capstone/database/tables.dart';
import 'package:capstone/struct/databaseGlobal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateUserPage extends StatelessWidget {
  const CreateUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    String name = "";
    String description = "";
    final _formKey = GlobalKey<FormState>();

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          const CupertinoSliverNavigationBar(
            largeTitle: Text('New User'),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.always,
                  onChanged: () {},
                  child: CupertinoFormSection.insetGrouped(
                    header: Text('Details'),
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
                SizedBox(height: 15),
                CupertinoButton.filled(
                  child: Text("Add User"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      database.createOrUpdateUser(
                        User(
                          id: DateTime.now().millisecondsSinceEpoch,
                          name: name,
                          description: description,
                        ),
                      );
                      Navigator.pop(context);
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
