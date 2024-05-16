import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/take_picture_screen.dart';
import 'utilities/theme_data.dart';

Future<void> main() async {
  // camera 초기화
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  // run app
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      // 홈 화면 : TakePictureScreen
      home: TakePictureScreen(camera: firstCamera),
    ),
  );
}
