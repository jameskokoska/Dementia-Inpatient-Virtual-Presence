import 'dart:async';
import 'package:camera/camera.dart';
import 'package:capstone/colors.dart';
import 'package:capstone/widgets/CameraView.dart';
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
  String lastRecognizedText = "";
  String lastStatus = "";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      bool available = await speech.initialize(
        onStatus: (status) {
          if (status == "done" && lastStatus == "notListening") {
            setState(() {
              if (lastRecognizedText.contains("<Pause>")) {
                lastRecognizedText = "<Pause>";
              } else {
                lastRecognizedText = "$lastRecognizedText <Pause>";
              }
            });
          }
          lastStatus = status;
        },
      );
      if (available) {
        setState(() {
          isRecording = true;
        });
        while (isRecording) {
          await Future.delayed(const Duration(milliseconds: 100), () {
            speech.listen(
              onResult: (result) {
                setState(() {
                  lastRecognizedText = result.recognizedWords;
                });
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: getColor(context, "lightDark"),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CupertinoButton(
              borderRadius: BorderRadius.circular(50),
              minSize: 70,
              padding: EdgeInsets.zero,
              color: getColor(context, "red"),
              onPressed: () {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('End the call?'),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        onPressed: () async {
                          Navigator.pop(context);
                          popRoute();
                        },
                        child: const Text('End Call'),
                      ),
                    ],
                  ),
                );
              },
              child: const Icon(
                CupertinoIcons.phone_down_fill,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
    Widget recognizedText = lastRecognizedText != ""
        ? Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 145),
              decoration: BoxDecoration(
                color: (Colors.grey[600])!.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, right: 8.0, top: 5, bottom: 9),
                child: TextFont(
                  text: lastRecognizedText,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
    Widget cameraView = Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.only(
            right: 10, top: 15 + MediaQuery.of(context).viewPadding.top),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: const SizedBox(
            width: 110,
            child: CameraView(),
          ),
        ),
      ),
    );
    return WillPopScope(
      onWillPop: () async => false,
      child: CupertinoPageScaffold(
        child: Stack(
          children: [
            cameraView,
            centerContent,
            bottomButtons,
            recognizedText,
          ],
        ),
      ),
    );
  }
}
