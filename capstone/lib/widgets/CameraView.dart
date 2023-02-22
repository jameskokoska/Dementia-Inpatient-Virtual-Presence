import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

List<CameraDescription> cameras = [];

class CameraView extends StatefulWidget {
  const CameraView({required this.isFacingFront, Key? key}) : super(key: key);
  final bool isFacingFront;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraController controller;
  late bool currentIsFacingFront = widget.isFacingFront;

  @override
  void initState() {
    super.initState();
    _initCamera(widget.isFacingFront);
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    if (widget.isFacingFront != currentIsFacingFront &&
        controller.value.isInitialized) {
      _initCamera(widget.isFacingFront);
      currentIsFacingFront = widget.isFacingFront;
    }
  }

  Future<void> _initCamera(bool isFacingFront) async {
    int cameraIndex;
    if (isFacingFront) {
      cameraIndex = cameras.indexOf(cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front));
    } else {
      cameraIndex = 0;
    }
    controller = CameraController(cameras[cameraIndex], ResolutionPreset.max);

    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            debugPrint('User denied camera access.');
            break;
          default:
            debugPrint('Handle other errors.');
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return CameraPreview(controller);
  }
}
