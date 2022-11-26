import 'dart:async';
import 'package:capstone/colors.dart';
import 'package:capstone/widgets/TextFont.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/cupertino.dart';

class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  stt.SpeechToText speech = stt.SpeechToText();
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      bool available = await speech.initialize(
        onStatus: (status) {
          print(status);
        },
      );
      if (available) {
        setState(() {
          isRecording = true;
        });
        for (int i = 0; i < 5000; i++) {
          if (isRecording == false) break;
          await Future.delayed(Duration(milliseconds: 100), () {
            speech.listen(
              onResult: (result) {
                print(result.recognizedWords);
              },
              partialResults: true,
            );
          });
        }
      } else {
        setState(() {
          isRecording = false;
        });
      }
    });
  }

  void popRoute() {
    Future.delayed(Duration(milliseconds: 100), () {
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  @override
  void dispose() {
    setState(() {
      isRecording = false;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget centerContent = Container();
    if (isRecording == false) {
      centerContent = Center(
        child: Container(
          padding: const EdgeInsets.all(35),
          child: const TextFont(
            text: "Please enable microphone to continue.",
            textAlign: TextAlign.center,
            maxLines: 10,
          ),
        ),
      );
    }
    Widget bottomButtons = Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        children: [
          CupertinoButton(
            borderRadius: BorderRadius.circular(50),
            minSize: 80,
            padding: EdgeInsets.zero,
            color: getColor(context, "red"),
            onPressed: () {
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('End the call?'),
                  actions: [
                    CupertinoDialogAction(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    CupertinoDialogAction(
                      child: Text('End Call'),
                      isDestructiveAction: true,
                      onPressed: () async {
                        Navigator.pop(context);
                        popRoute();
                      },
                    ),
                  ],
                ),
              );
            },
            child: Icon(
              CupertinoIcons.phone_down_fill,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
    return WillPopScope(
      onWillPop: () async => false,
      child: CupertinoPageScaffold(
        child: Stack(
          children: [
            centerContent,
            bottomButtons,
          ],
        ),
      ),
    );
  }
}
