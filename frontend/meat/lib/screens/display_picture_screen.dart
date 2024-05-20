import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:meat/widgets/boundingbox_widget.dart';
import 'package:meat/widgets/chart_widget.dart';
import 'package:meat/widgets/cropped_bbox_widget.dart';
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
  int? selectedBboxId;
  int cookedPercentage = 70; // 초기값 설정

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
      // if boundingBoxes.isNotEmpty:
      selectedBboxId = 0;
    });
  }

  void updateCookedPercentage(int newPercentage) {
    setState(() {
      cookedPercentage = newPercentage; // 새로운 백분율로 업데이트
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
                ...boundingBoxes.map((box) {
                  int index = boundingBoxes.indexOf(box);
                  return BoundingboxWidget(
                    box: box,
                    isSelected: selectedBboxId == index,
                    onTap: () {
                      print(
                          'Box ${index} at position (${box['left']}, ${box['top']}) tapped!');
                      setState(() {
                        selectedBboxId = index; // Update selected index on tap
                        cookedPercentage = 70;
                      });
                    },
                  );
                }).toList(),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 33, vertical: 35),
              child: SizedBox(
                height: 120,
                child: Row(children: [
                  if (selectedBboxId != null)
                    Expanded(
                      flex: 2, // Takes 2 parts of the space
                      child: CroppedBboxWidget(
                        key: ValueKey(selectedBboxId),
                        imagePath: widget.imagePath,
                        boundingBox: boundingBoxes[selectedBboxId!],
                      ),
                    ),
                  Expanded(
                    flex: 5, // Takes 5 parts of the space
                    child: PercentageBarGraph(
                      key: UniqueKey(),
                      cookedPercentage: cookedPercentage.toInt(),
                      animate: true,
                    ),
                    //Placeholder()
                  ),
                ]),

                // Placeholder(
                //   color: Colors.black26,
                // ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
