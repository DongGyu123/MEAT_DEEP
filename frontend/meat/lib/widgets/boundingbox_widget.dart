import "package:flutter/material.dart";

class BoundingboxWidget extends StatelessWidget {
  final Map<String, dynamic> box;
  final VoidCallback onTap;
  final bool isSelected;

  const BoundingboxWidget({
    Key? key,
    required this.box,
    required this.onTap,
    required this.isSelected,
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
              color: isSelected
                  ? Color.fromARGB(255, 250, 2, 2)
                  : Color.fromARGB(255, 162, 4, 4),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
