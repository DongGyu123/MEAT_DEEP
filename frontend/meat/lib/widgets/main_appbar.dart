import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget {
  const MainAppBar({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Center(
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 1.1),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0, // 상단 바 그림자 제거
      toolbarHeight: 44.0,
    );
  }
}
