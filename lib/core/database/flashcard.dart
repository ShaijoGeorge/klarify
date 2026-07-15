import 'package:isar/isar.dart';

// Tells our builder robots to create the background code!
part 'flashcard.g.dart';

@collection
class Flashcard {
  // Every card gets a unique ID number automatically (1, 2, 3...)
  Id id = Isar.autoIncrement; 

  // The German word (e.g., "Hund")
  // The 'Index' makes searching for words lightning fast later.
  @Index(type: IndexType.value)
  String? word;

  // The English meaning (e.g., "Dog")
  String? translation;

  // The German article (der, die, or das)
  String? article;

  // The plural form (e.g., "-e")
  String? pluralForm;

  // SPACED REPETITION BRAIN
  // Tells the app when user should study this card again.
  DateTime? nextReviewDate;

  // How many times user has gotten it right in a row (helps calculate the next date)
  int consecutiveCorrect = 0; 
}