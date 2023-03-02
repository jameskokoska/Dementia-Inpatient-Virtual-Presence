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
  String url = 'http://192.168.2.98:5000/response';

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
  bool isRecording = false;
  bool isMuted = false;
  bool isMutedFrontEnd = false;
  String lastRecognizedText = "";
  String responseText = "";
  String lastStatus = "";
  bool isFacingFront = true;
  bool isPlayingARecording = false;
  String? selectedId;
  late User? user = widget.user;

  @override
  void didUpdateWidget(Widget oldWidget) {
    if (widget.user != user) {
      setState(() {
        user = widget.user;
        isRecording = true;
        lastStatus = "";
        lastRecognizedText = "";
        isPlayingARecording = false;
        isMuted = false;
        isMutedFrontEnd = false;
        responseText = "";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      bool available = await speech.initialize(
        onStatus: (status) {
          if (status == "done" && lastStatus == "notListening") {
            _determineWhatToPlay(lastRecognizedText);
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
        _startRecordingLoop();
      } else {
        setState(() {
          isRecording = false;
        });
      }
    });
  }

  _startRecordingLoop() async {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 100), () {
        if (!isMuted && user != null && isRecording && !isMutedFrontEnd) {
          speech.listen(
            onResult: (result) {
              setState(() {
                lastRecognizedText = result.recognizedWords;
              });
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
            Text(user!.recordings["1"]!, textAlign: TextAlign.center)
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
                isRecording = false;
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

  void _determineWhatToPlay(inputText) async {
    try {
      if (!isPlayingARecording && isMutedFrontEnd == false) {
        if (inputText != "<Pause>") {
          String selectedIdResponse = await getResponse(inputText, user!);
          print(selectedIdResponse);
          print("RESPONSE:" + findResponseId(selectedIdResponse)!);
          if (isPlayingARecording == false) {
            setState(() {
              isPlayingARecording = true;
              isMuted = true;
              responseText = findResponseId(selectedIdResponse) ?? "";
              selectedId = selectedIdResponse;
            });
            speech.cancel();
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    isRecording = false;
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
    } else {
      centerContent = Stack(children: [
        user!.recordings["idle"] == null
            ? const SizedBox.shrink()
            : Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 105),
                  child: PlayBackVideo(
                    key: ValueKey(2),
                    filePath: user!.recordings["idle"]!,
                    isLooping: true,
                    volume: 0,
                    initializeFirst: false,
                  ),
                ),
              ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
              padding: EdgeInsets.only(bottom: 105),
              child: isPlayingARecording == true &&
                      selectedId != null &&
                      user!.recordings[selectedId] != null
                  ? PlayBackVideo(
                      key: const ValueKey(1),
                      filePath: user!.recordings[selectedId]!,
                      isLooping: false,
                      onFinishPlayback: () {
                        setState(() {
                          isPlayingARecording = false;
                          isMuted = false;
                        });
                      },
                    )
                  : Container(
                      color: Colors.transparent,
                      key: const ValueKey(2),
                    )),
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
    Widget responseTextWidget = responseText != ""
        ? Positioned(
            bottom: 145,
            width: MediaQuery.of(context).size.width,
            child: Container(
              color: getColor(context, "lightDark"),
              padding: const EdgeInsets.only(
                  left: 8.0, right: 8.0, top: 5, bottom: 9),
              child: TextFont(
                textColor: Colors.red,
                text: responseText,
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
            child: isRecording == true && user != null
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
            isPlayingARecording ? SizedBox.shrink() : recognizedText,
            isPlayingARecording ? responseTextWidget : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
