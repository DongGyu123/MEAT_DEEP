import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageUploadService {
  // 촬영 사진을 서버로 전송
  static Future<Map<String, dynamic>> uploadImage(
      String imagePath) async {
    var uri = Uri.parse(
        'http://172.17.10.108:8000/upload/'); // 에뮬레이터가 실행 중인 컴퓨터의 localhost
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));
    // request.fields['user'] = 'example_user';

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Image uploaded successfully.');
        // yolo bounding box 정보를 response로 받음
        var responseData = await http.Response.fromStream(response);
        final Map<String, dynamic> data;
        data = sonDecode(responseData);
        // Map data = jsonDecode(responseData.body);
        // // Map<String, dynamic> data_ = data; 
        // var data_ = Map<String, dynamic>.from(data);
        // print('${data_.runtimeType} --------------------------------------- ');
        // Map<String, dynamic> stringMap = data_.map((key, value) {
        //   // 각 키를 String으로 캐스팅하고, 값을 그대로 사용
        //   return MapEntry(key as String, value);
        // });
        // return stringMap;
        // print(data_);
        // print(data_.runtimeType);
        // return data_; 
      } else {
        print('Failed to upload image.');
        return {};
      }
    } catch (e) {
      print('Error occurred: $e');
      return {};
    }
  }
}
