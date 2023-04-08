import 'package:capstone/database/tables.dart';
import 'package:capstone/main.dart';
import 'package:capstone/pages/RecordResponsesList.dart';
import 'package:capstone/struct/databaseGlobal.dart';
import 'package:flutter/cupertino.dart';

final _formKey = GlobalKey<FormState>();

class EditSettingsPage extends StatelessWidget {
  const EditSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Settings'),
            previousPageTitle: "Home",
          ),
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.always,
                  onChanged: () {},
                  child: CupertinoFormSection.insetGrouped(
                    children: [
                      CupertinoTextFormFieldRow(
                        initialValue: appStateSettings["backend-ip"],
                        prefix: const Text('IP'),
                        textAlign: TextAlign.end,
                        onChanged: (value) {
                          updateSettings("backend-ip", value);
                        },
                      ),
                      CupertinoTextFormFieldRow(
                        initialValue: appStateSettings["duration-listen"],
                        prefix: const Text(
                            'Duration to listen\nbefore replying (ms)'),
                        textAlign: TextAlign.end,
                        onChanged: (value) {
                          updateSettings("duration-listen", value);
                        },
                      ),
                      CupertinoTextFormFieldRow(
                        initialValue: appStateSettings["duration-wait"],
                        prefix: const Text(
                            'Duration to wait before\nchoosing question (ms)'),
                        textAlign: TextAlign.end,
                        onChanged: (value) {
                          updateSettings("duration-wait", value);
                        },
                      ),
                    ],
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