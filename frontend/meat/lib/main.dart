import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // camera 초기화
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  // run app
  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      // 표시되는 홈 화면 : TakePictureScreen 위젯
      home: TakePictureScreen(
        camera: firstCamera,
      ),
    ),
  );
}

// TakePictureScreen 위젯 : 카메라 화면 관리
class TakePictureScreen extends StatefulWidget {
  // main에서 camera: firstCamera 받아옴
  const TakePictureScreen({
    super.key,
    required this.camera,
  });
  final CameraDescription camera; // 받아온 camera

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  // TakePictureScreen의 state 관리
  /*
    CameraController : 카메라 하드웨어에 대한 액세스를 관리하고, 
    카메라의 초기화, 미리보기 설정, 사진 촬영 및 기타 카메라 관련 기능을 수행하는 데 사용
   */
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // CameraController create 및 초기화
    _controller = CameraController(
      widget.camera, // 받아온 camera를 state로 관리
      ResolutionPreset.medium, // camera 해상도 설정
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // 화면 위젯 사용되지 않을 때, camera controller 리소스도 해제
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // 카메라 미리보기 화면
      body: FutureBuilder<void>(
        future: _initializeControllerFuture, // 비동기작업 기다리는 대상 객체
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // 비동기작업 완료되면
            // CameraController의 CameraPreview 사용
            return CameraPreview(_controller);
          } else {
            // 비동기작업 완료되지 않았으면
            // 즉 CameraPreview 없을 때 로딩 화면
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      // 사진 촬영 버튼
      floatingActionButton: FloatingActionButton(
        // 버튼 눌렸을 때 수행 작업
        onPressed: () async {
          try {
            await _initializeControllerFuture; // 카메라 초기화 ensure
            // CameraController의 takePicture() 사용
            // 사진 촬영 결과 image에 저장
            final image = await _controller.takePicture();

            // 위젯 mounted 안되었을 때 버튼 안보이게 (화면 전환 시 등)
            if (!context.mounted) return;
            // 화면 전환
            await Navigator.of(context).push(
              MaterialPageRoute(
                // DisplayPictureScreen 화면으로
                builder: (context) => DisplayPictureScreen(
                  imagePath: image.path, // 촬영한 image의 path 전달
                ),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt), // 카메라 아이콘
      ),
    );
  }
}

// DisplayPictureScreen : 촬영된 사진 보여주는 화면
class DisplayPictureScreen extends StatelessWidget {
  // 촬영된 사진 path를 imagePath로 받아옴
  final String imagePath;
  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // 촬영된 사진 표시
      body: Image.file(File(imagePath)),
    );
  }
}
