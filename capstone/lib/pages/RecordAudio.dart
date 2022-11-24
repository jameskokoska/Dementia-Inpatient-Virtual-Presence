import 'dart:async';
import 'dart:typed_data';
import 'package:speech_to_text/speech_to_text.dart' as stt;
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
  stt.SpeechToText speech = stt.SpeechToText();
  bool isRecording = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () async {
        if (!isRecording) {
          setState(() {
            isRecording = true;
          });

          bool available = await speech.initialize(
            onStatus: (status) {
              print(status);
            },
          );
          if (available) {
            speech.listen(
              onResult: (result) {
                print(result.recognizedWords);
              },
              listenFor: const Duration(milliseconds: 10000),
            );
            for (int i = 0; i < 5000; i++) {
              await Future.delayed(Duration(milliseconds: 100), () {
                speech.listen(
                  onResult: (result) {
                    print(result.recognizedWords);
                  },
                  partialResults: true,
                );
              });
            }
          } else {
            print("The user has denied the use of speech recognition.");
          }
        } else {
          speech.stop();
          setState(() {
            isRecording = false;
          });
        }
      },
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(CupertinoIcons.mic_fill),
            Text(isRecording ? "Stop" : "Record Audio"),
          ],
        ),
      ),
    );
  }
}
