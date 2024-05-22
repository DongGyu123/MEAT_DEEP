import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  // get original image size
  late Future<List<double>> imageSizeFuture;
  // // rendor image size
  // double picSize = 800;

  @override
  void initState() {
    super.initState();
    imageSizeFuture = loadImageSize(widget.imagePath);
    convertBoundingBoxes();
  }

  Future<List<double>> loadImageSize(String imagePath) async {
    final Image image = Image.file(File(imagePath));
    final ImageStream stream = image.image.resolve(ImageConfiguration.empty);
    final Completer<Size> completer = Completer<Size>();
    void imageListener(ImageInfo info, bool synchronousCall) {
      completer.complete(Size(
        info.image.width.toDouble(),
        info.image.height.toDouble(),
      ));
    }

    stream.addListener(ImageStreamListener(imageListener));
    final Size imageSize = await completer.future;
    stream.removeListener(ImageStreamListener(imageListener));

    print("imageSize -------------- $imageSize");
    return [imageSize.width, imageSize.height];
  }

  void convertBoundingBoxes() async {
    final convertedBoxes = BoundingBoxConverter.convertResponseToBoundingBoxes(
        widget.responseData, 1.0, 1.0);

    setState(() {
      boundingBoxes = convertedBoxes;
      print('============================================================');
      print(boundingBoxes);
      print('============================================================');
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
        body: FutureBuilder<List<double>>(
          future: imageSizeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              double imageWidth = snapshot.data![0];
              double imageHeight = snapshot.data![1];
              print("Image size: ${imageWidth} x ${imageHeight} ==========");
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints constraints) {
                      print(
                          'constraints.maxWidth ---- ${constraints.maxWidth}');
                      return Container(
                        height: 400,
                        // width: constraints.maxWidth,
                        // height: constraints.maxHeight,
                        margin: const EdgeInsets.all(10),
                        child: Center(
                          child: Expanded(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    height: 400,
                                    child: Image.file(
                                      File(widget.imagePath),
                                      fit: BoxFit.fitHeight,
                                      // width: constraints.maxWidth,
                                    ),
                                  ),
                                ),
                                // 이미지 위 개별 bbox 표시 --------------------------------------------------------
                                ...boundingBoxes.map((box) {
                                  print(box);
                                  int index = boundingBoxes.indexOf(box);
                                  box = BoundingBoxConverter
                                      .resizeConvertedBoundingBox(
                                    box,
                                    400 * (imageWidth / imageHeight),
                                    400,
                                  );
                                  return BoundingboxWidget(
                                    box: box,
                                    isSelected: selectedBboxId == index,
                                    onTap: () {
                                      print(
                                          'Box ${index} at position (${box['left']}, ${box['top']}) tapped!');
                                      setState(() {
                                        selectedBboxId =
                                            index; // Update selected index on tap
                                      });
                                    },
                                  );
                                }).toList(),
                                // ---------------------------------------------------------------------------
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  // 하단 result 정보 표시 ----------------------------------------------------------
                  // Positioned(
                  //   bottom: 30,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 33, vertical: 25),
                      child: Container(
                        height: 200,
                        child: Row(
                          
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                          if (selectedBboxId != null)
                            Expanded(
                              flex: 2, // Takes 2 parts of the space
                              // bbox 크롭 표시 -------------------------------------------------------------
                              child: CroppedBboxWidget(
                                  key: ValueKey(selectedBboxId),
                                  imagePath: widget.imagePath,
                                  boundingBox: BoundingBoxConverter
                                      .resizeConvertedBoundingBox(
                                          Map<String, dynamic>.from(
                                              boundingBoxes[selectedBboxId!]),
                                          imageWidth,
                                          imageHeight)),
                            ),
                          // confidence 막대 그래프 ----------------------------------------------
                          Expanded(
                            flex: 5, // Takes 5 parts of the space
                            child: (selectedBboxId != null)
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                  Container(height: 30,
                                  child: Text('${(boundingBoxes[
                                            selectedBboxId?.toInt() ?? 0]
                                        ['cooked'] == 1)?"cooked":"uncooked"}',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),),
                                  ),
                                  Container(height: 150,child:PercentageBarGraph(
                                    key: UniqueKey(),
                                    cookedPercentage: boundingBoxes[
                                            selectedBboxId?.toInt() ?? 0]
                                        ['cookedPercentage'],
                                    animate: true,
                                  ))])
                                : const Placeholder(
                                    color: Colors.black26,
                                  ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return const Text("Error loading image size");
            }
            return const CircularProgressIndicator();
          },
        ));
  }
}