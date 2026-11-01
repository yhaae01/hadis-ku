import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'providers/books_provider.dart';
import 'views/home_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HadisKuApp());
}

class HadisKuApp extends StatelessWidget {
  const HadisKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BooksProvider>(
          create: (_) => BooksProvider()..load(),
        ),
      ],
      child: MaterialApp(
        title: 'HadisKu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeView(),
      ),
    );
  }
}
