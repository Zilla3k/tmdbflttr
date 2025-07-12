import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_database/app/providers/movie_provider/movie_provider.dart';
import 'package:movie_database/app/providers/search_provider/search_provider.dart';
import 'package:movie_database/app/screens/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:movie_database/app/providers/home_provider/home_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('Bearer Token: ${dotenv.env['BEARER_TOKEN']}');
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()..fetchAll()),
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}
