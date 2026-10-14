import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'splash_screen.dart';
import '../features/documents/presentation/document_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/home/presentation/history_screen.dart';
import '../features/home/presentation/trash_screen.dart';
import '../features/scanner/presentation/scanner_screen.dart';
import '../features/editor/presentation/editor_screen.dart';

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/scan', builder: (context, state) => const ScannerScreen()),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(path: '/trash', builder: (context, state) => const TrashScreen()),
    GoRoute(
      path: '/edit/:id',
      builder: (context, state) =>
          EditorScreen(documentId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/document/:id',
      builder: (context, state) =>
          DocumentScreen(documentId: state.pathParameters['id']!),
    ),
  ],
);

class ScanFlowApp extends StatelessWidget {
  const ScanFlowApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'ScanFlow',
    debugShowCheckedModeBanner: false,
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    themeMode: ThemeMode.system,
    routerConfig: _router,
  );

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff087f72),
      brightness: brightness,
      surface: brightness == Brightness.light
          ? const Color(0xfff7f8f6)
          : const Color(0xff111b1a),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: brightness == Brightness.light
            ? Colors.white
            : const Color(0xff192523),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
