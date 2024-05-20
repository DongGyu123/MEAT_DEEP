import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color.fromARGB(255, 60, 60, 60),
      onPrimary: Color.fromARGB(255, 255, 255, 255),
      primaryContainer: Color.fromRGBO(255, 210, 46, 1),
      onPrimaryContainer: Color.fromARGB(255, 83, 83, 83),
      secondary: Color(0xff03dac6),
      onSecondary: Colors.black,
      secondaryContainer: Color(0xff03dac6),
      onSecondaryContainer: Colors.black,
      error: Color(0xffb00020),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Color.fromARGB(255, 255, 255, 255),
      surface: Colors.white,
      onSurface: Colors.black,
    ),
    textTheme: Typography.material2018().black,
  );
}
// ThemeData appTheme() {
//   return ThemeData(
//     useMaterial3: true,
//     colorScheme: const ColorScheme(
//       brightness: Brightness.light,
//       primary: Color.fromARGB(255, 60, 60, 60),
//       onPrimary: Color.fromARGB(255, 255, 255, 255),
//       primaryContainer: Color.fromRGBO(255, 210, 46, 1),
//       onPrimaryContainer: Color.fromARGB(255, 83, 83, 83),
//       secondary: Color(0xff03dac6),
//       onSecondary: Colors.black,
//       secondaryContainer: Color(0xff03dac6),
//       onSecondaryContainer: Colors.black,
//       error: Color(0xffb00020),
//       onError: Colors.white,
//       background: Colors.white,
//       onBackground: Color.fromARGB(255, 255, 255, 255),
//       surface: Colors.white,
//       onSurface: Colors.black,
//     ),
//     textTheme: GoogleFonts.interTextTheme().copyWith(
//       // 기본 텍스트 스타일 지정
//       bodyText2: TextStyle( // bodyText2 속성 정의
//         fontSize: 16.0, // 원하는 폰트 크기
//         fontWeight: FontWeight.normal, // 원하는 폰트 두께
//         // 기타 원하는 속성 추가
//       ),
//     ),
//   );
// }