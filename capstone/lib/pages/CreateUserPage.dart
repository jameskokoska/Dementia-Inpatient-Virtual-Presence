import 'dart:io';

import 'package:capstone/colors.dart';
import 'package:capstone/database/tables.dart';
import 'package:capstone/pages/Face%20Scanner.dart';
import 'package:capstone/struct/databaseGlobal.dart';
import 'package:capstone/widgets/TextFont.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

final _formKey = GlobalKey<FormState>();

class CreateUserPage extends StatelessWidget {
  const CreateUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    String name = "";
    String description = "";

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          const CupertinoSliverNavigationBar(
            largeTitle: Text('New User'),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.always,
                  onChanged: () {},
                  child: CupertinoFormSection.insetGrouped(
                    header: Text('Details'),
                    children: [
                      CupertinoTextFormFieldRow(
                        prefix: const Text('Name'),
                        textAlign: TextAlign.end,
                        validator: (String? value) {
                          if (value == null || value.isEmpty || value == "") {
                            return 'Please enter a value';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          name = value;
                        },
                      ),
                      CupertinoTextFormFieldRow(
                        prefix: const Text('Notes'),
                        textAlign: TextAlign.end,
                        validator: (String? value) {
                          return null;
                        },
                        onChanged: (value) {
                          description = value;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                CupertinoButton.filled(
                  child: const Text("Scan Facial Features"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(context, CupertinoPageRoute<Widget>(
                          builder: (BuildContext context) {
                        return FaceScannerPage(
                          user: User(
                            id: DateTime.now().millisecondsSinceEpoch,
                            name: name,
                            description: description,
                            recordings: {},
                          ),
                        );
                      }));
                      // Navigator.push(context, CupertinoPageRoute<Widget>(
                      //     builder: (BuildContext context) {
                      //   return RecordResponse(
                      //     responseId: "0",
                      //     user: User(
                      //       id: DateTime.now().millisecondsSinceEpoch,
                      //       name: name,
                      //       description: description,
                      //       recordings: {},
                      //     ),
                      //   );
                      // }));
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecordResponse extends StatefulWidget {
  const RecordResponse(
      {required this.responseId, required this.user, super.key});
  final String responseId;
  final User user;

  @override
  State<RecordResponse> createState() => _RecordResponseState();
}

class _RecordResponseState extends State<RecordResponse> {
  final record = Record();
  bool recordingAvailable = false;
  bool isRecording = false;
  String? recordingPath;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      if (await record.hasPermission()) {
        setState(() {
          recordingAvailable = true;
        });
      }
    });
  }

  Future<void> _recordAudio() async {
    if (isRecording) {
      String? path = await record.stop();
      print(path);
      setState(() {
        isRecording = false;
        recordingPath = path;
      });
    } else {
      await record.start();
      bool status = await record.isRecording();
      setState(() {
        isRecording = status;
      });
    }
  }

  Future<void> _deleteAudio() async {
    try {
      final file = File(recordingPath!);
      await file.delete();
      showCupertinoSnackBar(context: context, message: "Deleted recording");
      setState(() {
        recordingPath = null;
      });
      return;
    } catch (e) {
      showCupertinoSnackBar(context: context, message: e.toString());
      return;
    }
  }

  void _restartRecording() async {
    await _deleteAudio();
    await _recordAudio();
  }

  void _nextId() async {
    if (recordingPath == null) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Please record a response before proceeding'),
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
    } else {
      String? nextId = determineNextId(widget.responseId);
      if (nextId == null) {
        database.createOrUpdateUser(
          widget.user,
        );
        // we are done getting all the audio recordings
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        User user = widget.user.copyWith(recordings: {
          ...widget.user.recordings,
          widget.responseId: recordingPath ?? ""
        });
        print(user);
        Navigator.push(context,
            CupertinoPageRoute<Widget>(builder: (BuildContext context) {
          return RecordResponse(responseId: nextId, user: user);
        }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: CupertinoPageScaffold(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: <Widget>[
                const CupertinoSliverNavigationBar(
                  largeTitle: Text('Record Responses'),
                  automaticallyImplyLeading: false,
                ),
                SliverToBoxAdapter(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height / 4),
                      Center(
                        child: TextFont(
                          text: "Please say:",
                          fontSize: 15,
                          textColor: getColor(context, "gray"),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: TextFont(
                            text: responses[widget.responseId] ?? "",
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.center,
                            maxLines: 50,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    recordingPath == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: CupertinoButton(
                              color: getColor(context, "lightDark"),
                              borderRadius: BorderRadius.circular(50),
                              minSize: 50,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                _restartRecording();
                              },
                              child: Icon(
                                CupertinoIcons.restart,
                                color: getColor(context, "black"),
                              ),
                            ),
                          ),
                    const SizedBox(width: 15),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: CupertinoButton(
                            color: isRecording
                                ? getColor(context, "red")
                                : getColor(context, "systemBlue"),
                            borderRadius: BorderRadius.circular(50),
                            minSize: 70,
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              _recordAudio();
                            },
                            child: Icon(
                              isRecording
                                  ? CupertinoIcons.stop_fill
                                  : CupertinoIcons.mic_fill,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: TextFont(
                              text: isRecording ? "Recording" : "",
                              fontSize: 13,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 15),
                    recordingPath == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: CupertinoButton(
                              color: getColor(context, "lightDark"),
                              borderRadius: BorderRadius.circular(50),
                              minSize: 50,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                _deleteAudio();
                              },
                              child: Icon(
                                CupertinoIcons.delete,
                                color: getColor(context, "black"),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    borderRadius: BorderRadius.circular(10),
                    minSize: 70,
                    padding: EdgeInsets.zero,
                    color: getColor(context, "lightDark"),
                    onPressed: () {
                      if (recordingPath != null) _deleteAudio();
                      Navigator.pop(context);
                    },
                    child: Icon(
                      CupertinoIcons.back,
                      color: getColor(context, "black"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFont(
                      text: "${widget.responseId} / ${responses.keys.length}",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Opacity(
                    opacity: recordingPath == null ? 0.2 : 1,
                    child: CupertinoButton(
                      borderRadius: BorderRadius.circular(10),
                      minSize: 70,
                      padding: EdgeInsets.zero,
                      color: getColor(context, "lightDark"),
                      onPressed: () {
                        _nextId();
                      },
                      child: Icon(
                        CupertinoIcons.forward,
                        color: getColor(context, "black"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showCupertinoSnackBar({
  required BuildContext context,
  required String message,
  int duration = 3000,
}) {
  const animationDuration = 200;
  final overlayEntry = OverlayEntry(
    builder: (context) => _CupertinoSnackBar(
      message: message,
      animationDuration: animationDuration,
      waitDuration: duration,
    ),
  );
  Future.delayed(
    Duration(milliseconds: duration + 2 * animationDuration),
    overlayEntry.remove,
  );
  Overlay.of(Navigator.of(context).context).insert(overlayEntry);
}

class _CupertinoSnackBar extends StatefulWidget {
  final String message;
  final int animationDuration;
  final int waitDuration;

  const _CupertinoSnackBar({
    Key? key,
    required this.message,
    required this.animationDuration,
    required this.waitDuration,
  }) : super(key: key);

  @override
  State<_CupertinoSnackBar> createState() => _CupertinoSnackBarState();
}

class _CupertinoSnackBarState extends State<_CupertinoSnackBar> {
  bool show = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        show = true;
      });
    });
    Future.delayed(
      Duration(
        milliseconds: widget.waitDuration,
      ),
      () {
        if (mounted) {
          setState(() => show = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      top: show ? 8 + MediaQuery.of(context).viewPadding.top : -100,
      left: 20,
      right: 20,
      curve: show ? Curves.linearToEaseOut : Curves.easeInToLinear,
      duration: Duration(milliseconds: widget.animationDuration),
      child: Material(
        child: CupertinoPopupSurface(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            child: TextFont(
              text: widget.message,
              textAlign: TextAlign.center,
              fontSize: 15,
              maxLines: 100,
              textColor: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
