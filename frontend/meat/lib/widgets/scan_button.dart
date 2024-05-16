import 'package:flutter/material.dart';

class ScanButton extends StatelessWidget {
  final Future<void> Function() onPressed;
  final String buttonText;
  final IconData iconData;

  const ScanButton({
    Key? key,
    required this.onPressed,
    required this.buttonText,
    required this.iconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15), //45, 5
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.all(
            Radius.circular(100),
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(255, 210, 46, 0.578),
              spreadRadius: 3,
              blurRadius: 10,
              offset: Offset(0, 4.5),
            ),
          ],
        ),
        child: SizedBox(
          // width: 185,
          // height: 60,
          width: 220,
          height: 50,
          child: FloatingActionButton(
            onPressed: onPressed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  iconData,
                  size: 20,
                  color: const Color.fromARGB(255, 83, 83, 83),
                ),
                const SizedBox(width: 10),
                Text(
                  buttonText,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1),
                  selectionColor: const Color.fromARGB(255, 83, 83, 83),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
