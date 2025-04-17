import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'dart:io';
import 'package:image/image.dart' as img;

class ProfileUploadScreen extends StatefulWidget {
  const ProfileUploadScreen({super.key});

  @override
  State<ProfileUploadScreen> createState() => _ProfileUploadScreenState();
}

class _ProfileUploadScreenState extends State<ProfileUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _image = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<File> _compressImage(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('Could not decode image');

    // Resize image to 128x128
    final resized = img.copyResize(
      image,
      width: 128,
      height: 128,
      maintainAspect: true
     
    );

    // Compress with decreasing quality until under 100KB
    int quality = 25;
    List<int> compressedBytes;
    do {
      compressedBytes = img.encodeJpg(resized, quality: quality);
      quality -= 5;
    } while (compressedBytes.length > 100 * 1024 && quality > 5);
    
    // Create a new file with compressed image
    final compressedFile = File(file.path.replaceAll('.jpg', '_compressed.jpg'));
    await compressedFile.writeAsBytes(compressedBytes);
    
    print('Final image size: ${compressedBytes.length / 1024}KB with quality: ${quality + 5}');
    return compressedFile;
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = auth.FirebaseAuth.instance.currentUser;
      if (user == null) return;
         print('User ID: ${user.uid}');
      print('Image name: ${_image!.path.split('/').last}');
print("Ref");
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');
print("Compressing image");
      final compressedFile = await _compressImage(_image!);
      print("Image compressed");
print("uploading");
      try {
        final String extension = compressedFile.path.toLowerCase().split('.').last;
        final String contentType = extension == 'png' ? 'image/png' : 'image/jpeg';
        await storageRef.putFile(compressedFile, SettableMetadata(contentType: contentType));
      } catch (e) {
        print('Error uploading file to Firebase Storage: $e');
        rethrow;
      }
      final downloadURL = await storageRef.getDownloadURL();
   

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'profileImageUrl': downloadURL});

      if (mounted) {
        Navigator.pop(context, downloadURL);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
        print('Error details: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile Picture'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null)
              ClipOval(
                child: Image.file(
                  _image!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Icon(
                Icons.person,
                size: 200,
                color: Colors.grey,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Choose Image'),
            ),
            const SizedBox(height: 10),
            if (_image != null)
              ElevatedButton(
                onPressed: _isLoading ? null : _uploadImage,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Upload Image'),
              ),
          ],
        ),
      ),
    );
  }
} 