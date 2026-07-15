
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../core/services/ai_service.dart';
import '../../core/database/flashcard.dart';
import '../../main.dart'; // To access our global isarDb variable!

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
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    setState(() {
      _isScanning = true;
      _extractedText = "Reading textbook..."; 
    });

    try {
      // The Camera reads the text
      final inputImage = InputImage.fromFilePath(photo.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      setState(() {
        _extractedText = "Asking the AI to build flashcards...\n(This takes a few seconds)";
      });

      // Send the messy text to our AI Brain
      final List<Flashcard> generatedCards = await AiService.generateFlashcards(recognizedText.text);

      if (generatedCards.isNotEmpty) {
        // Save the perfect flashcards into the Isar Database!
        await isarDb.writeTxn(() async {
          await isarDb.flashcards.putAll(generatedCards);
        });

        setState(() {
          _extractedText = "Success! Saved ${generatedCards.length} flashcards to your deck!";
        });
      } else {
        setState(() {
          _extractedText = "Oops! The AI couldn't find any clear German words.";
        });
      }
      
    } catch (e) {
      setState(() {
        _extractedText = "CRASH REPORT:\n$e"; // show the exact error!
      });
    } finally {
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
                      color: Colors.black.withValues(alpha: 0.05),
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