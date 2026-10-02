import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../utils/game_progress.dart';

class MemoryGame extends StatefulWidget {
  final String username;
  const MemoryGame({super.key, required this.username});
  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  int score = 0;
  int level = 1;
  bool gameOver = false;
  List<Map<String, dynamic>> cards = [];
  int? firstIndex;
  int? secondIndex;
  bool canTap = true;
  int pairsFound = 0;
  final Random _random = Random();

  final List<Map<String, dynamic>> allCards = [
    {'emoji': '🐠', 'name': 'سمكة'},
    {'emoji': '🐬', 'name': 'دلفين'},
    {'emoji': '🐢', 'name': 'سلحفاة'},
    {'emoji': '🦈', 'name': 'قرش'},
    {'emoji': '🐙', 'name': 'اخطبوط'},
    {'emoji': '🦭', 'name': 'فقمة'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final savedLevel = await GameProgress.loadLevel(
        widget.username, 'memory');
    setState(() => level = savedLevel);
    _startLevel();
  }

  void _startLevel() {
    int pairCount = level == 1 ? 2 : level == 2 ? 4 : 6;
    final selected = List.of(allCards)..shuffle();
    final pairs = selected.take(pairCount).toList();

    List<Map<String, dynamic>> deck = [];
    for (var card in pairs) {
      deck.add({...card, 'isFlipped': false, 'isMatched': false});
      deck.add({...card, 'isFlipped': false, 'isMatched': false});
    }
    deck.shuffle();

    setState(() {
      cards = deck;
      firstIndex = null;
      secondIndex = null;
      pairsFound = 0;
      canTap = true;
    });
  }

  void _onCardTap(int index) async {
    if (!canTap) return;
    if (cards[index]['isFlipped'] == true) return;
    if (cards[index]['isMatched'] == true) return;

    setState(() => cards[index]['isFlipped'] = true);

    if (firstIndex == null) {
      firstIndex = index;
    } else {
      secondIndex = index;
      canTap = false;

      await Future.delayed(const Duration(milliseconds: 800));

      if (cards[firstIndex!]['name'] == cards[secondIndex!]['name']) {
        setState(() {
          cards[firstIndex!]['isMatched'] = true;
          cards[secondIndex!]['isMatched'] = true;
          pairsFound++;
          score += level * 10;
        });

        int pairCount = level == 1 ? 2 : level == 2 ? 4 : 6;
        if (pairsFound == pairCount) {
          await GameProgress.saveLevel(
              widget.username, 'memory', level);
          await GameProgress.saveScore(
              widget.username, 'memory', score);
          if (level < 3) {
            setState(() => level++);
            await Future.delayed(const Duration(milliseconds: 500));
            _startLevel();
          } else {
            setState(() => gameOver = true);
          }
        }
      } else {
        setState(() {
          cards[firstIndex!]['isFlipped'] = false;
          cards[secondIndex!]['isFlipped'] = false;
        });
      }

      firstIndex = null;
      secondIndex = null;
      canTap = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('🐠 ذاكرة المحيط',
              style: GoogleFonts.cairo(fontSize: 22,
                  fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: gameOver ? _buildGameOver() : _buildGame(),
      ),
    );
  }

  Widget _buildGame() {
    int crossAxis = level == 1 ? 2 : 4;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE0F7FF), Color(0xFFB3ECFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('⭐ $score',
                        style: GoogleFonts.cairo(fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('المستوى $level',
                        style: GoogleFonts.cairo(fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('🎴 $pairsFound ازواج',
                        style: GoogleFonts.cairo(fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxis,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    final isFlipped = card['isFlipped'] as bool;
                    final isMatched = card['isMatched'] as bool;
                    return GestureDetector(
                      onTap: () => _onCardTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: isMatched
                              ? Colors.green[300]
                              : isFlipped
                              ? Colors.white
                              : Colors.blue[600],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withAlpha(60),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isFlipped || isMatched) ...[
                              Text(card['emoji'] as String,
                                  style: const TextStyle(fontSize: 35)),
                              const SizedBox(height: 4),
                              Text(card['name'] as String,
                                  style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800])),
                            ] else
                              const Text('❓',
                                  style: TextStyle(
                                      fontSize: 36,
                                      color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOver() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE0F7FF), Color(0xFFB3ECFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🐠', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text('احسنت !',
                style: GoogleFonts.cairo(fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800])),
            const SizedBox(height: 16),
            Text('النتيجة : $score ⭐',
                style: GoogleFonts.cairo(fontSize: 28,
                    color: Colors.teal)),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Text(
                  '🌊 نصيحة : احمِ المحيطات من التلوث !',
                  style: GoogleFonts.cairo(fontSize: 14,
                      color: Colors.blue[800]),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () => setState(() {
                score = 0; level = 1;
                gameOver = false; _startLevel();
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text('🔄 العب مجددا',
                    style: GoogleFonts.cairo(fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text('🏠 الرئيسية',
                    style: GoogleFonts.cairo(fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}