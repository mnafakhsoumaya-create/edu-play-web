import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../utils/game_progress.dart';

class SortGame extends StatefulWidget {
  final String username;
  const SortGame({super.key, required this.username});
  @override
  State<SortGame> createState() => _SortGameState();
}

class _SortGameState extends State<SortGame> {
  int score = 0;
  int level = 1;
  int timeLeft = 30;
  bool gameOver = false;
  bool levelComplete = false;
  int sorted = 0;
  int sortedNeeded = 5;
  Map<String, dynamic>? currentItem;
  late dynamic _timer;
  final Random _random = Random();

  final List<Map<String, dynamic>> wasteItems = [
    {'emoji': '🧴', 'name': 'بلاستيك', 'bin': 'بلاستيك', 'color': Colors.yellow},
    {'emoji': '🛍️', 'name': 'كيس', 'bin': 'بلاستيك', 'color': Colors.yellow},
    {'emoji': '📰', 'name': 'جريدة', 'bin': 'ورق', 'color': Colors.blue},
    {'emoji': '📦', 'name': 'كرتون', 'bin': 'ورق', 'color': Colors.blue},
    {'emoji': '🥫', 'name': 'علبة معدن', 'bin': 'معدن', 'color': Colors.grey},
    {'emoji': '🍌', 'name': 'قشر موز', 'bin': 'عضوي', 'color': Colors.green},
    {'emoji': '🥕', 'name': 'خضار', 'bin': 'عضوي', 'color': Colors.green},
    {'emoji': '💡', 'name': 'مصباح', 'bin': 'خطر', 'color': Colors.red},
    {'emoji': '🔋', 'name': 'بطارية', 'bin': 'خطر', 'color': Colors.red},
  ];

  final List<Map<String, dynamic>> bins = [
    {'name': 'بلاستيك', 'emoji': '🟡', 'color': Colors.yellow},
    {'name': 'ورق', 'emoji': '🔵', 'color': Colors.blue},
    {'name': 'معدن', 'emoji': '⚫', 'color': Colors.grey},
    {'name': 'عضوي', 'emoji': '🟢', 'color': Colors.green},
    {'name': 'خطر', 'emoji': '🔴', 'color': Colors.red},
  ];

  List<Map<String, dynamic>> displayedBins = [];

  final List<String> envMessages = [
    '♻️ فرز النفايات يحمي البيئة !',
    '🌍 اعادة التدوير تنقذ الارض !',
    '🌱 النفايات العضوية سماد طبيعي !',
    '⚠️ النفايات الخطرة تلوث التربة !',
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final savedLevel = await GameProgress.loadLevel(
        widget.username, 'sort');
    setState(() => level = savedLevel);
    _startLevel();
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  void _startLevel() {
    sorted = 0;
    sortedNeeded = level == 1 ? 5 : level == 2 ? 8 :
    level == 3 ? 10 : 12;
    int seconds = level == 1 ? 30 : level == 2 ? 25 :
    level == 3 ? 20 : 15;
    levelComplete = false;

    int binCount = level == 1 ? 2 : level == 2 ? 3 :
    level == 3 ? 4 : 5;
    displayedBins = bins.take(binCount).toList();

    setState(() { timeLeft = seconds; });
    _nextItem();
    _startTimer();
  }

  void _nextItem() {
    final availableBinNames =
    displayedBins.map((b) => b['name']).toList();
    final available = wasteItems
        .where((w) => availableBinNames.contains(w['bin']))
        .toList();
    setState(() {
      currentItem = available[_random.nextInt(available.length)];
    });
  }

  void _startTimer() {
    _cancelTimer();
    _timer = Stream.periodic(
        const Duration(seconds: 1)).listen((_) {
      if (!mounted) return;
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) { _cancelTimer(); _endGame(); }
      });
    });
  }

  void _cancelTimer() {
    try { _timer?.cancel(); } catch (_) {}
  }

  void _onBinTap(Map<String, dynamic> bin) async {
    if (gameOver || levelComplete || currentItem == null) return;

    if (bin['name'] == currentItem!['bin']) {
      setState(() { sorted++; score += level * 10; });

      if (sorted >= sortedNeeded) {
        _cancelTimer();
        setState(() => levelComplete = true);
        await GameProgress.saveLevel(
            widget.username, 'sort', level);
        await GameProgress.saveScore(
            widget.username, 'sort', score);
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
        _nextItem();
      }
    } else {
      _cancelTimer();
      _endGame();
    }
  }

  void _endGame() => setState(() => gameOver = true);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('♻️ فرز النفايات',
              style: GoogleFonts.cairo(fontSize: 22,
                  fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green[800],
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () { _cancelTimer(); Navigator.pop(context); },
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
          colors: [Color(0xFFF0FFF0), Color(0xFFE8F5E9)],
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
                      color: Colors.green[800],
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
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('♻️ $sorted/$sortedNeeded',
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
            const SizedBox(height: 16),
            if (currentItem != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withAlpha(60),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(currentItem!['emoji'] as String,
                        style: const TextStyle(fontSize: 70)),
                    const SizedBox(height: 8),
                    Text(currentItem!['name'] as String,
                        style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800])),
                    const SizedBox(height: 4),
                    Text('في اي صندوق ؟',
                        style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: Colors.grey[600])),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: displayedBins.length,
                  itemBuilder: (context, index) {
                    final bin = displayedBins[index];
                    return GestureDetector(
                      onTap: () => _onBinTap(bin),
                      child: Container(
                        decoration: BoxDecoration(
                          color: (bin['color'] as Color).withAlpha(40),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: bin['color'] as Color,
                            width: 3,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(bin['emoji'] as String,
                                style: const TextStyle(fontSize: 30)),
                            const SizedBox(height: 4),
                            Text(bin['name'] as String,
                                style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: bin['color'] as Color)),
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
          colors: [Color(0xFFF0FFF0), Color(0xFFE8F5E9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('♻️', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text('انتهت اللعبة !',
                style: GoogleFonts.cairo(fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900])),
            const SizedBox(height: 16),
            Text('النتيجة : $score ⭐',
                style: GoogleFonts.cairo(fontSize: 28,
                    color: Colors.orange)),
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
                  '♻️ نصيحة : افرز نفاياتك يوميا !',
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
                  color: Colors.green[800],
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
                  color: Colors.orange,
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