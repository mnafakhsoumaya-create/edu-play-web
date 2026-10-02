import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../games/beach_clean_game.dart';
import '../games/forest_game.dart';
import '../games/sort_game.dart';
import '../games/energy_game.dart';
import '../games/memory_game.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> games = [
    {
      'name': 'نظف الشاطئ',
      'emoji': '🏖️',
      'color': Color(0xFF1E88E5),
      'description': 'اجمع النفايات البلاستيكية !',
      'route': '/beach',
      'levels': '4 مستويات',
    },
    {
      'name': 'انقذ الغابة',
      'emoji': '🌳',
      'color': Color(0xFF43A047),
      'description': 'ازرع الاشجار وانقذ الغابة !',
      'route': '/forest',
      'levels': '4 مستويات',
    },
    {
      'name': 'فرز النفايات',
      'emoji': '♻️',
      'color': Color(0xFF00897B),
      'description': 'ضع كل نفاية في مكانها الصحيح !',
      'route': '/sort',
      'levels': '4 مستويات',
    },
    {
      'name': 'الطاقة المتجددة',
      'emoji': '☀️',
      'color': Color(0xFFFB8C00),
      'description': 'اختر مصادر الطاقة النظيفة !',
      'route': '/energy',
      'levels': '4 مستويات',
    },
    {
      'name': 'ذاكرة المحيط',
      'emoji': '🐠',
      'color': Color(0xFF039BE5),
      'description': 'ابحث عن الازواج !',
      'route': '/memory',
      'levels': '3 مستويات',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        itemCount: games.length,
                        itemBuilder: (context, index) {
                          return _buildGameCard(games[index]);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.logout,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 4),
                      Text('خروج',
                          style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: Colors.red,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              Text('مرحبا ${widget.username} ! 👋',
                  style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withAlpha(100),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text('🌍', style: TextStyle(fontSize: 45)),
            ),
          ),
          const SizedBox(height: 12),
          Text('العاب حماية البيئة',
              style: GoogleFonts.cairo(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900])),
          const SizedBox(height: 4),
          Text('تعلم والعب واحمِ كوكبنا ! 🌱',
              style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.green[700])),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Text(
                '🌍 معا نحمي البيئة ونبني مستقبلا افضل !',
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(Map<String, dynamic> game) {
    return GestureDetector(
      onTap: () {
        switch (game['route']) {
          case '/beach':
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => BeachCleanGame(
                        username: widget.username)));
            break;
          case '/forest':
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => ForestGame(
                        username: widget.username)));
            break;
          case '/sort':
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => SortGame(
                        username: widget.username)));
            break;
          case '/energy':
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => EnergyGame(
                        username: widget.username)));
            break;
          case '/memory':
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => MemoryGame(
                        username: widget.username)));
            break;
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: (game['color'] as Color).withAlpha(80),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (game['color'] as Color).withAlpha(50),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: (game['color'] as Color).withAlpha(30),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(game['emoji'] as String,
                    style: const TextStyle(fontSize: 38)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(game['name'] as String,
                      style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900])),
                  const SizedBox(height: 2),
                  Text(game['description'] as String,
                      style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (game['color'] as Color).withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(game['levels'] as String,
                        style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: game['color'] as Color,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: game['color'] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}