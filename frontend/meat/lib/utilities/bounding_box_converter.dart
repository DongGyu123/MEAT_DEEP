class BoundingBoxConverter {
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
