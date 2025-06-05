// File: lib/screens/create_post_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_pbb_kel6/services/firestore_service.dart'; // Ensure this path is correct
import 'package:fp_pbb_kel6/screens/home_page.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:fp_pbb_kel6/services/imgur_api.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();
  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();
  User? _currentUser;

  final String _imgurClientId =
      "YOUR_IMGUR_CLIENT_ID"; // Replace or load from env

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Image picking failed: $e")));
    }
  }

  Future<String?> _uploadImageToImgur(File image) async {
    // This function remains for future use but is not called in the test version.
    // For brevity, I'm omitting the full Imgur code here, but it's the same as your original.
    // Assume it's correctly implemented if/when you decide to use it.
    if (_imgurClientId == "YOUR_IMGUR_CLIENT_ID" || _imgurClientId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Imgur Client ID not configured.")),
        );
      }
      return null;
    }
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.imgur.com/3/image'),
    );
    request.headers['Authorization'] = 'Client-ID $_imgurClientId';
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
        filename: path.basename(image.path),
      ),
    );
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true &&
            jsonResponse['data'] != null &&
            jsonResponse['data']['link'] != null) {
          return jsonResponse['data']['link'];
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Imgur upload error: ${response.statusCode}")),
        );
      }
      return null;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Imgur upload exception: $e")));
      }
      return null;
    }
  }

  Future<String?> _uploadImageToFastAPI(File image) async {
    // This function remains for future use but is not called in the test version.
    // For brevity, I'm omitting the full FastAPI code here, but it's the same as your original.
    // Assume it's correctly implemented if/when you decide to use it.
    const String fastApiUploadUrl = "YOUR_FASTAPI_SERVER_URL/upload_image/";
    var request = http.MultipartRequest('POST', Uri.parse(fastApiUploadUrl));
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        image.path,
        filename: path.basename(image.path),
      ),
    );
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['image_url'];
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("FastAPI upload error: ${response.statusCode}"),
          ),
        );
      }
      return null;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("FastAPI upload exception: $e")));
      }
      return null;
    }
  }

  Future<void> _submitPost() async {
    if (_currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in. Cannot post.")),
        );
      }
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select an image.")));
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    String? imageUrlToSave;

    try {
      // Convert File to XFile for imgur upload
      final xFile = XFile(_imageFile!.path);
      imageUrlToSave = await ImgurAPI.uploadImageorVideo(xFile);

      String username = _currentUser!.displayName ?? "Anonymous";
      DocumentSnapshot userData = await _firestoreService.getUserData(
        _currentUser!.uid,
      );
      if (userData.exists) {
        final data = userData.data() as Map<String, dynamic>;
        if (data.containsKey('username') &&
            data['username'] != null &&
            (data['username'] as String).isNotEmpty) {
          username = data['username'];
        }
      }

      await _firestoreService.createPost(
        userId: _currentUser!.uid,
        username: username,
        imageUrl: imageUrlToSave,
        caption: _captionController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post created successfully!")),
      );
      setState(() {
        _imageFile = null;
        _captionController.clear();
      });

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error creating post: $e")));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(
                    context,
                  ).pop(); // Use the outer context for this pop
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(
                    context,
                  ).pop(); // Use the outer context for this pop
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Post"),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitPost,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      "Share",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => _showImageSourceActionSheet(context),
              child: Container(
                height: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  border: Border.all(color: Colors.grey[700]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    _imageFile != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Tap to select an image",
                              style: TextStyle(color: Colors.grey[400]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                hintText: "Write a caption...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[850],
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
              maxLines: 4,
              minLines: 1,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
