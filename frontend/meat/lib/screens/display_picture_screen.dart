import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:meat/widgets/boundingbox_widget.dart';
import 'package:meat/widgets/chart_widget.dart';
import 'package:meat/widgets/cropped_bbox_widget.dart';
import '../utilities/bounding_box_converter.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> responseData;

  const DisplayPictureScreen({
    super.key,
    required this.imagePath,
    required this.responseData,
  });

  @override
  DisplayPictureScreenState createState() => DisplayPictureScreenState();
}

class DisplayPictureScreenState extends State<DisplayPictureScreen> {
  // bboxes 정보를 class+confidence+xywhn 한 번에 관리
  List<Map<String, dynamic>> boundingBoxes = [];
  // 현재 선택된 bbox id 관리
  int? selectedBboxId;

  @override
  void initState() {
    super.initState();
    loadImageAndConvertBoundingBoxes();
  }

  void loadImageAndConvertBoundingBoxes() async {
    // final Image image = Image.file(File(widget.imagePath));
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
    final convertedBoxes = BoundingBoxConverter.convertResponseToBoundingBoxes(
      widget.responseData,
      250, // imageSize.width,
      400, // imageSize.height,
    );

    setState(() {
      boundingBoxes = convertedBoxes;
      print('convertedBoxes ---------- ${convertedBoxes}');
      selectedBboxId = boundingBoxes.isNotEmpty ? 0 : null; // id 초기화
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
      // 촬영된 사진 표시 -------------------------------------------------------------------
      body: SingleChildScrollView(child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 250, 
              height: 400, 
              child: 
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(File(widget.imagePath)),
                ),
                // 개별 bbox 표시 -------------------------------------------------------------
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
                      });
                    },
                  );
                }).toList(),
                // ---------------------------------------------------------------------------
              ],
            ),
          ),), 
          // 하단 result 정보 표시 ----------------------------------------------------------
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
                  // confidence 막대 그래프 ----------------------------------------------
                  Expanded(
                    flex: 5, // Takes 5 parts of the space
                    child: (selectedBboxId != null)
                        ? PercentageBarGraph(
                            key: UniqueKey(),
                            cookedPercentage:
                                boundingBoxes[selectedBboxId?.toInt() ?? 0]
                                    ['cookedPercentage'],
                            animate: true,
                          )
                        : const Placeholder(
                            color: Colors.black26,
                          ),
                  ),
                ]),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
