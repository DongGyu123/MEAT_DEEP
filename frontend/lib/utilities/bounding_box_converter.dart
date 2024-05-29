class BoundingBoxConverter {
  static List<Map<String, dynamic>> convertResponseToBoundingBoxes(
      Map<String, dynamic> responseData,
      double imageWidth,
      double imageHeight) {
    List<Map<String, dynamic>> convertedBoxes = [];

    for (int idx = 0; idx < responseData['xywhn'].length; idx++) {
      int cookedPercentage = (responseData['conf'][idx] * 100).round();
      double width = responseData['xywhn'][idx][2] * imageWidth;
      double height = responseData['xywhn'][idx][3] * imageHeight;
      double left = responseData['xywhn'][idx][0] * imageWidth - (width / 2);
      double top = responseData['xywhn'][idx][1] * imageHeight - (height / 2);

      print('---------------- ${width} ${height}');

      convertedBoxes.add({
        "id": idx, // (optional)
        "cooked": responseData['cls'][idx],
        "cookedPercentage": cookedPercentage,
        "left": left,
        "top": top,
        "width": width,
        "height": height,
        "imageWidth": imageWidth,
        "imageHeight": imageHeight,
      });
    }

    return convertedBoxes;
  }

  static Map<String, dynamic> resizeConvertedBoundingBox(
      Map<String, dynamic> convertedBox, double newWidth, double newHeight) {
    Map<String, dynamic> resizedConvertedBox = {};

    double resizeWidthRatio = newWidth / convertedBox['imageWidth'];
    double resizeHeightRatio = newHeight / convertedBox['imageHeight'];

    double width = convertedBox['width'] * resizeWidthRatio;
    double height = convertedBox['height'] * resizeHeightRatio;
    double left = convertedBox['left'] * resizeWidthRatio;
    double top = convertedBox['top'] * resizeHeightRatio;

    // resizedConvertedBox['width'] *= resizeWidthRatio;
    // resizedConvertedBox['height'] *= resizeHeightRatio;
    // resizedConvertedBox['left'] *= resizeWidthRatio;
    // resizedConvertedBox['top'] *= resizeHeightRatio;
    // resizedConvertedBox['imageWidth'] = newWidth;
    // resizedConvertedBox['imageHeight'] = newHeight;

    resizedConvertedBox = {
      "id": convertedBox['id'], // (optional)
      "cooked": convertedBox['cooked'],
      "cookedPercentage": convertedBox['cookedPercentage'],
      "left": left,
      "top": top,
      "width": width,
      "height": height,
      "imageWidth": newWidth,
      "imageHeight": newHeight,
    };

    print(
        'Resized Box [${resizeWidthRatio}% x ${resizeHeightRatio}%] --------> [${newWidth} x ${newHeight}]');

    return resizedConvertedBox;
  }

  static List<Map<String, dynamic>> resizeConvertedBoundingBoxes(
      List<Map<String, dynamic>> convertedBoxes,
      double newWidth,
      double newHeight) {
    List<Map<String, dynamic>> resizedConvertedBoxes = [];

    for (int idx = 0; idx < convertedBoxes.length; idx++) {
      double resizeWidthRatio = newWidth / convertedBoxes[idx]['imageWidth'];
      double resizeHeightRatio = newHeight / convertedBoxes[idx]['imageHeight'];

      double width = convertedBoxes[idx]['width'] * resizeWidthRatio;
      double height = convertedBoxes[idx]['height'] * resizeHeightRatio;
      double left = convertedBoxes[idx]['left'] * resizeWidthRatio;
      double top = convertedBoxes[idx]['top'] * resizeHeightRatio;

      print('Resized Boxes ---------------- ${width} ${height}');

      resizedConvertedBoxes.add({
        "id": idx, // (optional)
        "cooked": convertedBoxes[idx]['cooked'],
        "cookedPercentage": convertedBoxes[idx]['cookedPercentage'],
        "left": left,
        "top": top,
        "width": width,
        "height": height,
        "imageWidth": newWidth,
        "imageHeight": newHeight,
      });
    }

    return resizedConvertedBoxes;
  }

  // static List<Map<String, dynamic>> resizeBoundingBoxes(
  //     List<Map<String, dynamic>> convertedBoxes,
  //     double resizeWidthRatio,
  //     double resizeHeightRatio) {
  //   List<Map<String, dynamic>> resizedConvertedBoxes = [];

  //   for (int idx = 0; idx < convertedBoxes.length; idx++) {
  //     double width = convertedBoxes[idx]['width'] * resizeWidthRatio;
  //     double height = convertedBoxes[idx]['height'] * resizeHeightRatio;
  //     double left = convertedBoxes[idx]['left'] * resizeWidthRatio;
  //     double top = convertedBoxes[idx]['top'] * resizeHeightRatio;

  //     print('---------------- ${width} ${height}');

  //     resizedConvertedBoxes.add({
  //       "id": idx, // (optional)
  //       "cooked": convertedBoxes[idx]['cooked'],
  //       "cookedPercentage": convertedBoxes[idx]['cookedPercentage'],
  //       "left": left,
  //       "top": top,
  //       "width": width,
  //       "height": height,
  //     });
  //   }

  //   return resizedConvertedBoxes;
  // }

  static List<Map<String, dynamic>> convertYoloToBoundingBoxes(
      List<Map<String, dynamic>> yoloBoxes,
      double imageWidth,
      double imageHeight) {
    return yoloBoxes.map((box) {
      double width = box['width'] * imageWidth;
      double height = box['height'] * imageHeight;
      double left = (box['x_center'] * imageWidth) - (width / 2);
      double top = (box['y_center'] * imageHeight) - (height / 2);
      String className = box['class_name'];

      return {
        "left": left,
        "top": top,
        "width": width,
        "height": height,
        "class_name": className
      };
    }).toList();
  }
}