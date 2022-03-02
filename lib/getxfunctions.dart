import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:hive/hive.dart';
// import 'package:music_player_project/database/database.dart';
// import 'package:music_player_project/main.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:on_audio_room/on_audio_room.dart';

// import 'pages/home.dart';

class IconChanging extends GetxController {
  dynamic isChanged = true;

  bool playlisticon = true;

  var clr = Colors.black;
  void iconChanging(index) {
    isChanged = !isChanged;

    if (isChanged) {
      clr = Colors.black;

      Get.snackbar(
        'Liked Songs',
        'Removed From Liked songs',
        backgroundColor: Colors.white,
        duration: Duration(seconds: 2),
      );
    } else {
      clr = Colors.red;
      Get.snackbar(
        'Liked Songs',
        'Song Added in Favorite',
        backgroundColor: Colors.white,
        duration: Duration(seconds: 2),
      );
    }
    update();
  }

  playlisticonChanging() {
    playlisticon = !playlisticon;

    update();
  }
}

class SettingsController extends GetxController {
  final themeData = GetStorage();

  bool isDarkMode = true;

  String textTheme = 'Dark Theme';

  @override
  void themeChange() {
    isDarkMode = !isDarkMode;
    if (isDarkMode) {
      textTheme = 'Dark Theme';
      themeData.write('theme', isDarkMode);
      Get.changeTheme(
        ThemeData(
          scaffoldBackgroundColor: Colors.grey.shade300,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.red,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.red.shade900,
            foregroundColor: Colors.white,
          ),
        ),
      );
    } else {
      textTheme = 'Light Theme';
      Get.changeTheme(ThemeData.dark());
      themeData.write('theme', !isDarkMode);
    }
    update();
  }

  @override
  void onInit() {
    if (themeData.read('theme') != null) {
      isDarkMode = themeData.read('theme');
      update();
    }
    // TODO: implement onInit
    super.onInit();
  }
}

// ===================================================================================
// This is a Playing Screen Controller. Its using to control the Playing Screen.

class PlayingScreenController extends GetxController
    with GetTickerProviderStateMixin {
  // late List<Audio> audiosList;

  // PlayingScreenController(this.audiosList);
  // double value = 0.0;
  bool repeat = false;
  bool shuffle = false;

  late AnimationController iconControl;
  late AnimationController rotateController;
  late Animation<double> rotateAnimation;
  late AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer.withId('music');

  bool notificationSwitch = false;
  final switchData = GetStorage();

  @override
  void onInit([index, List<Audio>? list]) {
    if (list == null) {
      return;
    }
    if (index == null) {
      return;
    }

    assetsAudioPlayer.open(
      Playlist(audios: list, startIndex: index),
      autoStart: false,
      showNotification: notificationSwitch,
      loopMode: LoopMode.playlist,
      notificationSettings: NotificationSettings(
        stopEnabled: false,
        customNextAction: (player) {
          if (!iconControl.isCompleted) {
            iconControl.forward();
            rotateController.repeat();
          }
          player.next();
        },
        customPrevAction: (player) {
          if (!iconControl.isCompleted) {
            iconControl.forward();
            rotateController.repeat();
          }
          player.previous();
        },
        customPlayPauseAction: (player) {
          if (!iconControl.isCompleted) {
            iconControl.forward();
            rotateController.repeat();
            player.play();
          } else if (iconControl.isCompleted) {
            iconControl.reverse();
            rotateController.stop();
            player.pause();
          }
        },
      ),
    );

    if (switchData.read('getXisSwitched') != null) {
      notificationSwitch = switchData.read('getXisSwitched');
      update();
    }

    iconControl =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    rotateController =
        AnimationController(vsync: this, duration: Duration(seconds: 5))
          ..stop();

    rotateAnimation =
        CurvedAnimation(parent: rotateController, curve: Curves.easeIn);

    // permission request
    update();
    super.onInit();
  }

  @override
  void onClose() {
    iconControl.dispose();
    rotateController.dispose();
    // assetsAudioPlayer.dispose();
    if (switchData == false) {
      assetsAudioPlayer.dispose();
    }
    super.onClose();
  }

  repeatSong() {
    repeat = !repeat;
    update();
  }

  shuffleSong() {
    shuffle = !shuffle;
    update();
  }

  changingSliderSeek(double sec) {
    Duration pos = Duration(seconds: sec.toInt());
    assetsAudioPlayer.seek(pos);
    update();
  }

  switchChangeState(value) {
    notificationSwitch = value;
    switchData.write('getXisSwitched', notificationSwitch);
    update();
  }
}

// ==================================================================================

class HomeController extends GetxController {
  List<SongModel> fechsongsall = [];
  // List<SongsModel> databaseList = [];
  // final dataBaseList = ValueNotifier(<SongsModel>[]);

  final OnAudioQuery audioQuery = OnAudioQuery();
  OnAudioRoom audioRoom = OnAudioRoom();

  bool changingGridview = true;
  bool favoriteAdded = false;
  bool visible = false;

  changeHomeBody() {
    changingGridview = !changingGridview;
    update();
  }

  addToFavorites(List songs, int index, bool isAdded) {
    print(isAdded);
    favoriteAdded = isAdded;
    if (isAdded == false) {
      // audioRoom.addTo(
      //   RoomType.FAVORITES,
      //   songs[index].getMap.toFavoritesEntity(),
      //   ignoreDuplicate: false,
      // );

      // isAdded = true;

      Get.back();
      // ========================================

      Get.snackbar(
        '',
        '',
        animationDuration: Duration(seconds: 2),
        backgroundColor: Colors.white,
        titleText: Text(
          songs[index].title,
          maxLines: 2,
          style: const TextStyle(color: Colors.black),
        ),
        messageText: const Text(
          'Added to Liked Songs',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      );
    } else {
      // isAdded = false;
      Get.back();
      Get.snackbar(
        '',
        '',
        animationDuration: Duration(seconds: 2),
        backgroundColor: Colors.white,
        titleText: Text(
          songs[index].title,
          maxLines: 2,
          style: const TextStyle(color: Colors.black),
        ),
        messageText: const Text(
          'Song Already Added',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      );
    }
    update();
    // onAudioRoom.addTo(
    //   RoomType.FAVORITES,
    //   dataBaseList.get
    //   ignoreDuplicate: false,
    // );
  }

  requestPermission() async {
    if (!kIsWeb) {
      bool permissionStatus = await audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await audioQuery.permissionsRequest();

        List<SongModel> allfechsong = await audioQuery.querySongs();

        fechsongsall = allfechsong;

        // await fechSongsAddtoDataBase();
      } else {
        // await audioQuery.permissionsRequest();

        List<SongModel> allfechsong = await audioQuery.querySongs();
        //  audioQuery.queryAlbums();
        fechsongsall = allfechsong;

        // await fechSongsAddtoDataBase();
      }
      update();
    }
    //  await addsonglist();
  }

  @override
  void onInit() {
    requestPermission();

    // TODO: implement onInit
    super.onInit();
  }
 
  // fechSongsAddtoDataBase() async {
  //   final box = Hive.box(dbname);
  //   dataBaseList.value = fechsongsall
  //       .map(
  //         (e) => SongsModel(
  //           title: e.title,
  //           uri: e.uri.toString(),
  //           id: e.id,
  //         ),
  //       )
  //       .toList();

  //   await box.put('allSongs', dataBaseList.value);
  // }

}



// =========================================================================================
// This class used to controling the favorites page.

// class FavoritesController extends GetxController {
//   OnAudioRoom audioRoom = OnAudioRoom();
//   deleteSong(favorites, index) async {
//     update();
//     await audioRoom.deleteFrom(
//       RoomType.FAVORITES,
//       favorites[index].key,
//     );
//   }
// }

class BottomNavbarControlls extends GetxController {
  var currentIndex = 0;

  selectedItemChanging(index) {
    currentIndex = index;
    update();
  }
}
