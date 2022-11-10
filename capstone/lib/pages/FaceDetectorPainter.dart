import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.faces, this.absoluteImageSize, this.rotation);

  final List<Face> faces;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white;

    for (final Face face in faces) {
      canvas.drawRect(
        Rect.fromLTRB(
          translateX(face.boundingBox.left, rotation, size, absoluteImageSize),
          translateY(face.boundingBox.top, rotation, size, absoluteImageSize),
          translateX(face.boundingBox.right, rotation, size, absoluteImageSize),
          translateY(
              face.boundingBox.bottom, rotation, size, absoluteImageSize),
        ),
        paint,
      );

      void paintContour(FaceContourType type, {Color color = Colors.red}) {
        final faceContour = face.contours[type];
        if (faceContour?.points != null) {
          canvas.drawPoints(
            PointMode.polygon,
            faceContour!.points
                .map((point) => Offset(
                      translateX(point.x.toDouble(), rotation, size,
                                  absoluteImageSize) *
                              1.25 -
                          45,
                      translateY(point.y.toDouble(), rotation, size,
                              absoluteImageSize) *
                          1,
                    ))
                .toList(),
            Paint()
              ..strokeWidth = 2.0
              ..color = color,
          );

          for (final Point point in faceContour.points) {
            canvas.drawCircle(
              Offset(
                translateX(point.x.toDouble(), rotation, size,
                            absoluteImageSize) *
                        1.25 -
                    45,
                translateY(
                        point.y.toDouble(), rotation, size, absoluteImageSize) *
                    1,
              ),
              2,
              paint
                ..color = color
                ..style = PaintingStyle.fill,
            );
          }
        }
      }

      paintContour(FaceContourType.face, color: Color(0xFF1C629B));
      paintContour(FaceContourType.leftEyebrowTop,
          color: Color.fromRGBO(197, 114, 36, 1));
      paintContour(FaceContourType.leftEyebrowBottom, color: Color(0xFFD4D23D));
      paintContour(FaceContourType.rightEyebrowTop,
          color: Color.fromRGBO(197, 114, 36, 1));
      paintContour(FaceContourType.rightEyebrowBottom,
          color: Color(0xFFD4D23D));
      paintContour(FaceContourType.leftEye, color: Color(0xFF24C567));
      paintContour(FaceContourType.rightEye, color: Color(0xFF24C567));
      paintContour(FaceContourType.upperLipTop, color: Color(0xFFDB94DD));
      paintContour(FaceContourType.upperLipBottom, color: Color(0xFFC024C5));
      paintContour(FaceContourType.lowerLipTop, color: Color(0xFFDB94DD));
      paintContour(FaceContourType.lowerLipBottom, color: Color(0xFFC024C5));
      paintContour(FaceContourType.noseBridge);
      paintContour(FaceContourType.noseBottom);
      paintContour(FaceContourType.leftCheek);
      paintContour(FaceContourType.rightCheek);
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.faces != faces;
  }
}

double translateX(
    double x, InputImageRotation rotation, Size size, Size absoluteImageSize) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return x *
          size.width /
          (Platform.isIOS ? absoluteImageSize.width : absoluteImageSize.height);
    case InputImageRotation.rotation270deg:
      return size.width -
          x *
              size.width /
              (Platform.isIOS
                  ? absoluteImageSize.width
                  : absoluteImageSize.height);
    default:
      return x * size.width / absoluteImageSize.width;
  }
}

double translateY(
    double y, InputImageRotation rotation, Size size, Size absoluteImageSize) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      return y *
          size.height /
          (Platform.isIOS ? absoluteImageSize.height : absoluteImageSize.width);
    default:
      return y * size.height / absoluteImageSize.height;
  }
}
