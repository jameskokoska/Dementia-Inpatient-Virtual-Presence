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
  const UserEntry({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () {
        Navigator.push(
          context,
          CupertinoPageRoute<Widget>(
            builder: (BuildContext context) {
              return CallPage();
            },
          ),
        );
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
                text: user.name[0],
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
              TextFont(
                text: user.description,
                textColor: getColor(context, "black"),
                fontSize: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
