import 'package:capstone/colors.dart';
import 'package:capstone/database/tables.dart';
import 'package:capstone/main.dart';
import 'package:capstone/pages/CallPage.dart';
import 'package:capstone/pages/Face%20Scanner.dart';
import 'package:capstone/pages/RecordResponse.dart';
import 'package:capstone/struct/databaseGlobal.dart';
import 'package:capstone/widgets/TextFont.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecordResponseEntry extends StatelessWidget {
  const RecordResponseEntry({
    required this.response,
    required this.responseID,
    required this.categoryID,
    required this.complete,
    required this.user,
    super.key,
  });

  final String response;
  final String responseID;
  final String categoryID;
  final bool complete;
  final User user;

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      title: Text(response),
      leading: Icon(
        complete
            ? Icons.check_box_rounded
            : Icons.indeterminate_check_box_rounded,
        color: complete
            ? getColor(context, "completeGreen")
            : getColor(context, "incompleteRed"),
      ),
      trailing: CupertinoButton(
        onPressed: () {
          Navigator.push(context,
              CupertinoPageRoute<Widget>(builder: (BuildContext context) {
            return RecordResponse(
              responseId: responseID,
              response: responses[categoryID]![responseID]!,
              user: user,
            );
          }));
        },
        padding: const EdgeInsets.only(left: 14, right: 7, top: 12, bottom: 12),
        child: complete
            ? const Icon(
                CupertinoIcons.delete,
                size: 20,
              )
            : const CupertinoListTileChevron(),
      ),
      onTap: () => {
        Navigator.push(context,
            CupertinoPageRoute<Widget>(builder: (BuildContext context) {
          return RecordResponse(
            responseId: responseID,
            response: responses[categoryID]![responseID]!,
            user: user,
          );
        }))
      },
    );
  }
}
