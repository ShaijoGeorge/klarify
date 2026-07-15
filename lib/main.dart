import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/database/flashcard.dart';

// Global variable for the database
late Isar isarDb;

void main() async{

  WidgetsFlutterBinding.ensureInitialized();

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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Klarify German',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      home: const TestDashboardScreen()
    );
  }
}

// Temporary layout template to test if the colors shift correctly
class TestDashboardScreen extends StatelessWidget {
  const TestDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Detects if the screen is currently displaying dark or light colors
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Klarify German'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Willkommen!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'Change your phone settings to watch the colors shift automatically.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              
              // Testing one card using our gender color logic
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.getGenderColor('der', isDark),
                    width: 2,
                  ),
                ),
                child: const Text(
                  'der Hund (Dog)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
