import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mic_stream/mic_stream.dart';

class RecordAudio extends StatefulWidget {
  const RecordAudio({super.key});

  @override
  State<RecordAudio> createState() => _RecordAudioState();
}

class _RecordAudioState extends State<RecordAudio> {
  late StreamSubscription<List<int>> listener;
  bool isRecording = false;
  double averageSample = 0.0;
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () async {
        if (!isRecording) {
          setState(() {
            isRecording = true;
          });

          Stream<Uint8List>? stream =
              await MicStream.microphone(sampleRate: 44100);
          listener = stream!.listen((samples) {
            print(samples);
            setState(
              () {
                averageSample =
                    samples.reduce((a, b) => a + b) / samples.length;
              },
            );
          });
        } else {
          setState(() {
            isRecording = false;
          });
          listener.cancel();
        }
      },
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(CupertinoIcons.mic_fill),
            Text(isRecording ? "Stop" : "Record Audio"),
            Text(averageSample.toString()),
          ],
        ),
      ),
    );
  }
}
