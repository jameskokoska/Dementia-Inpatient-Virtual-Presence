import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayBackVideo extends StatefulWidget {
  final String filePath;
  final bool isLooping;
  final Function? onFinishPlayback;
  final double volume;
  final bool initializeFirst;
  const PlayBackVideo({
    Key? key,
    required this.filePath,
    required this.isLooping,
    this.onFinishPlayback,
    this.volume = 1,
    this.initializeFirst = true,
  }) : super(key: key);

  @override
  _PlayBackVideoState createState() => _PlayBackVideoState();
}

class _PlayBackVideoState extends State<PlayBackVideo> {
  late VideoPlayerController _videoPlayerController;

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initializeFirst == false) {
      _videoPlayerController = VideoPlayerController.file(File(widget.filePath),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
        ..addListener(() {
          if (!_videoPlayerController.value.isPlaying &&
              _videoPlayerController.value.position.inSeconds >=
                  _videoPlayerController.value.duration.inSeconds) {
            if (widget.onFinishPlayback != null) widget.onFinishPlayback!();
          }
        })
        ..setLooping(widget.isLooping)
        ..initialize()
        ..setVolume(widget.volume)
        ..play();
    }
  }

  Future _initVideoPlayer() async {
    if (widget.initializeFirst == true) {
      _videoPlayerController = VideoPlayerController.file(File(widget.filePath))
        ..addListener(() {
          if (!_videoPlayerController.value.isPlaying &&
              _videoPlayerController.value.position.inSeconds >=
                  _videoPlayerController.value.duration.inSeconds) {
            if (widget.onFinishPlayback != null) widget.onFinishPlayback!();
          }
        });
      await _videoPlayerController.initialize();
      await _videoPlayerController.setLooping(widget.isLooping);
      await _videoPlayerController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initializeFirst == false) {
      return CupertinoPageScaffold(
        child: AspectRatio(
          aspectRatio: _videoPlayerController.value.aspectRatio == 1
              ? 9 / 16
              : _videoPlayerController.value.aspectRatio,
          child: VideoPlayer(_videoPlayerController),
        ),
      );
    }
    return CupertinoPageScaffold(
      child: FutureBuilder(
        future: _initVideoPlayer(),
        builder: (context, state) {
          if (state.connectionState == ConnectionState.waiting) {
            return Container();
          } else {
            return AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController),
            );
          }
        },
      ),
    );
  }
}
