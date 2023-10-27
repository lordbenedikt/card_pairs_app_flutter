import 'package:flutter/material.dart';

class CustomGrid extends StatelessWidget {
  const CustomGrid(
      {super.key,
      required this.cols,
      required this.rows,
      required this.children});

  final int cols;
  final int rows;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < rows; i++)
          Expanded(
            child: Row(children: [
              for (var j = 0; j < cols; j++)
                Expanded(
                    child: (cols * i + j < children.length)
                        ? children[cols * i + j]
                        : Container())
            ]),
          ),
      ],
    );
  }
}
