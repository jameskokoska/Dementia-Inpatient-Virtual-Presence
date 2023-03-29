import 'dart:async';
import 'package:capstone/colors.dart';
import 'package:capstone/database/tables.dart';
import 'package:capstone/pages/PlayBackVideo.dart';
import 'package:capstone/widgets/CameraView.dart';
import 'package:capstone/widgets/TextFont.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> getResponse(String inputText, User user) async {
  String url = 'http://10.0.0.50:5000/response';

  Map data = {'input_text': inputText};
  String body = json.encode(data);
  debugPrint(body);

  var response = await http.post(
    Uri.parse(url),
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  final intInStr = RegExp(r'\d+');

  for (int i = 0; i < json.decode(response.body).length; i++) {
    List<String?> responseIds = intInStr
        .allMatches(json.decode(response.body)[0]["intent"])
        .map((m) => m.group(0))
        .toList();

    // print(responseIds);

    for (int j = 0; j < responseIds.length; j++) {
      if (user.recordings[responseIds[j]] != null) {
        return responseIds[j].toString();
      }
    }
  }

  // print(responseList);
  return json.decode(response.body)["response_id"].toString();
}

class CallPage extends StatefulWidget {
  const CallPage(
      {required this.user, required this.setCurrentPageIndex, super.key});
  final User? user;
  final Function(int) setCurrentPageIndex;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  stt.SpeechToText speech = stt.SpeechToText();
  bool isAvailable = false;
  bool isMutedFrontEnd = false;
  String lastRecognizedText = "";
  bool isFacingFront = true;
  String? selectedId;
  late User? user = widget.user;
  bool isPlayingRecording = false;

  @override
  void didUpdateWidget(Widget oldWidget) {
    if (widget.user != user) {
      setState(() {
        user = widget.user;
        lastRecognizedText = "";
        isMutedFrontEnd = false;
        isPlayingRecording = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      bool available = await speech.initialize(
        onStatus: (status) async {
          print("STATUS:" + status);
        },
      );
      if (available) {
        setState(() {
          isAvailable = true;
        });
        print("IS AVAILABLE!");
        _startRecordingLoop();
      } else {
        setState(() {
          isAvailable = false;
        });
      }
    });
  }

  final _isTalkingDebouncer = Debouncer(milliseconds: 3500);

  _startRecordingLoop() async {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 100), () {
        if (isPlayingRecording == false && user != null && !isMutedFrontEnd) {
          speech.listen(
            onResult: (result) {
              print(result.recognizedWords);
              if (result.finalResult) {
                setState(() {
                  lastRecognizedText =
                      (lastRecognizedText + " " + result.recognizedWords)
                          .trim();
                });
              } else {
                _isTalkingDebouncer.run(() {
                  print("DEBOUNCER OVER");
                  _determineWhatToPlay(lastRecognizedText);
                });
              }
            },
            partialResults: true,
          );
        }
      });
    }
  }

  void _showCallInfo() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Call Info'),
        content: Column(
          children: [
            Text(
              user!.name,
              textAlign: TextAlign.center,
            ),
            user!.description != ""
                ? Text(user!.description, textAlign: TextAlign.center)
                : const SizedBox.shrink(),
            Text(user!.recordings.toString(), textAlign: TextAlign.center)
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
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                user = null;
              });
              widget.setCurrentPageIndex(0);
              Future.delayed(const Duration(milliseconds: 100), () {
                speech.stop();
                speech.cancel();
              });
            },
            child: const Text('End Call'),
          ),
        ],
      ),
    );
  }

  Future<bool> _determineWhatToPlay(inputText) async {
    try {
      if (lastRecognizedText != "" && selectedId == null) {
        isPlayingRecording = true;
        lastRecognizedText = "";
        speech.cancel();
        if (isMutedFrontEnd == false) {
          print(inputText);
          String selectedIdResponse = await getResponse(inputText, user!);
          print(selectedIdResponse);
          print("RESPONSE:" + findResponseId(selectedIdResponse)!);
          if (selectedId == null) {
            setState(() {
              selectedId = selectedIdResponse;
            });
          }
        }
      }
      return true;
    } catch (e) {
      debugPrint("Most likely the user has not recorded this response");
      debugPrint(e.toString());
      isPlayingRecording = false;
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget centerContent = Container();
    if (user == null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(35),
          child: const TextFont(
            text: "No user selected.",
            textAlign: TextAlign.center,
            maxLines: 10,
          ),
        ),
      );
    }
    if (isAvailable == false) {
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
    } else {
      centerContent = Stack(children: [
        user!.recordings["idle"] == null
            ? const SizedBox.shrink()
            : Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: PlayBackVideo(
                    key: ValueKey(2),
                    filePath: user!.recordings["idle"]!,
                    isLooping: true,
                    volume: 0,
                    initializeFirst: false,
                  ),
                ),
              ),
        Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: Align(
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: selectedId != null && user!.recordings[selectedId] != null
                  ? PlayBackVideo(
                      key: const ValueKey(1),
                      filePath: user!.recordings[selectedId]!,
                      isLooping: false,
                      onFinishPlayback: () {
                        setState(() {
                          selectedId = null;
                          isPlayingRecording = false;
                        });
                        // setState(() {
                        //   isPlayingARecording = false;
                        //   isMuted = false;
                        // });
                      },
                    )
                  : SizedBox(
                      key: const ValueKey(2),
                    ),
            ),
          ),
        ),
        // Align(
        //   alignment: Alignment.bottomCenter,
        //   child: Padding(
        //     padding: EdgeInsets.only(bottom: 105),
        //     child: Model(),
        //   ),
        // ),
      ]);
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
              color:
                  !isMutedFrontEnd ? getColor(context, "gray") : Colors.white,
              onPressed: () {
                speech.cancel();
                setState(() {
                  isMutedFrontEnd = !isMutedFrontEnd;
                });
              },
              child: Icon(
                !isMutedFrontEnd
                    ? CupertinoIcons.mic_fill
                    : CupertinoIcons.mic_slash_fill,
                color: !isMutedFrontEnd ? Colors.white : Colors.grey,
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
            child: Container(
              color: getColor(context, "lightDark"),
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
    Widget responseTextWidget = selectedId != null
        ? Positioned(
            bottom: 145,
            width: MediaQuery.of(context).size.width,
            child: Container(
              color: getColor(context, "lightDark"),
              padding: const EdgeInsets.only(
                  left: 8.0, right: 8.0, top: 5, bottom: 9),
              child: TextFont(
                textColor: Colors.red,
                text: findResponseId(selectedId ?? "") ?? "",
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
            child: user != null
                ? CameraView(isFacingFront: isFacingFront)
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
    return WillPopScope(
      onWillPop: () async => false,
      child: CupertinoPageScaffold(
        child: Stack(
          children: [
            centerContent,
            cameraView,
            bottomButtons,
            selectedId != null ? SizedBox.shrink() : recognizedText,
            selectedId != null ? responseTextWidget : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
