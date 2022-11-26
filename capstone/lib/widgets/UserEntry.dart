import 'package:capstone/colors.dart';
import 'package:capstone/database/tables.dart';
import 'package:capstone/main.dart';
import 'package:capstone/pages/CallPage.dart';
import 'package:capstone/pages/Face%20Scanner.dart';
import 'package:capstone/struct/databaseGlobal.dart';
import 'package:capstone/widgets/TextFont.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserEntry extends StatelessWidget {
  const UserEntry({required this.user, required this.setUser, super.key});

  final User user;
  final Function(User) setUser;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.red,
        ),
        child: const Padding(
          padding: EdgeInsets.only(right: 25),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      confirmDismiss: (DismissDirection direction) async {
        return await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Delete ${user.name} ?'),
            actions: [
              CupertinoDialogAction(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              CupertinoDialogAction(
                child: Text('Delete'),
                isDestructiveAction: true,
                onPressed: () async {
                  Navigator.of(context).pop(true);
                  await Future.delayed(Duration(milliseconds: 500), () async {
                    await database.deleteUser(user.id);
                  });
                },
              ),
            ],
          ),
        );
      },
      key: ValueKey<int>(this.user.id),
      onDismissed: (DismissDirection direction) {},
      child: CupertinoButton(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   CupertinoPageRoute<Widget>(
          //     builder: (BuildContext context) {
          //       return CallPage(
          //         key: ValueKey(user.id),
          //         user: user,
          //       );
          //     },
          //   ),
          // );
          setUser(user);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: getColor(context, "gray"),
              ),
              child: Center(
                child: TextFont(
                  text: user.name.isEmpty ? "" : user.name[0],
                  fontWeight: FontWeight.bold,
                  textColor: Colors.white,
                  textAlign: TextAlign.center,
                  fontSize: 25,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFont(
                  text: user.name,
                  fontWeight: FontWeight.bold,
                  textColor: getColor(context, "black"),
                  fontSize: 20,
                ),
                user.description != ""
                    ? TextFont(
                        text: user.description,
                        textColor: getColor(context, "black"),
                        fontSize: 16,
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
