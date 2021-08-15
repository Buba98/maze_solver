import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'directions.dart';

class CustomPainterMazeSquare extends CustomPainter {
  final Color colorForeground,
      colorBackground,
      colorBackgroundCursor,
      colorCheckpoint;
  final List<Directions> directions;
  final bool cursor;
  final bool cornerCorrectionUpLeft;
  final bool hasPlayer;
  final bool isStart;
  final bool isEnd;

  CustomPainterMazeSquare({
    this.colorCheckpoint = Colors.red,
    this.isStart = false,
    this.isEnd = false,
    this.hasPlayer = false,
    this.colorForeground = Colors.teal,
    this.colorBackground = Colors.orange,
    this.cursor = false,
    this.colorBackgroundCursor = Colors.blue,
    required this.directions,
    this.cornerCorrectionUpLeft = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paintBackground = Paint()
      ..color = cursor
          ? colorBackgroundCursor
          : isStart || isEnd
              ? colorCheckpoint
              : colorBackground
      ..style = PaintingStyle.fill;

    canvas.drawRect(
        Rect.fromLTRB(0, 0, size.width, size.height), paintBackground);

    Paint paintForeground = Paint()
      ..color = colorForeground
      ..strokeWidth = size.width * .1;

    for (Directions direction in directions)
      switch (direction) {
        case Directions.UP:
          Offset start = Offset(0, size.width * .05);
          Offset end = Offset(size.width, size.width * .05);
          canvas.drawLine(start, end, paintForeground);
          break;
        case Directions.DOWN:
          Offset start = Offset(0, size.height - size.width * .05);
          Offset end = Offset(size.width, size.height - size.width * .05);
          canvas.drawLine(start, end, paintForeground);
          break;
        case Directions.LEFT:
          Offset start = Offset(size.width * .05, 0);
          Offset end = Offset(size.width * .05, size.height);
          canvas.drawLine(start, end, paintForeground);
          break;
        case Directions.RIGHT:
          Offset start = Offset(size.width - size.width * .05, 0);
          Offset end = Offset(size.width - size.width * .05, size.height);
          canvas.drawLine(start, end, paintForeground);
          break;
      }

    if (cornerCorrectionUpLeft) {
      Offset start = Offset(0, size.width * .05);
      Offset end = Offset(size.width * .1, size.width * .05);
      canvas.drawLine(start, end, paintForeground);
    }

    if (hasPlayer) {
      final icon = Icons.accessibility_new_outlined;

      var builder = ParagraphBuilder(ParagraphStyle(
          fontFamily: icon.fontFamily, fontSize: size.width * .4))
        ..addText(String.fromCharCode(icon.codePoint));
      var para = builder.build();
      para.layout(const ParagraphConstraints(width: 60));
      canvas.drawParagraph(para, Offset(size.width * .3, size.width * .3));
    }

    if (isStart) {
      final icon = Icons.play_arrow;

      var builder = ParagraphBuilder(ParagraphStyle(
          fontFamily: icon.fontFamily, fontSize: size.width * .1))
        ..addText(String.fromCharCode(icon.codePoint));
      var para = builder.build();
      para.layout(const ParagraphConstraints(width: 60));
      canvas.drawParagraph(para, Offset(size.width * .1, size.width * .1));
    }

    if (isEnd) {
      final icon = Icons.stop;

      var builder = ParagraphBuilder(ParagraphStyle(
          fontFamily: icon.fontFamily, fontSize: size.width * .1))
        ..addText(String.fromCharCode(icon.codePoint));
      var para = builder.build();
      para.layout(const ParagraphConstraints(width: 60));
      canvas.drawParagraph(para, Offset(size.width * .1, size.width * .1));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
