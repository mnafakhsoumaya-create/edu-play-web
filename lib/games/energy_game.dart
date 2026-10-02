import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../utils/game_progress.dart';

class EnergyGame extends StatefulWidget {
  final String username;
  const EnergyGame({super.key, required this.username});
  @override
  State<EnergyGame> createState() => _EnergyGameState();
}

class _EnergyGameState extends State<EnergyGame> {
  int score = 0;
  int level = 1;
  int timeLeft = 15;
  bool gameOver = false;
  bool levelComplete = false;
  int correct = 0;
  int correctNeeded = 5;
  Map<String, dynamic>? currentQuestion;
  late dynamic _timer;
  final Random _random = Random();

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'اي طاقة نظيفة ؟',
      'correct': '☀️ طاقة شمسية',
      'wrong': ['🛢️ بترول', '🏭 فحم', '💥 غاز'],
    },
    {
      'question': 'اي مصدر متجدد ؟',
      'correct': '💨 طاقة الرياح',
      'wrong': ['🛢️ نفط', '☢️ نووي', '🔥 حرق'],
    },
    {
      'question': 'اي وسيلة صديقة للبيئة ؟',
      'correct': '🚲 دراجة هوائية',
      'wrong': ['🚗 سيارة بنزين', '✈️ طائرة', '🚢 باخرة'],
    },
    {
      'question': 'اي عمل يوفر الطاقة ؟',
      'correct': '💡 اطفاء الضوء',
      'wrong': ['📺 ترك التلفاز', '❄️ فتح التكييف', '🔌 شحن دائم'],
    },
    {
      'question': 'اي مصدر طاقة نظيف ؟',
      'correct': '🌊 طاقة المياه',
      'wrong': ['🛢️ بترول', '🏭 مصنع', '💨 دخان'],
    },
    {
      'question': 'اي تصرف يحمي البيئة ؟',
      'correct': '♻️ اعادة التدوير',
      'wrong': ['🗑️ رمي القمامة', '🔥 الحرق', '💧 تبذير الماء'],
    },
    {
      'question': 'اي طاقة لا تلوث الهواء ؟',
      'correct': '⚡ كهرباء متجددة',
      'wrong': ['🛢️ ديزل', '🏭 فحم', '🔥 غاز طبيعي'],
    },
    {
      'question': 'كيف نوفر الماء ؟',
      'correct': '🚿 دش قصير',
      'wrong': ['🛁 حمام طويل', '💧 صنبور مفتوح', '🌊 غسيل يومي'],
    },
  ];

  final List<String> envMessages = [
    '☀️ الطاقة الشمسية نظيفة ومجانية !',
    '💨 الرياح مصدر طاقة لا ينضب !',
    '🌍 وفر الطاقة انقذ الكوكب !',
    '⚡ الطاقة المتجددة مستقبلنا !',
  ];

  List<String> currentChoices = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final savedLevel = await GameProgress.loadLevel(
        widget.username, 'energy');
    setState(() => level = savedLevel);
    _startLevel();
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  void _startLevel() {
    correct = 0;
    correctNeeded = level == 1 ? 5 : level == 2 ? 7 :
    level == 3 ? 9 : 12;
    int seconds = level == 1 ? 15 : level == 2 ? 12 :
    level == 3 ? 10 : 8;
    levelComplete = false;
    setState(() { timeLeft = seconds; });
    _nextQuestion();
    _startTimer();
  }

  void _nextQuestion() {
    final q = questions[_random.nextInt(questions.length)];
    final wrongList = List<String>.from(q['wrong'] as List);
    wrongList.shuffle();
    int wrongCount = level == 1 ? 1 : level == 2 ? 2 : 3;
    final choices = [
      q['correct'] as String,
      ...wrongList.take(wrongCount)
    ];
    choices.shuffle();
    setState(() {
      currentQuestion = q;
      currentChoices = choices;
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

  void _onChoiceTap(String choice) async {
    if (gameOver || levelComplete) return;

    if (choice == currentQuestion!['correct']) {
      setState(() {
        correct++;
        score += level * 10;
        timeLeft = level == 1 ? 15 : level == 2 ? 12 :
        level == 3 ? 10 : 8;
      });

      if (correct >= correctNeeded) {
        _cancelTimer();
        setState(() => levelComplete = true);
        await GameProgress.saveLevel(
            widget.username, 'energy', level);
        await GameProgress.saveScore(
            widget.username, 'energy', score);
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
        _nextQuestion();
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
          title: Text('☀️ الطاقة المتجددة',
              style: GoogleFonts.cairo(fontSize: 22,
                  fontWeight: FontWeight.bold)),
          backgroundColor: Colors.orange[700],
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
          colors: [Color(0xFFFFF9E6), Color(0xFFFFE0B2)],
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
                      color: Colors.orange[700],
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
                      color: Colors.amber[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('✅ $correct/$correctNeeded',
                        style: GoogleFonts.cairo(fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: timeLeft <= 3
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
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: Text(envMessages[level - 1],
                  style: GoogleFonts.cairo(fontSize: 14,
                      color: Colors.orange[800],
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            if (levelComplete)
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text('🎉 ممتاز ! المستوى ${level + 1}',
                    style: GoogleFonts.cairo(fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            if (currentQuestion != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withAlpha(60),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                    currentQuestion!['question'] as String,
                    style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800]),
                    textAlign: TextAlign.center),
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
                    itemCount: currentChoices.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () =>
                            _onChoiceTap(currentChoices[index]),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.orange, width: 2),
                          ),
                          child: Center(
                              child: Text(currentChoices[index],
                                  style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[800]),
                                  textAlign: TextAlign.center)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGameOver() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF9E6), Color(0xFFFFE0B2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('☀️', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text('انتهت اللعبة !',
                style: GoogleFonts.cairo(fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900])),
            const SizedBox(height: 16),
            Text('النتيجة : $score ⭐',
                style: GoogleFonts.cairo(fontSize: 28,
                    color: Colors.amber[700])),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: Text(
                  '☀️ نصيحة : استخدم الطاقة الشمسية !',
                  style: GoogleFonts.cairo(fontSize: 14,
                      color: Colors.orange[800]),
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
                  color: Colors.orange[700],
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
                  color: Colors.amber[700],
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