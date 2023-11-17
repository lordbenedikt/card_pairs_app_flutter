import 'dart:ui';

import 'package:flutter/material.dart';

class CustomGrid extends StatefulWidget {
  const CustomGrid({
    super.key,
    required this.cols,
    required this.rows,
    required this.children,
  });

  final int cols;
  final int rows;
  final List<Widget> children;

  @override
  State<CustomGrid> createState() => _CustomGridState();
}

class _CustomGridState extends State<CustomGrid> {
  Orientation? _startOrientation;

  @override
  Widget build(BuildContext context) {
    _startOrientation ??= MediaQuery.of(context).orientation;
    final bool orientationChanged =
        MediaQuery.of(context).orientation != _startOrientation;
    int actualCols = orientationChanged ? widget.rows : widget.cols;
    int actualRows = orientationChanged ? widget.cols : widget.rows;
    return Column(
      children: [
        for (var i = 0; i < actualRows; i++)
          Expanded(
            child: Row(children: [
              for (var j = 0; j < actualCols; j++)
                Expanded(
                  child: (actualCols * i + j < widget.children.length)
                      ? widget.children[actualCols * i + j]
                      : Container(),
                )
            ]),
          ),
      ],
    );
  }
}
