import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:hive_flutter/adapters.dart';
// import 'package:music_player/database/database.dart';

import 'package:music_player_project/getxfunctions.dart';
import 'package:on_audio_room/on_audio_room.dart';

import 'pages/bottomnavbar.dart';

// ignore: constant_identifier_names
// String dbname = 'music';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  OnAudioRoom().initRoom();
  // await Hive.initFlutter();
  // Hive.registerAdapter(SongsModelAdapter());
  // await Hive.openBox(dbname);
  runApp(MyApp());
}

class MyApp extends GetView<SettingsController> {
  MyApp({Key? key}) : super(key: key);

  final themeDate = GetStorage();

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController());

    return GetMaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey.shade300,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red.shade900,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      //  themeMode: ThemeService().getThemeMode(),
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        backgroundColor: Colors.black,
        splash: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/Music app logo.png',
              ),
            ),
          ),
        ),
        splashIconSize: 100,
        nextScreen: BottomNavBar(),
        splashTransition: SplashTransition.slideTransition,
      ),
    );
  }
}
