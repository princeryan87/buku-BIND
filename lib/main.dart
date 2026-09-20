import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/lisensi_model.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LisensiService.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const BukuDigitalApp());
}

class BukuDigitalApp extends StatelessWidget {
  const BukuDigitalApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buku Digital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D9B5A)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F5F7),
      ),
      home: const SplashScreen(),
    );
  }
}
