// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class ImgurAPI {

  /// Upload image or video (Vidio belom coba)
  ///   
  ///  Parameter [XFile] dari ImagePicker (ex: picker.pickImage(source: ImageSource.gallery))
  ///   
  /// Throws an [Exception] if the upload fails.
  ///   
  /// Returns a [String] containing the uploaded file URL.
  static Future<String> uploadImageorVideo(XFile pickedFile) async {
  final clientID = "6643a03c8fd8e2e";
    try {
      final mimeType = lookupMimeType(pickedFile.path);

      if (mimeType == null) {
        throw Exception("Error unknown mimetype: $mimeType");
      }

      final mediaType = MediaType(
        mimeType.split('/')[0],
        mimeType.split('/')[1],
      );

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgur.com/3/image'), // or /3/image
      );

      request.headers['Authorization'] = 'Client-ID $clientID';

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          pickedFile.path,
          contentType: mediaType, // or png, webp, etc
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('Upload successful: $responseBody');
        final Map<String, dynamic> json = jsonDecode(responseBody);
        final String imageUrl = json['data']['link'];
        return imageUrl;
      }else{
        print('Upload failed: $responseBody , ${response.statusCode}');
        throw Exception(
          "Error uploading image Status Code: $response.statusCode",
        );
      }
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception("Error uploading image: $e");
    }
  }
}
