import 'dart:io';

import 'package:camera/camera.dart';
import 'package:capstone/colors.dart';
import 'package:capstone/database/tables.dart';
import 'package:capstone/pages/CreateUserPage.dart';
import 'package:capstone/pages/Face%20Scanner.dart';
import 'package:capstone/pages/PlayBackVideo.dart';
import 'package:capstone/pages/RecordCamera.dart';
import 'package:capstone/pages/RecordResponsesList.dart';
import 'package:capstone/struct/databaseGlobal.dart';
import 'package:capstone/widgets/TextFont.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

import '../widgets/Snackbar.dart';

class RecordResponse extends StatefulWidget {
  const RecordResponse({
    required this.responseId,
    required this.response,
    required this.user,
    super.key,
  });
  final String responseId;
  final String response;
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
      deleteVideo(context, recordingPath!);
      setState(() {
        recordingPath = null;
      });
      return;
    } catch (e) {
      showCupertinoSnackBar(context: context, message: e.toString());
      return;
    }
  }

  Future<void> _saveNewRecording() async {
    User user = currentUser.copyWith(recordings: {
      ...currentUser.recordings,
      currentResponseId: recordingPath ?? ""
    });
    await database.createOrUpdateUser(user);
    Navigator.pop(context);
  }

  void _restartRecording() async {
    await _deleteVideo();
    await _recordVideo();
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
                    color: getColor(context, "white"),
                    child: const Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  )
                : recordingPath != null
                    ? PlayBackVideo(filePath: recordingPath!)
                    : CameraPreview(_cameraController),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Center(
                      child: HintText(
                        text: "Please say:",
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: TextFont(
                          text: widget.response,
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
                            : CupertinoButton(
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
                        const SizedBox(width: 15),
                        Center(
                          child: CupertinoButton(
                            color: recordingPath != null
                                ? getColor(context, "completeGreen")
                                : _isRecording
                                    ? getColor(context, "red")
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(50),
                            minSize: 70,
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              if (recordingPath != null) {
                                _saveNewRecording();
                              } else if (recordingPath == null) {
                                _recordVideo();
                              } else {
                                _restartRecording();
                              }
                            },
                            child: Icon(
                              recordingPath != null
                                  ? CupertinoIcons.check_mark
                                  : _isRecording
                                      ? CupertinoIcons.stop_fill
                                      : CupertinoIcons.circle_filled,
                              color: recordingPath != null
                                  ? Colors.white
                                  : _isRecording
                                      ? Colors.white
                                      : getColor(context, "red"),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        recordingPath == null
                            ? const SizedBox.shrink()
                            : CupertinoButton(
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> deleteVideo(context, String recordingPath) async {
  if (context == null) {
    final file = File(recordingPath);
    await file.delete();
    print("Deleted" + recordingPath);
    return true;
  } else {
    bool result = await confirmDelete(context, "Delete recording?");
    if (result == true) {
      final file = File(recordingPath);
      await file.delete();
      showCupertinoSnackBar(context: context, message: "Deleted recording.");
      print("Deleted" + recordingPath);
      return true;
    } else {
      return false;
    }
  }
}

Future<bool> confirmDelete(context, String message) async {
  bool result = await showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(message),
      actions: [
        CupertinoDialogAction(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return result;
}
