import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:meat/screens/display_picture_screen.dart';
import 'package:meat/widgets/main_appbar.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/scan_button.dart';
import '../providers/image_upload.dart';

// TakePictureScreen : 카메라 화면 관리
class TakePictureScreen extends StatefulWidget {
  // main에서 camera: firstCamera 받아옴
  const TakePictureScreen({super.key, required this.camera});
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
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
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
      body: Stack(children: <Widget>[
        // 카메라 미리보기 화면
        Positioned(
          top: 63,
          left: 0,
          right: 0,
          child: CameraPreviewWidget(
              controller: _controller,
              initializeControllerFuture: _initializeControllerFuture),
        ),
        // 설명 텍스트
        const Positioned(
            top: 95,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Scanner will determine your meat doneness',
                style: TextStyle(fontSize: 12),
              ),
            )),
        // 상단 바
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: MainAppBar(title: 'meat checker'),
        )
      ]),
      // 사진 촬영 버튼
      floatingActionButton: ScanButton(
        // 버튼 눌렸을 때 수행 작업
        onPressed: () async {
          try {
            await _initializeControllerFuture; // 카메라 초기화 ensure
            // CameraController의 takePicture() 사용
            // 사진 촬영 결과 image에 저장
            final image = await _controller.takePicture();

            // 위젯 mounted 안되었을 때 버튼 안보이게 (화면 전환 시 등)
            if (!context.mounted) return;
            // uploadImage 함수 호출하여 이미지 업로드
            // -> 분석 결과 Bounding Box 정보 받기
            // final boundingBoxes = await uploadImage(image.path);
            final yoloBoundingBoxes = [
              // dummy 값
              {
                "x_center": 0.5,
                "y_center": 0.5,
                "width": 0.2,
                "height": 0.3,
                "class_name": "Person"
              },
              {
                "x_center": 0.8,
                "y_center": 0.2,
                "width": 0.1,
                "height": 0.1,
                "class_name": "Dog"
              }
            ];
            // 화면 전환
            await Navigator.of(context).push(
              MaterialPageRoute(
                // DisplayPictureScreen 화면으로
                builder: (context) => DisplayPictureScreen(
                  imagePath: image.path, // 촬영한 image의 path 전달
                  yoloBoundingBoxes: yoloBoundingBoxes, // 분석 결과 전달
                ),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
        buttonText: 'Scan meat',
        iconData: Icons.camera_alt, // 카메라 아이콘
        // iconData: Icons.crop_free, // 스캔 아이콘
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
