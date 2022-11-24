import 'package:capstone/colors.dart';
import 'package:capstone/database/tables.dart';
import 'package:capstone/struct/databaseGlobal.dart';
import 'package:capstone/widgets/TextFont.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

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
                SizedBox(height: 15),
                CupertinoButton.filled(
                  child: Text("Add User"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      database.createOrUpdateUser(
                        User(
                          id: DateTime.now().millisecondsSinceEpoch,
                          name: name,
                          description: description,
                        ),
                      );
                      // Navigator.pop(context);
                      Navigator.push(context, CupertinoPageRoute<Widget>(
                          builder: (BuildContext context) {
                        return RecordResponse();
                      }));
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
  const RecordResponse({super.key});

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

  void _recordAudio() async {
    if (isRecording) {
      String? path = await record.stop();
      print(path);
      setState(() {
        isRecording = false;
        recordingPath = path;
      });
      showCupertinoSnackBar(context: context, message: path ?? "");
    } else {
      await record.start();
      bool status = await record.isRecording();
      setState(() {
        isRecording = status;
      });
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
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: TextFont(
                          text: "The time is 1:59pm",
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              ],
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
                      Navigator.pop(context);
                    },
                    child: Icon(
                      CupertinoIcons.back,
                      color: getColor(context, "black"),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: CupertinoButton(
                          color: getColor(context, "systemBlue"),
                          borderRadius: BorderRadius.circular(50),
                          minSize: 70,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            _recordAudio();
                          },
                          child: Icon(
                            isRecording
                                ? CupertinoIcons.mic_fill
                                : CupertinoIcons.mic,
                            color: getColor(context, "black"),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: TextFont(
                            text: isRecording ? "Recording..." : "",
                            fontSize: 15,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                  Opacity(
                    opacity: recordingPath == null ? 0.2 : 1,
                    child: CupertinoButton(
                      borderRadius: BorderRadius.circular(10),
                      minSize: 70,
                      padding: EdgeInsets.zero,
                      color: getColor(context, "lightDark"),
                      onPressed: () {
                        if (recordingPath == null) {
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text(
                                  'Please record a response before proceeding'),
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
    );
  }
}
