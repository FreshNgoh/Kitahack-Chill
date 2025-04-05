import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application/components/bar.dart';
import 'package:image_picker/image_picker.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openCameraAndHandleResult();
    });
  }

  Future<void> _openCameraAndHandleResult() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);

    if (!mounted) return;

    if (image == null) {
      // Return to previous page if user cancels
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Bar()),
        (route) => false, // This clears all existing routes
      );
    } else {
      // Navigate to display page with captured image
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DisplayPhotoPage(imageFile: File(image.path)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}

class DisplayPhotoPage extends StatelessWidget {
  final File imageFile;

  const DisplayPhotoPage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Captured Photo'),
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Bar()),
              (route) => false,
            );
          },
          child: Container(
            margin: EdgeInsets.all(10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xffF7F8F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.chevron_left),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color.fromARGB(255, 112, 110, 110),
                  width: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 240,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15), // Adjust this value
                child: Image.file(imageFile, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
