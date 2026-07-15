import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/database/flashcard.dart';
import 'features/splash/splash_screen.dart';

// Global variables
late Isar isarDb;
late SharedPreferences prefs;
late ValueNotifier<ThemeMode> themeNotifier;
late ValueNotifier<String> fontNotifier;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Init prefs and theme
  prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('themeMode') ?? 'system';
  ThemeMode initMode = ThemeMode.system;
  if (savedTheme == 'light') initMode = ThemeMode.light;
  if (savedTheme == 'dark') initMode = ThemeMode.dark;
  themeNotifier = ValueNotifier(initMode);

  final savedFont = prefs.getString('fontFamily') ?? 'Inter';
  fontNotifier = ValueNotifier(savedFont);

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
    return ValueListenableBuilder<String>(
      valueListenable: fontNotifier,
      builder: (context, currentFont, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, currentMode, _) {
            return MaterialApp(
              title: 'Klarify German',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.getLightTheme(currentFont),
              darkTheme: AppTheme.getDarkTheme(currentFont),
              themeMode: currentMode,
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
