import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLogin = true;
  String _error = '';
  List<Map<String, String>> _profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final names = prefs.getStringList('profiles_names') ?? [];
    final passes = prefs.getStringList('profiles_passes') ?? [];
    setState(() {
      _profiles = List.generate(names.length,
              (i) => {'name': names[i], 'pass': passes[i]});
    });
  }

  Future<void> _saveProfile(String name, String pass) async {
    final prefs = await SharedPreferences.getInstance();
    final names = prefs.getStringList('profiles_names') ?? [];
    final passes = prefs.getStringList('profiles_passes') ?? [];
    names.add(name);
    passes.add(pass);
    await prefs.setStringList('profiles_names', names);
    await prefs.setStringList('profiles_passes', passes);
  }

  void _submit() async {
    final name = _nameController.text.trim();
    final pass = _passController.text.trim();

    if (name.isEmpty || pass.isEmpty) {
      setState(() => _error = 'يرجى ملء جميع الحقول !');
      return;
    }

    if (_isLogin) {
      final exists = _profiles.any(
              (p) => p['name'] == name && p['pass'] == pass);
      if (!exists) {
        setState(() => _error = 'اسم المستخدم او كلمة المرور خاطئة !');
        return;
      }
    } else {
      final exists = _profiles.any((p) => p['name'] == name);
      if (exists) {
        setState(() => _error = 'هذا الاسم موجود مسبقا !');
        return;
      }
      await _saveProfile(name, pass);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', name);

    if (mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(
              builder: (_) => HomeScreen(username: name)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: const Center(
                        child: Text('🌍',
                            style: TextStyle(fontSize: 55)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text('العاب حماية البيئة',
                        style: GoogleFonts.cairo(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),

                    const SizedBox(height: 6),

                    Text('Kids World Games',
                        style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: Colors.white70,
                            fontStyle: FontStyle.italic)),

                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _isLogin = true; _error = '';
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _isLogin
                                          ? const Color(0xFF2E7D32)
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text('تسجيل الدخول',
                                        style: GoogleFonts.cairo(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: _isLogin
                                                ? Colors.white
                                                : Colors.grey),
                                        textAlign: TextAlign.center),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _isLogin = false; _error = '';
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !_isLogin
                                          ? const Color(0xFF2E7D32)
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text('حساب جديد',
                                        style: GoogleFonts.cairo(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: !_isLogin
                                                ? Colors.white
                                                : Colors.grey),
                                        textAlign: TextAlign.center),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          TextField(
                            controller: _nameController,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              labelText: 'اسم الطفل',
                              labelStyle: GoogleFonts.cairo(
                                  color: const Color(0xFF2E7D32)),
                              prefixIcon: const Icon(Icons.person,
                                  color: Color(0xFF2E7D32)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                    color: Color(0xFF2E7D32), width: 2),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          TextField(
                            controller: _passController,
                            obscureText: true,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              labelStyle: GoogleFonts.cairo(
                                  color: const Color(0xFF2E7D32)),
                              prefixIcon: const Icon(Icons.lock,
                                  color: Color(0xFF2E7D32)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                    color: Color(0xFF2E7D32), width: 2),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          if (_error.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red),
                              ),
                              child: Text(_error,
                                  style: GoogleFonts.cairo(
                                      fontSize: 13, color: Colors.red),
                                  textAlign: TextAlign.center),
                            ),

                          const SizedBox(height: 16),

                          GestureDetector(
                            onTap: _submit,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                  _isLogin ? '🚀 دخول' : '✅ انشاء حساب',
                                  style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  textAlign: TextAlign.center),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (_profiles.isNotEmpty) ...[
                      Text('الملفات الموجودة:',
                          style: GoogleFonts.cairo(
                              fontSize: 14, color: Colors.white70)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: _profiles.map((p) =>
                            GestureDetector(
                              onTap: () {
                                _nameController.text = p['name']!;
                                setState(() => _isLogin = true);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(50),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white54),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('👦',
                                        style: TextStyle(fontSize: 18)),
                                    const SizedBox(width: 6),
                                    Text(p['name']!,
                                        style: GoogleFonts.cairo(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            )
                        ).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}