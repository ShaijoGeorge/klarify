import 'dart:convert';
import 'dart:developer';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../database/flashcard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiService {
  static Future<String> get _getApiKey async {
    final prefs = await SharedPreferences.getInstance();
    final overrideKey = prefs.getString('GEMINI_API_KEY');
    if (overrideKey != null && overrideKey.isNotEmpty) {
      return overrideKey;
    }
    return dotenv.env['GEMINI_API_KEY'] ?? '';
  }

  static Future<List<Flashcard>> generateFlashcards(String rawText) async {
    final apiKey = await _getApiKey;

    // Wake up the Gemini Brain
    final model = GenerativeModel(
      model: 'gemini-3.5-flash', // The super-fast, free version
      apiKey: apiKey,
    );

    // The Strict Instructions (The Prompt)
    final prompt = '''
    You are a strict German language tutor. 
    Look at the following messy text from a textbook and extract the German vocabulary.
    
    Rules:
    1. Ignore random numbers, page numbers, or messy characters.
    2. Figure out the definite article (der, die, or das) for nouns.
    3. Figure out the plural form if it is a noun.
    4. Provide the exact English translation.
    
    OUTPUT ONLY A VALID JSON ARRAY. NO OTHER TEXT. 
    Format example:
    [
      {"word": "Hund", "translation": "Dog", "article": "der", "pluralForm": "-e"},
      {"word": "schnell", "translation": "fast", "article": "", "pluralForm": ""}
    ]
    
    Text to process:
    $rawText
    ''';

    try {
      // Ask the AI to do the work
      final response = await model.generateContent([Content.text(prompt)]);
      final rawJson = response.text ?? '[]';

      // Clean up the response (sometimes AI adds ```json at the start)
      final cleanJson = rawJson.replaceAll('```json', '').replaceAll('```', '').trim();

      // Turn the AI's JSON string into real Dart Maps
      final List<dynamic> parsedData = jsonDecode(cleanJson);

      // Build our Lego pieces! (Create Isar Flashcards)
      List<Flashcard> newCards = parsedData.map((item) {
        return Flashcard()
          ..word = item['word']
          ..translation = item['translation']
          ..article = item['article']
          ..pluralForm = item['pluralForm']
          ..nextReviewDate = DateTime.now() // Ready to study immediately!
          ..createdAt = DateTime.now(); // Track when it was scanned
      }).toList();

      return newCards;
    } catch (e) {
      log("The Brain got confused: $e");
      throw Exception("AI Error: $e");
    }
  }
}