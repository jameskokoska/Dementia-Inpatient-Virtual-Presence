import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:capstone/colors.dart';
import 'package:capstone/database/tables.dart';
import 'package:capstone/widgets/CameraView.dart';
import 'package:capstone/widgets/TextFont.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/cupertino.dart';

class CallPage extends StatefulWidget {
  const CallPage({required this.user, super.key});
  final User user;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  stt.SpeechToText speech = stt.SpeechToText();
  final _audioPlayer = AudioPlayer();
  late StreamSubscription<void> _playerStateChangedSubscription;
  bool isRecording = false;
  bool isMuted = false;
  String lastRecognizedText = "";
  String lastStatus = "";
  bool isFacingFront = true;
  bool isPlayingARecording = false;

  @override
  void initState() {
    super.initState();
    _playerStateChangedSubscription =
        _audioPlayer.onPlayerComplete.listen((state) async {
      await _audioPlayer.stop();
      setState(() {
        isPlayingARecording = false;
        isMuted = false;
      });
    });
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
            _determineWhatToPlay(lastRecognizedText);
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
            if (!isMuted) {
              speech.listen(
                onResult: (result) {
                  setState(() {
                    lastRecognizedText = result.recognizedWords;
                  });
                  // print(result.recognizedWords);
                },
                partialResults: true,
              );
            }
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
    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  void _showCallInfo() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Call Info'),
        content: Column(
          children: [
            Text(
              widget.user.name,
              textAlign: TextAlign.center,
            ),
            widget.user.description != ""
                ? Text(widget.user.description, textAlign: TextAlign.center)
                : const SizedBox.shrink(),
            Text(widget.user.recordings["1"]!, textAlign: TextAlign.center)
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () async {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEndCall() {
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
  }

  void _determineWhatToPlay(inputText) {
    try {
      if (!isPlayingARecording) {
        if (inputText != "<Pause>") {
          print(inputText);
          int selectedId = 1;
          _audioPlayer.play(
            kIsWeb
                ? UrlSource(widget.user.recordings[selectedId.toString()]!)
                : DeviceFileSource(
                    widget.user.recordings[selectedId.toString()]!),
          );
          setState(() {
            isPlayingARecording = true;
            isMuted = true;
          });
          speech.cancel();
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void dispose() {
    setState(() {
      isRecording = false;
    });
    _audioPlayer.dispose();
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: getColor(context, "lightDark"),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CupertinoButton(
              borderRadius: BorderRadius.circular(50),
              minSize: 65,
              padding: EdgeInsets.zero,
              color: getColor(context, "gray"),
              onPressed: () {
                _showCallInfo();
              },
              child: const Icon(
                CupertinoIcons.person_fill,
                color: Colors.white,
                size: 24,
              ),
            ),
            CupertinoButton(
              borderRadius: BorderRadius.circular(50),
              minSize: 65,
              padding: EdgeInsets.zero,
              color: getColor(context, "gray"),
              onPressed: () {
                setState(() {
                  isFacingFront = !isFacingFront;
                });
              },
              child: const Icon(
                CupertinoIcons.switch_camera_solid,
                color: Colors.white,
                size: 24,
              ),
            ),
            CupertinoButton(
              borderRadius: BorderRadius.circular(50),
              minSize: 65,
              padding: EdgeInsets.zero,
              color: !isMuted ? getColor(context, "gray") : Colors.white,
              onPressed: () {
                speech.cancel();
                setState(() {
                  isMuted = !isMuted;
                });
              },
              child: Icon(
                !isMuted
                    ? CupertinoIcons.mic_fill
                    : CupertinoIcons.mic_slash_fill,
                color: !isMuted ? Colors.white : Colors.grey,
                size: 24,
              ),
            ),
            CupertinoButton(
              borderRadius: BorderRadius.circular(50),
              minSize: 65,
              padding: EdgeInsets.zero,
              color: getColor(context, "red"),
              onPressed: () {
                _showEndCall();
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
        ? Positioned(
            bottom: 145,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, right: 8.0, top: 5, bottom: 9),
              child: TextFont(
                text: lastRecognizedText,
                maxLines: 2,
                textAlign: TextAlign.center,
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
          child: SizedBox(
            width: 110,
            child: CameraView(isFacingFront: isFacingFront),
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
