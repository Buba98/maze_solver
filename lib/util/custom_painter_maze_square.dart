import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'directions.dart';

class CustomPainterMazeSquare extends CustomPainter {
  final Color colorForeground, colorBackground, colorBackgroundCursor;
  final List<Directions> directions;
  final bool cursor;

  CustomPainterMazeSquare({
    this.colorForeground = Colors.teal,
    this.colorBackground = Colors.orange,
    this.cursor = false,
    this.colorBackgroundCursor = Colors.blue,
    required this.directions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paintBackground = Paint()
      ..color = colorBackground
      ..style = PaintingStyle.fill;

    canvas.drawRect(
        Rect.fromLTRB(0, 0, size.width, size.height), paintBackground);

    Paint paintForeground = Paint()
      ..color = colorForeground
      ..strokeWidth = size.width * .1;

    for (Directions direction in directions)
      switch (direction) {
        case Directions.UP:
          Offset start = Offset(0, 0);
          Offset end = Offset(size.width, 0);
          canvas.drawLine(start, end, paintForeground);
          break;
        case Directions.DOWN:
          Offset start = Offset(0, size.height);
          Offset end = Offset(size.width, size.height);
          canvas.drawLine(start, end, paintForeground);
          break;
        case Directions.LEFT:
          Offset start = Offset(0, 0);
          Offset end = Offset(0, size.height);
          canvas.drawLine(start, end, paintForeground);
          break;
        case Directions.RIGHT:
          Offset start = Offset(size.width, 0);
          Offset end = Offset(size.width, size.height);
          canvas.drawLine(start, end, paintForeground);
          break;
      }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
