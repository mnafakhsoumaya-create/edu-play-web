import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../utils/game_progress.dart';

class BeachCleanGame extends StatefulWidget {
  final String username;
  const BeachCleanGame({super.key, required this.username});
  @override
  State<BeachCleanGame> createState() => _BeachCleanGameState();
}

class _BeachCleanGameState extends State<BeachCleanGame> {
  int score = 0;
  int level = 1;
  int timeLeft = 30;
  bool gameOver = false;
  bool levelComplete = false;
  int itemsCollected = 0;
  int itemsNeeded = 5;
  List<Map<String, dynamic>> items = [];
  late dynamic _timer;
  final Random _random = Random();

  final List<Map<String, dynamic>> goodItems = [
    {'emoji': '🧴', 'name': 'زجاجة بلاستيك'},
    {'emoji': '🛍️', 'name': 'كيس بلاستيك'},
    {'emoji': '🥤', 'name': 'علبة مشروب'},
    {'emoji': '📦', 'name': 'كرتون'},
    {'emoji': '🧃', 'name': 'عصير'},
  ];

  final List<Map<String, dynamic>> badItems = [
    {'emoji': '🐚', 'name': 'صدفة طبيعية'},
    {'emoji': '🌊', 'name': 'موجة'},
    {'emoji': '🐠', 'name': 'سمكة'},
  ];

  final List<String> envMessages = [
    '♻️ البلاستيك يضر بالمحيط !',
    '🌊 نظف الشاطئ لحماية البحر !',
    '🐢 السلاحف تاكل البلاستيك !',
    '🌍 كوكبنا يحتاجك !',
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final savedLevel = await GameProgress.loadLevel(
        widget.username, 'beach');
    setState(() => level = savedLevel);
    _startLevel();
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  void _startLevel() {
    itemsCollected = 0;
    itemsNeeded = level == 1 ? 5 : level == 2 ? 8 :
    level == 3 ? 10 : 12;
    int seconds = level == 1 ? 30 : level == 2 ? 25 :
    level == 3 ? 20 : 15;
    levelComplete = false;

    List<Map<String, dynamic>> newItems = [];
    int goodCount = level == 1 ? 6 : 8;
    for (int i = 0; i < goodCount; i++) {
      final item = goodItems[_random.nextInt(goodItems.length)];
      newItems.add({
        'emoji': item['emoji'],
        'name': item['name'],
        'type': 'good',
        'collected': false,
      });
    }
    if (level >= 2) {
      int badCount = level == 2 ? 2 : level == 3 ? 3 : 4;
      for (int i = 0; i < badCount; i++) {
        final item = badItems[_random.nextInt(badItems.length)];
        newItems.add({
          'emoji': item['emoji'],
          'name': item['name'],
          'type': 'bad',
          'collected': false,
        });
      }
    }
    newItems.shuffle();

    setState(() {
      items = newItems;
      timeLeft = seconds;
    });
    _startTimer();
  }

  void _startTimer() {
    _cancelTimer();
    _timer = Stream.periodic(
        const Duration(seconds: 1)).listen((_) {
      if (!mounted) return;
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) {
          _cancelTimer();
          _endGame();
        }
      });
    });
  }

  void _cancelTimer() {
    try { _timer?.cancel(); } catch (_) {}
  }

  void _onItemTap(int index) async {
    if (gameOver || levelComplete) return;
    if (items[index]['collected'] == true) return;

    final item = items[index];

    if (item['type'] == 'good') {
      setState(() {
        items[index]['collected'] = true;
        itemsCollected++;
        score += level * 10;
      });

      if (itemsCollected >= itemsNeeded) {
        _cancelTimer();
        setState(() => levelComplete = true);

        // حفظ التقدم
        await GameProgress.saveLevel(
            widget.username, 'beach', level);
        await GameProgress.saveScore(
            widget.username, 'beach', score);

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          if (level < 4) {
            setState(() => level++);
            _startLevel();
          } else {
            setState(() => gameOver = true);
          }
        }
      } else {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted && !gameOver) {
          setState(() => items[index]['collected'] = false);
        }
      }
    } else {
      _cancelTimer();
      _endGame();
    }
  }

  void _endGame() {
    setState(() => gameOver = true);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('🏖️ نظف الشاطئ',
              style: GoogleFonts.cairo(fontSize: 22,
                  fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _cancelTimer();
              Navigator.pop(context);
            },
          ),
        ),
        body: gameOver ? _buildGameOver() : _buildGame(),
      ),
    );
  }

  Widget _buildGame() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF87CEEB), Color(0xFFFFEDB3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('⭐ $score',
                        style: GoogleFonts.cairo(fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('🗑️ $itemsCollected/$itemsNeeded',
                        style: GoogleFonts.cairo(fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: timeLeft <= 5
                          ? Colors.red : Colors.teal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('⏱️ $timeLeft',
                        style: GoogleFonts.cairo(fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Text(envMessages[level - 1],
                  style: GoogleFonts.cairo(fontSize: 14,
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(height: 8),
            Text('المستوى $level — اجمع $itemsNeeded نفايات !',
                style: GoogleFonts.cairo(fontSize: 14,
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold)),
            if (levelComplete)
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text('🎉 احسنت ! المستوى ${level + 1}',
                    style: GoogleFonts.cairo(fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final collected = item['collected'] as bool;
                    final isBad = item['type'] == 'bad';
                    return GestureDetector(
                      onTap: () => _onItemTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: collected
                              ? Colors.grey[200]
                              : isBad
                              ? Colors.blue[100]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: collected
                                ? Colors.grey[300]!
                                : isBad
                                ? Colors.blue
                                : Colors.green,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              collected ? '✓' : item['emoji'] as String,
                              style: TextStyle(
                                fontSize: collected ? 28 : 40,
                                color: collected
                                    ? Colors.grey[400] : null,
                              ),
                            ),
                            if (!collected)
                              Text(item['name'] as String,
                                  style: GoogleFonts.cairo(
                                    fontSize: 10,
                                    color: isBad
                                        ? Colors.blue[700]
                                        : Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center),
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
          colors: [Color(0xFF87CEEB), Color(0xFFFFEDB3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏖️', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text('انتهت اللعبة !',
                style: GoogleFonts.cairo(fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900])),
            const SizedBox(height: 16),
            Text('النتيجة : $score ⭐',
                style: GoogleFonts.cairo(fontSize: 28,
                    color: Colors.green[700])),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Text(
                  '🌍 نصيحة : قلل استخدام البلاستيك !',
                  style: GoogleFonts.cairo(fontSize: 14,
                      color: Colors.green[800]),
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
                  color: Colors.green[700],
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