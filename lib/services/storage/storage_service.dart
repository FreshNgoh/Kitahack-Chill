import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class StorageService with ChangeNotifier {
  // Firebase Storage
  final firebaseStorage = FirebaseStorage.instance;

  //Images stored in firebase as download URLs
  List<String> _imageUrls = [];

  // loading status
  bool _isLoading = false;

  // uploading status
  bool _isUploading = false;

  // G E T T E R S
  List<String> get imageUrls => _imageUrls;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;

  // R E A D   I M A G E S
  Future<void> fetchImages() async {
    //start loading
    _isLoading = true;

    // get the list under the directory: uploaded_images/
    final ListResult result =
        await firebaseStorage.ref('uploaded_images/').listAll();

    // get the download URLs for each image
    final urls = await Future.wait(
      result.items.map((ref) => ref.getDownloadURL()),
    );

    // update URLs
    _imageUrls = urls;

    // finish loading
    _isLoading = false;

    // update UI, notift listeners
    notifyListeners();
  }

  // D E L E T E   I M A G E

  // Images are stored as download URLS, eg. https://firebasestorage.googleapis.com/v0/b/eat-meh-kitahack.appspot.com/o/uploaded_images%2Fimage1.jpg?alt=media&token=12345678-1234-1234-1234-123456789012
  // To delete an image, we need to delete the path from the storage

  Future<void> deleteImages(String imageUrl) async {
    try {
      // remove from local list
      _imageUrls.remove(imageUrl);

      //get path name and delete from firebase
      final String path = extractPathFromUrl(imageUrl);
      await firebaseStorage.ref(path).delete();
    } catch (e) {
      print('Error deleting image: $e');
    }

    // update UI, notift listeners
    notifyListeners();
  }

  String extractPathFromUrl(String url) {
    Uri uri = Uri.parse(url);

    // extracting the part of the url we need
    String encodedPath = uri.pathSegments.last;

    // url decoding path
    return Uri.decodeComponent(encodedPath);
  }

  // U P L O A D   I M A G E

  Future<void> uploadImage() async {
    // start upload
    _isUploading = true;
    // update UI
    notifyListeners();

    //pick an image
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    // user cancel the image selection
    if (image == null) return;

    File file = File(image.path);

    try {
      // define the path in storage
      String filePath = 'uploaded_images/${DateTime.now()}.png';

      //upload the file to firebase storage
      await firebaseStorage.ref(filePath).putFile(file);

      //after uploading, fetch the download URL
      String downloadUrl = await firebaseStorage.ref(filePath).getDownloadURL();

      //update the image URLs list and UI
      _imageUrls.add(downloadUrl);
      notifyListeners();
    } catch (e) {
      print('Error uploading image: $e');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
