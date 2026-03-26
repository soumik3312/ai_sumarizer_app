import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/notes_provider.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive database before running the app
  await DatabaseService.initialize();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const NoteSummarizerApp());
}

class NoteSummarizerApp extends StatefulWidget {
  const NoteSummarizerApp({super.key});

  @override
  State<NoteSummarizerApp> createState() => _NoteSummarizerAppState();
}

class _NoteSummarizerAppState extends State<NoteSummarizerApp> {
  final ThemeProvider _themeProvider = ThemeProvider();
  final NotesProvider _notesProvider = NotesProvider();

  @override
  void initState() {
    super.initState();
    _themeProvider.addListener(() => setState(() {}));
    _notesProvider.addListener(() => setState(() {}));
    
    // Initialize providers with data from Hive
    _initializeProviders();
  }

  Future<void> _initializeProviders() async {
    await _themeProvider.loadFromDatabase();
    await _notesProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProviderInherited(
      provider: _themeProvider,
      child: NotesProviderInherited(
        provider: _notesProvider,
        child: MaterialApp(
          title: 'NoteAI - Smart Summarizer',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeProvider.themeMode,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
