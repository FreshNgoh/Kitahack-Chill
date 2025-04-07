import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class UploadService {
  static Future<String?> uploadImageToFirebase(File imageFile) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child(
        'uploads/$fileName.jpeg',
      );

      await ref.putFile(imageFile);

      return await ref.getDownloadURL();
    } catch (e) {
      print('🔥 Failed to upload image: $e');
      return null;
    }
  }
}
