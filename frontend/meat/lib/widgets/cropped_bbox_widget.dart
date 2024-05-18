import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class CroppedBboxWidget extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> boundingBox;

  const CroppedBboxWidget(
      {Key? key, required this.imagePath, required this.boundingBox})
      : super(key: key);

  @override
  _CroppedBboxWidgetState createState() => _CroppedBboxWidgetState();
}

class _CroppedBboxWidgetState extends State<CroppedBboxWidget> {
  img.Image? croppedImage;
  Map<String, dynamic>? boundingBox;

  @override
  void initState() {
    super.initState();
    boundingBox = widget.boundingBox;
    if (boundingBox != null) {
      cropImage(boundingBox!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (croppedImage != null)
            Expanded(
              child: Center(
                child: Image.memory(
                  img.encodeJpg(croppedImage!),
                  width: 200, // 고정 너비
                  height: 200, // 고정 높이
                  fit: BoxFit.contain, // 이미지 비율 유지 없이 크기에 맞추기
                ),
              ),
            )
          else
            const Expanded(
              child: Center(
                  child:
                      CircularProgressIndicator()), // Show loading indicator while image is processing
            ),
        ],
      ),
    );
  }

  void cropImage(Map<String, dynamic> box) async {
    final imageFile = File(widget.imagePath);
    final bytes = await imageFile.readAsBytes();
    img.Image? src = img.decodeImage(bytes);

    if (src != null) {
      int x = box['left']!.toInt();
      int y = box['top']!.toInt();
      int w = box['width']!.toInt();
      int h = box['height']!.toInt();
      img.Image cropped = img.copyCrop(src, x: x, y: y, width: w, height: h);

      setState(() {
        croppedImage = cropped;
      });
    }
  }
}
