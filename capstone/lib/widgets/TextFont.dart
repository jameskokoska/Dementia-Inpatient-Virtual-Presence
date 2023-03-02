import 'package:capstone/colors.dart';
import 'package:flutter/material.dart';

class TextFont extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? textColor;
  final TextAlign textAlign;
  final int? maxLines;
  final bool fixParagraphMargin;
  final double? minFontSize;
  final double? maxFontSize;
  final TextOverflow? overflow;
  final bool? softWrap;

  const TextFont({
    Key? key,
    required this.text,
    this.fontSize = 20,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.left,
    this.textColor,
    this.maxLines,
    this.fixParagraphMargin = false,
    this.maxFontSize,
    this.minFontSize,
    this.overflow,
    this.softWrap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color? finalTextColor;
    if (textColor == null) {
      finalTextColor = getColor(context, "black");
    } else {
      finalTextColor = textColor;
    }
    final TextStyle textStyle = TextStyle(
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: finalTextColor,
      decoration: TextDecoration.underline,
      decorationStyle: TextDecorationStyle.double,
      decorationColor: const Color(0x00FFFFFF),
      overflow: overflow,
    );
    return Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow ?? TextOverflow.ellipsis,
      style: textStyle,
      softWrap: softWrap,
    );
  }
}

class HintText extends StatelessWidget {
  const HintText({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Flexible(
        child: TextFont(
          text: text,
          fontSize: 12,
          maxLines: 5,
          textAlign: TextAlign.center,
          textColor: getColor(context, "black").withOpacity(0.3),
        ),
      ),
    );
  }
}
