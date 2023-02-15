import 'package:capstone/widgets/TextFont.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
