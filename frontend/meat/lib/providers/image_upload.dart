import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageUploadService {
  // 촬영 사진을 서버로 전송
  static Future<List<Map<String, dynamic>>> uploadImage(
      String imagePath) async {
    var uri = Uri.parse(
        'http://10.0.2.2:8000/upload/'); // 에뮬레이터가 실행 중인 컴퓨터의 localhost
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));
    // request.fields['user'] = 'example_user';

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Image uploaded successfully.');
        // yolo bounding box 정보를 response로 받음
        var responseData = await http.Response.fromStream(response);
        var data = jsonDecode(responseData.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('Failed to upload image.');
        return [];
      }
    } catch (e) {
      print('Error occurred: $e');
      return [];
    }
  }
}
