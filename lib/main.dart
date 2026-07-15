import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/database/flashcard.dart';
import 'app_shell.dart';

// Global variable for the database
late Isar isarDb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Find a safe folder on the phone to put the filing cabinet
  final dir = await getApplicationDocumentsDirectory();

  // Open the Isar filing cabinet and tell it to use our Flashcard blueprint
  isarDb = await Isar.open(
    [FlashcardSchema],
    directory: dir.path,
  );

  runApp(const KlarifyGermanApp());
}

class KlarifyGermanApp extends StatelessWidget {
  const KlarifyGermanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Klarify German',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AppShell(),
    );
  }
}
