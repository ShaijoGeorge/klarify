import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  // The tools we need
  final ImagePicker _picker = ImagePicker(); // Opens the camera
  // Tells the brain we specifically want to read Latin letters (German)
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin); 
  
  // The memory variables to hold the result
  bool _isScanning = false; 
  String _extractedText = "Take a picture of your German textbook!";

  // The function that does the magic
  Future<void> _scanTextbook() async {
    // Open the camera and wait for the user to take a picture
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    
    // If they closed the camera without taking a picture, just stop.
    if (photo == null) return;

    // Show a loading spinner so the user knows it's thinking
    setState(() {
      _isScanning = true;
    });

    try {
      // Turn the photo into a format ML Kit can understand
      final inputImage = InputImage.fromFilePath(photo.path);
      
      // Send the photo to the Brain! It reads the text instantly.
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Save what it read and update the screen
      setState(() {
        _extractedText = recognizedText.text;
      });
      
    } catch (e) {
      setState(() {
        _extractedText = "Oops! Could not read the image.";
      });
    } finally {
      // Hide the loading spinner
      setState(() {
        _isScanning = false;
      });
    }
  }

  // When the screen closes, we clean up the brain to save battery
  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  // The UI (What the user sees)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Magic Scanner'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Button to open the camera
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _scanTextbook, // Disable if loading
                icon: const Icon(Icons.camera_alt, size: 28),
                label: const Text('Scan Textbook Page', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // This is where we show the text the camera read!
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  // Adds a nice premium shadow
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                ),
                child: _isScanning 
                  // Show a loading circle while reading
                  ? const Center(child: CircularProgressIndicator())
                  // Show the text we found, wrapped so it doesn't overflow
                  : SingleChildScrollView(
                      child: Text(
                        _extractedText,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}