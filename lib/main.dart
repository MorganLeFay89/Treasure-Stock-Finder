import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:finance/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // APIキーを安全に読み込む
  await dotenv.load(fileName: '.env_secrets/.env');

  runApp(
    const ProviderScope(
      child: TreasureStockFinderApp(),
    ),
  );
}
