import "package:flutter/material.dart";

class BoundingboxWidget extends StatelessWidget {
  final Map<String, dynamic> box;
  final VoidCallback onTap;

  const BoundingboxWidget({
    Key? key,
    required this.box,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: box['left']!,
      top: box['top']!,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: box['width']!,
          height: box['height']!,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(255, 211, 53, 53),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
