import 'package:camera/camera.dart';
import 'package:capstone/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:capstone/pages/PlayBackVideo.dart';

class RecordCamera extends StatefulWidget {
  const RecordCamera({Key? key}) : super(key: key);

  @override
  _RecordCameraState createState() => _RecordCameraState();
}

class _RecordCameraState extends State<RecordCamera> {
  bool _isLoading = true;
  bool _isRecording = false;
  late CameraController _cameraController;

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

  _recordVideo() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      setState(() => _isRecording = false);
      final route = CupertinoPageRoute<Widget>(builder: (BuildContext context) {
        return PlayBackVideo(
          filePath: file.path,
          isLooping: true,
        );
      });
      Navigator.push(context, route);
    } else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CameraPreview(_cameraController),
            Padding(
              padding: const EdgeInsets.all(25),
              child: CupertinoButton(
                color: _isRecording
                    ? getColor(context, "red")
                    : getColor(context, "systemBlue"),
                borderRadius: BorderRadius.circular(50),
                minSize: 70,
                padding: EdgeInsets.zero,
                onPressed: () {
                  _recordVideo();
                },
                child: Icon(
                  _isRecording
                      ? CupertinoIcons.stop_fill
                      : CupertinoIcons.mic_fill,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
