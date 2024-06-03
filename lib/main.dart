import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constant/app_color.dart';
import 'database/database.dart';
import 'home_page.dart'; // Riverpodのインポート


// テーマの状態を管理するためのグローバルなValueNotifier
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);


void main() async {
  //WidgetsFlutterBinding.ensureInitialized();

  if (shouldDeleteDatabase) {
    await deleteDatabaseFile();
  }
  // データベースを初期化
  //await initializeDB();
  runApp(
  const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.mainBackground,
        cardColor: AppColors.cardBackground,
        textTheme: TextTheme(
          bodyText1: GoogleFonts.notoSansJp(color: AppColors.mainText),
          bodyText2: GoogleFonts.notoSansJp(color: AppColors.subText),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: AppColors.darkPrimary,
        scaffoldBackgroundColor: AppColors.darkMainBackground,
        cardColor: AppColors.darkCardBackground,
        textTheme: TextTheme(
          bodyText1: GoogleFonts.notoSansJp(color: AppColors.darkMainText),
          bodyText2: GoogleFonts.notoSansJp(color: AppColors.darkSubText),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkPrimary,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: Colors.white,
        ),
      ),
          themeMode: themeMode, // テーマモードの切り替え
          home: const HomePage(), // アプリのホームページ
        );
      },
    );
  }
}
