import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/face_launcher_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar para modo fullscreen imersivo
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  runApp(const FaceLauncherApp());
}

class FaceLauncherApp extends StatelessWidget {
  const FaceLauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Launcher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const FaceLauncherScreen(),
    );
  }
}
