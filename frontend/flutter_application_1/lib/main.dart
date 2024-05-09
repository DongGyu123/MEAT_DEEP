import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  _cameras = await availableCameras();
  runApp(const CameraApp());
}

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    _controller = CameraController(_cameras.first, ResolutionPreset.medium);
    await _controller.initialize();
    setState(() {
      _isReady = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Camera App')),
      body: CameraPreview(_controller),
    );
  }
}