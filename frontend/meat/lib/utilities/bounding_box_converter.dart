class BoundingBoxConverter {
  static List<Map<String, dynamic>> convertResponseToBoundingBoxes(
      Map<String, dynamic> responseData,
      double imageWidth,
      double imageHeight) {
    List<Map<String, dynamic>> convertedBoxes = [];

    for (int idx = 0; idx < responseData['xywhn'].length; idx++) {
      int cookedPercentage = (responseData['conf'][idx] * 100).round();
      double left = responseData['xywhn'][idx][0] * imageWidth;
      double top = responseData['xywhn'][idx][1] * imageHeight;
      double width = responseData['xywhn'][idx][2] * imageWidth;
      double height = responseData['xywhn'][idx][3] * imageHeight;

      convertedBoxes.add({
        "id": idx, // (optional)
        "cooked": responseData['cls'][idx],
        "cookedPercentage": cookedPercentage,
        "left": left,
        "top": top,
        "width": width,
        "height": height,
      });
    }

    return convertedBoxes;
  }

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
