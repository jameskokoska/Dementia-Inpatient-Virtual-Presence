import 'dart:io';

import 'package:camera/camera.dart';
import 'package:capstone/colors.dart';
import 'package:capstone/database/tables.dart';
import 'package:capstone/pages/Face%20Scanner.dart';
import 'package:capstone/pages/PlayBackVideo.dart';
import 'package:capstone/pages/RecordCamera.dart';
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
                    header: const Text('Details'),
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
                        return RecordResponse(
                          responseId: "0",
                          user: User(
                            id: DateTime.now().millisecondsSinceEpoch,
                            name: name,
                            description: description,
                            recordings: {},
                          ),
                        );
                        return FaceScannerPage(
                          user: User(
                            id: DateTime.now().millisecondsSinceEpoch,
                            name: name,
                            description: description,
                            recordings: {},
                          ),
                        );
                      }));
                    }
                  },
                ),
                // CupertinoButton.filled(
                //   child: const Text("Record Camera"),
                //   onPressed: () {
                //     Navigator.push(context, CupertinoPageRoute<Widget>(
                //         builder: (BuildContext context) {
                //       return RecordCamera();
                //     }));
                //   },
                // ),
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
  bool _isLoading = true;
  bool _isRecording = false;
  String? recordingPath;
  late CameraController _cameraController;
  late String currentResponseId = widget.responseId;
  late User currentUser = widget.user;

  @override
  void initState() {
    _initCamera();
    super.initState();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
    _cameraController = CameraController(front, ResolutionPreset.max);
    await _cameraController.initialize();
    setState(() => _isLoading = false);
  }

  Future<void> _recordVideo() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      setState(() => _isRecording = false);
      setState(() {
        recordingPath = file.path;
        _isRecording = false;
      });
    } else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  Future<void> _deleteVideo() async {
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
    await _deleteVideo();
    await _recordVideo();
  }

  void _prevId() async {
    String? prevId = determinePrevId(currentResponseId);
    if (prevId == null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      if (recordingPath != null) await _deleteVideo();
      if (_isRecording) await _recordVideo();
      User user = currentUser.copyWith(recordings: {
        ...currentUser.recordings,
        currentResponseId: recordingPath ?? ""
      });
      setState(() {
        currentResponseId = prevId;
        _isRecording = false;
        recordingPath = null;
        currentUser = user;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          recordingPath = currentUser.recordings[prevId];
        });
      });
    }
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
      String? nextId = determineNextId(currentResponseId);
      if (nextId == null) {
        User user = currentUser.copyWith(recordings: {
          ...currentUser.recordings,
          currentResponseId: recordingPath ?? ""
        });
        setState(() {
          currentResponseId = "0";
          _isRecording = false;
          recordingPath = null;
          currentUser = user;
        });
        await database.createOrUpdateUser(
          currentUser,
        );
        // we are done getting all the audio recordings
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        User user = currentUser.copyWith(recordings: {
          ...currentUser.recordings,
          currentResponseId: recordingPath ?? ""
        });
        setState(() {
          currentResponseId = nextId;
          _isRecording = false;
          recordingPath = null;
          currentUser = user;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (recordingPath != null) _deleteVideo();
        return true;
      },
      child: CupertinoPageScaffold(
        child: Stack(
          children: [
            _isLoading
                ? Container(
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : recordingPath != null
                    ? PlayBackVideo(
                        filePath: recordingPath!,
                        isLooping: true,
                      )
                    : Stack(
                        children: [
                          CameraPreview(_cameraController),
                          Transform.translate(
                            offset: Offset(0, -50),
                            child: Transform.scale(
                              scale: 1,
                              child: Opacity(
                                opacity: 0.5,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image:
                                          AssetImage('assets/PersonOutline.png')
                                              as ImageProvider,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Center(
                      child: TextFont(
                        text: "Please say:",
                        fontSize: 15,
                        textColor: getColor(context, "gray"),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: TextFont(
                          text: responses[currentResponseId] ?? "",
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          textAlign: TextAlign.center,
                          maxLines: 50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
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
                                color: _isRecording
                                    ? getColor(context, "red")
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                minSize: 70,
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  if (recordingPath == null) {
                                    _recordVideo();
                                  } else {
                                    _restartRecording();
                                  }
                                },
                                child: Icon(
                                  _isRecording
                                      ? CupertinoIcons.stop_fill
                                      : CupertinoIcons.circle_filled,
                                  color: _isRecording
                                      ? Colors.white
                                      : getColor(context, "red"),
                                ),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: TextFont(
                                  text: _isRecording ? "Recording" : "",
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
                                    _deleteVideo();
                                  },
                                  child: Icon(
                                    CupertinoIcons.delete,
                                    color: getColor(context, "black"),
                                  ),
                                ),
                              ),
                      ],
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
                      _prevId();
                    },
                    child: Icon(
                      CupertinoIcons.back,
                      color: getColor(context, "black"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFont(
                      text: "${currentResponseId} / ${responses.keys.length}",
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
  Overlay.of(Navigator.of(context).context)!.insert(overlayEntry);
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
