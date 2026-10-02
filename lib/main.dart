import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const KidsWorldGames());
}

class KidsWorldGames extends StatelessWidget {
  const KidsWorldGames({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kids World Games',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LoginScreen(),
    );
  }
}