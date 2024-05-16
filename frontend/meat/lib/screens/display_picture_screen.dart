import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../utilities/bounding_box_converter.dart';

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
    final convertedBoxes = BoundingBoxConverter.convertYoloToBoundingBoxes(
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
          const SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(File(widget.imagePath)),
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
