import 'package:capstone/colors.dart';
import 'package:capstone/database/tables.dart';
import 'package:capstone/pages/RecordResponse.dart';
import 'package:capstone/struct/databaseGlobal.dart';
import 'package:capstone/widgets/Snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecordResponseEntry extends StatelessWidget {
  const RecordResponseEntry({
    required this.response,
    required this.responseID,
    required this.categoryID,
    required this.complete,
    required this.user,
    this.initialFilePathIfComplete,
    super.key,
  });

  final String response;
  final String responseID;
  final String categoryID;
  final bool complete;
  final User user;
  final String? initialFilePathIfComplete;

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
        onPressed: () async {
          if (complete) {
            bool result = true;
            try {
              result = await deleteVideo(context, user.recordings[responseID]!);
            } catch (e) {
              showCupertinoSnackBar(context: context, message: e.toString());
            }
            if (result) {
              User updatedUser = user;
              updatedUser.recordings.remove(responseID);
              database.createOrUpdateUser(updatedUser);
            }
            return;
          } else {
            Navigator.push(context,
                CupertinoPageRoute<Widget>(builder: (BuildContext context) {
              return RecordResponse(
                responseId: responseID,
                response: responses[categoryID]![responseID]!,
                user: user,
                initialFilePathIfComplete: initialFilePathIfComplete,
              );
            }));
          }
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
            initialFilePathIfComplete: initialFilePathIfComplete,
          );
        }))
      },
    );
  }
}
