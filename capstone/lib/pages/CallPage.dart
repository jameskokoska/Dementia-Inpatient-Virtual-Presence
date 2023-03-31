import 'dart:async';
import 'package:capstone/colors.dart';
import 'package:capstone/database/tables.dart';
import 'package:capstone/main.dart';
import 'package:capstone/pages/PlayBackVideo.dart';
import 'package:capstone/widgets/CameraView.dart';
import 'package:capstone/widgets/TextFont.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> getResponse(String inputText, User user) async {
  String url = appStateSettings["backend-ip"] + '/response';

  Map data = {'input_text': inputText};
  String body = json.encode(data);
  debugPrint(body);

  var response = await http.post(
    Uri.parse(url),
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  for (int i = 0; i < json.decode(response.body).length; i++) {
    List<String?> responseIds = orderIntents(json.decode(response.body));

    for (int j = 0; j < responseIds.length; j++) {
      if (user.recordings[responseIds[j]] != null) {
        return responseIds[j].toString();
      }
    }
  }

  return json.decode(response.body)["response_id"].toString();
}

String extractNumberFromEnd(String input) {
  final RegExp regex = RegExp(r'\((\d+)\)$');
  final Match? match = regex.firstMatch(input);
  if (match == null) {
    throw ArgumentError(
        'Input does not contain a number in brackets at the end.');
  }
  return match.group(1)!;
}

List<String> orderIntents(List<dynamic> intents) {
  try {
    List<String> orderedIntents = [];

    // Create a Map of intents with their probabilities as keys
    Map<double, String> intentMap = {};
    for (var intent in intents) {
      double probability = double.parse(intent['probability']!);
      intentMap[probability] = intent['intent']!;
    }

    // Sort the keys (probabilities) in descending order
    List<double> sortedKeys = intentMap.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Add the intents to the ordered list in descending order of probability
    for (var key in sortedKeys) {
      orderedIntents.add(extractNumberFromEnd(intentMap[key]!));
    }

    return orderedIntents;
  } catch (e) {
    debugPrint(
        "$e The format recieved from the backend is different than what was expected.");
  }
  return [];
}

String? getRandomQuestion(User user) {
  List<String> questionIDs = responses["Questions"]!.keys.toList();
  questionIDs.shuffle();
  for (String responseID in questionIDs) {
    if (user.recordings[responseID] != null) {
      return responseID.toString();
    }
  }
  return null;
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
  bool callLoading = true;
  stt.SpeechToText speech = stt.SpeechToText();
  bool isAvailable = false;
  bool isMutedFrontEnd = false;
  String lastRecognizedText = "";
  bool isFacingFront = true;
  String? selectedId;
  late User? user = widget.user;
  bool isPlayingRecording = false;

  Debouncer _isTalkingDebouncer =
      Debouncer(milliseconds: int.parse(appStateSettings["duration-listen"]));
  Debouncer _silenceDebouncer =
      Debouncer(milliseconds: int.parse(appStateSettings["duration-wait"]));
  Timer? callLoadingTimer;
  Timer? playOpeningTimer;
  @override
  void didUpdateWidget(CallPage oldWidget) {
    debugPrint("Loaded page");
    if (widget.user != user) {
      _isTalkingDebouncer = Debouncer(
          milliseconds: int.parse(appStateSettings["duration-listen"]));
      _silenceDebouncer =
          Debouncer(milliseconds: int.parse(appStateSettings["duration-wait"]));
      setState(() {
        callLoading = true;
        user = widget.user;
        selectedId = null;
        isPlayingRecording = false;
      });

      callLoadingTimer = Timer(const Duration(milliseconds: 1500), () {
        setState(() {
          lastRecognizedText = "";
          isMutedFrontEnd = false;
          isPlayingRecording = false;
          selectedId = null;
          callLoading = false;
        });
        playOpeningTimer = Timer(const Duration(milliseconds: 500), () {
          playOpening();
        });
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      bool available = await speech.initialize(
          // onStatus: (status) async {
          //   print("STATUS:" + status);
          // },
          );
      if (available) {
        setState(() {
          isAvailable = true;
        });
        _startRecordingLoop();
      } else {
        setState(() {
          isAvailable = false;
        });
      }
    });
  }

  _startRecordingLoop() async {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 100), () {
        if (callLoading == false &&
            (isPlayingRecording == true || lastRecognizedText != "")) {
          _silenceDebouncer.run(() {
            playRandomQuestion();
          });
        }
        if (callLoading == false &&
            isPlayingRecording == false &&
            user != null &&
            !isMutedFrontEnd) {
          speech.listen(
            onResult: (result) {
              _silenceDebouncer.run(() {
                playRandomQuestion();
              });
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

  void endCall() {
    setState(() {
      user = null;
      _isTalkingDebouncer.cancel();
      _silenceDebouncer.cancel();
      callLoadingTimer?.cancel();
      playOpeningTimer?.cancel();
    });
    widget.setCurrentPageIndex(0);
    Future.delayed(const Duration(milliseconds: 100), () {
      speech.stop();
      speech.cancel();
    });
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
              endCall();
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

  bool playRandomQuestion() {
    if (isMutedFrontEnd == false) {
      String? selectedIdResponse = getRandomQuestion(user!);
      debugPrint("randomQuestion $selectedIdResponse");
      if (selectedId == null && selectedIdResponse != null) {
        isPlayingRecording = true;
        lastRecognizedText = "";
        speech.cancel();
        setState(() {
          selectedId = selectedIdResponse;
        });
      }
    }
    return true;
  }

  bool playOpening() {
    if (isMutedFrontEnd == false) {
      String selectedIdResponse = "opening";
      if (selectedId == null && user!.recordings[selectedIdResponse] != null) {
        isPlayingRecording = true;
        lastRecognizedText = "";
        speech.cancel();
        setState(() {
          selectedId = selectedIdResponse;
        });
      }
    }
    return true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget centerContent = Container();
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
        user?.recordings["idle"] == null
            ? Center(
                child: Container(
                  padding: const EdgeInsets.all(35),
                  child: const TextFont(
                    text: "No idle video found.",
                    textAlign: TextAlign.center,
                    maxLines: 10,
                  ),
                ),
              )
            : Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: PlayBackVideo(
                    key: const ValueKey(2),
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
              duration: const Duration(milliseconds: 200),
              child: selectedId != null && user?.recordings[selectedId] != null
                  ? PlayBackVideo(
                      key: const ValueKey(1),
                      filePath: user!.recordings[selectedId]!,
                      isLooping: false,
                      onFinishPlayback: () {
                        setState(() {
                          selectedId = null;
                          isPlayingRecording = false;
                        });
                      },
                    )
                  : const SizedBox(
                      key: ValueKey(2),
                    ),
            ),
          ),
        ),
      ]);
    }

    Widget bottomButtons = Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: getColor(context, "lightDark").withOpacity(0.8),
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
            Container(color: Colors.black),
            callLoading
                ? Container(
                    color: getColor(context, "white"),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Center(
                          child: CupertinoActivityIndicator(),
                        ),
                        const SizedBox(height: 25),
                        Center(
                          child: TextFont(
                            text: "Connecting to ${user?.name}",
                            fontSize: 15,
                          ),
                        )
                      ],
                    ),
                  )
                : centerContent,
            cameraView,
            bottomButtons,
            selectedId != null ? Container() : recognizedText,
            selectedId != null ? responseTextWidget : Container(),
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

  cancel() {
    _timer?.cancel();
  }
}
