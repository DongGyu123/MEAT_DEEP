import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  // camera 초기화
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  // run app
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color.fromARGB(255, 60, 60, 60), // 로딩 색
          onPrimary: Color.fromARGB(255, 255, 255, 255),
          primaryContainer: Color.fromRGBO(255, 210, 46, 1), // 버튼 색
          onPrimaryContainer: Color.fromARGB(255, 83, 83, 83),
          secondary: Color(0xff03dac6),
          onSecondary: Colors.black,
          secondaryContainer: Color(0xff03dac6),
          onSecondaryContainer: Colors.black,
          error: Color(0xffb00020),
          onError: Colors.white,
          background:
              Colors.white, //Color.fromARGB(255, 250, 250, 250), // 배경 색
          onBackground: Color.fromARGB(255, 255, 255, 255),
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        // textTheme: const TextTheme(
        //   titleLarge: TextStyle(
        //     fontSize: 20.0,
        //     fontWeight: FontWeight.normal,
        //   ),
        // ),
      ),
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
      // appBar: AppBar(
      //   title: const Center(child: Text('Scan Your Meat')),
      // ),
      body: Stack(
        children: <Widget>[
          // 카메라 미리보기 화면
          Positioned(
            top: 63,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 15, bottom: 20), //15
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FutureBuilder<void>(
                  future: _initializeControllerFuture, // 비동기작업 기다리는 대상 객체
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      // 비동기작업 완료되면
                      // CameraController의 CameraPreview 사용
                      return CameraPreview(_controller);
                    } else {
                      // 비동기작업 완료되지 않았으면
                      // 즉 CameraPreview 없을 때 로딩 화면
                      return const Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Color.fromARGB(117, 105, 105, 105),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 32, 32, 32)),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              title: const Center(
                child: Text(
                  'meat checker',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1),
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0, // 상단 바 그림자 제거
              toolbarHeight: 44.0,
            ),
          ),
        ],
      ),
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

// 사진 촬영 버튼 ui 분리
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

// DisplayPictureScreen : 촬영된 사진 보여주는 화면
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final List<Map<String, dynamic>> yoloBoundingBoxes;

  const DisplayPictureScreen({
    super.key,
    required this.imagePath,
    required this.yoloBoundingBoxes,
  });

  @override
  DisplayPictureScreenState createState() => DisplayPictureScreenState();
}

class DisplayPictureScreenState extends State<DisplayPictureScreen> {
  List<Map<String, dynamic>> boundingBoxes = [];

  @override
  void initState() {
    super.initState();
    loadImageAndConvertBoundingBoxes();
  }

  void loadImageAndConvertBoundingBoxes() async {
    final Image image = Image.file(File(widget.imagePath));
    final ImageStream stream = image.image.resolve(ImageConfiguration.empty);
    final Completer<Size> completer = Completer<Size>();
    stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(Size(
        info.image.width.toDouble(),
        info.image.height.toDouble(),
      ));
    }));

    final imageSize = await completer.future;
    final convertedBoxes = convertYoloToBoundingBoxes(
      widget.yoloBoundingBoxes,
      imageSize.width,
      imageSize.height,
    );

    setState(() {
      boundingBoxes = convertedBoxes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        'check result..',
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 1.1),
      )),
      // 촬영된 사진 표시
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(File(widget.imagePath.toString())),
                ),
                ...boundingBoxes
                    .map((box) => Positioned(
                          left: box['left'],
                          top: box['top'],
                          child: Container(
                            width: box['width'],
                            height: box['height'],
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromARGB(255, 211, 53, 53),
                                  width: 2),
                            ),
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
          const Positioned(
            bottom: 30,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 33, vertical: 35),
              child: SizedBox(
                height: 120,
                child: Placeholder(
                  color: Colors.black26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// convertYoloToBoundingBoxes
List<Map<String, dynamic>> convertYoloToBoundingBoxes(
    List<Map<String, dynamic>> yoloBoxes,
    double imageWidth,
    double imageHeight) {
  return yoloBoxes.map((box) {
    double width = box['width']! * imageWidth;
    double height = box['height']! * imageHeight;
    double left = (box['x_center']! * imageWidth) - (width / 2);
    double top = (box['y_center']! * imageHeight) - (height / 2);
    String className = box['class_name']!;

    return {
      "left": left,
      "top": top,
      "width": width,
      "height": height,
      "class_name": className
    };
  }).toList();
}

// 촬영 사진을 서버로 전송
Future<List<Map<String, dynamic>>> uploadImage(String imagePath) async {
  var uri =
      Uri.parse('http://10.0.2.2:8000/upload/'); // 에뮬레이터가 실행 중인 컴퓨터의 localhost
  var request = http.MultipartRequest('POST', uri);
  request.files.add(await http.MultipartFile.fromPath(
    'file',
    imagePath,
  ));
  // request.fields['user'] = 'example_user';

  late List<Map<String, dynamic>> yoloBoundingBoxes;
  try {
    var response = await request.send();
    if (response.statusCode == 200) {
      print('Image uploaded successfully.');
      // yolo bounding box 정보를 response로 받음
      var responseData = await http.Response.fromStream(response);
      var data = jsonDecode(responseData.body);
      yoloBoundingBoxes =
          List<Map<String, dynamic>>.from(data['yoloBoundingBoxes']);
    } else {
      print('Failed to upload image.');
    }
  } catch (e) {
    print('Error occurred: $e');
  }

  return yoloBoundingBoxes;
}
