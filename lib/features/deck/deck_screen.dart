import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../core/database/flashcard.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart'; // To access isarDb

class DeckScreen extends StatefulWidget {
  const DeckScreen({super.key});

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  List<Flashcard> _dueCards = [];
  bool _isLoading = true;
  bool _isFlipped = false; // Tracks if we are looking at the front or back

  @override
  void initState() {
    super.initState();
    _loadDueCards();
  }

  // Pull the cards from the database
  Future<void> _loadDueCards() async {
    final now = DateTime.now();
    // Ask Isar: "Give me all cards where nextReviewDate is BEFORE or EQUAL to right now."
    final cards = await isarDb.flashcards
        .filter()
        .nextReviewDateLessThan(now)
        .or()
        .nextReviewDateIsNull() // Catch brand new cards!
        .findAll();

    setState(() {
      _dueCards = cards;
      _isLoading = false;
      _isFlipped = false;
    });
  }

  // The Memory Brain (Spaced Repetition Math)
  Future<void> _gradeCard(int multiplierInHours) async {
    if (_dueCards.isEmpty) return;

    final card = _dueCards.first;
    
    // Calculate the new date in the future
    card.nextReviewDate = DateTime.now().add(Duration(hours: multiplierInHours));
    
    // Save the new date into the Isar Filing Cabinet!
    await isarDb.writeTxn(() async {
      await isarDb.flashcards.put(card);
    });

    // Remove the card from the screen and reset for the next one
    setState(() {
      _dueCards.removeAt(0);
      _isFlipped = false;
    });
  }

  // The UI (What user see)
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dueCards.isEmpty) {
      return const Center(
        child: Text("You are all caught up! Go scan some books.", 
            style: TextStyle(fontSize: 18)),
      );
    }

    final currentCard = _dueCards.first;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_dueCards.length} Cards Due'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // THE FLASHCARD
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Flip the card when tapped!
                  setState(() {
                    _isFlipped = true;
                  });
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    // MAGIC CRAYONS: Paint the border based on der/die/das!
                    border: Border.all(
                      color: AppTheme.getGenderColor(currentCard.article ?? '', isDark),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      )
                    ]
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Always show the German word
                      Text(
                        currentCard.word ?? '',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 40),
                      ),
                      
                      // Only show the answer if the card is flipped!
                      if (_isFlipped) ...[
                        const SizedBox(height: 20),
                        Divider(color: Colors.grey.withOpacity(0.2), thickness: 2, endIndent: 40, indent: 40),
                        const SizedBox(height: 20),
                        Text(
                          '${currentCard.article} ${currentCard.word} (Plural: ${currentCard.pluralForm})',
                          style: TextStyle(fontSize: 18, color: AppTheme.getGenderColor(currentCard.article ?? '', isDark)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          currentCard.translation ?? '',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 24),
                        ),
                      ] else ...[
                        const SizedBox(height: 40),
                        const Text("Tap to flip", style: TextStyle(color: Colors.grey)),
                      ]
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 30),

            // THE GRADING BUTTONS (Only show when flipped)
            if (_isFlipped) 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _GradeButton(label: 'Again', color: Colors.red, onPressed: () => _gradeCard(0)), // 0 hours (Immediately)
                  _GradeButton(label: 'Hard', color: Colors.orange, onPressed: () => _gradeCard(12)), // 12 hours
                  _GradeButton(label: 'Good', color: Colors.green, onPressed: () => _gradeCard(24)), // 24 hours (1 day)
                  _GradeButton(label: 'Easy', color: Colors.blue, onPressed: () => _gradeCard(96)), // 96 hours (4 days)
                ],
              )
            else 
              const SizedBox(height: 60), // Empty space to keep layout from jumping
          ],
        ),
      ),
    );
  }
}

// A mini-widget to make our buttons look nice and uniform
class _GradeButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _GradeButton({required this.label, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}