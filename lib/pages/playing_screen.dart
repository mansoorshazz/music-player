import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:music_player_project/controllers/playlist.dart';
import 'package:music_player_project/getxfunctions.dart';
import 'package:music_player_project/pages/bottomnavbar.dart';
import 'package:music_player_project/pages/songs_add_to_playlist.dart';
import 'package:music_player_project/widgets/miniplayer.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:on_audio_room/on_audio_room.dart';
import 'package:text_scroll/text_scroll.dart';

class PlayingScreen extends GetView<PlayingScreenController> {
  final dynamic index;

  final List<Audio>? convertedList;

  final List<SongModel>? songs;

  PlayingScreen({
    Key? key,
    required this.convertedList,
    this.songs,
    this.index,
  }) : super(key: key);

  final OnAudioRoom audioRoom = OnAudioRoom();

  final TextEditingController playListNameController = TextEditingController();

  // final bool playing = false;

  @override
  Widget build(BuildContext context) {
    Get.put(PlayingScreenController());
    Get.put(PlayListController());

    controller.onInit(index, convertedList);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back)),
        title: const Text('Now Playing'),
        centerTitle: true,
      ),
      body: GetBuilder<PlayingScreenController>(
        builder: (control) => Column(
          children: [
            Container(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  buildRotatePlayingImage(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  control.assetsAudioPlayer.builderRealtimePlayingInfos(
                      builder: (context, realtimeInfos) {
                    return control.assetsAudioPlayer.builderIsPlaying(
                        builder: (context, isPlaying) => isPlaying
                            ? TextScroll(
                                controller
                                    .assetsAudioPlayer.getCurrentAudioTitle,
                                style: TextStyle(
                                  fontSize: 20,
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                controller
                                    .assetsAudioPlayer.getCurrentAudioTitle,
                                style: TextStyle(
                                  fontSize: 20,
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.bold,
                                ),
                              ));
                  }),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  buildFavoriteAddIconPlaylistAdd(context),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  buildSongDuration(context),
                  buildSlider(context),
                  buildRepeatAndShuffleIcon(context),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  buildPauseAndPlayandFastForwardIcons(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================================================
  // This is a audio playing image  and Rotate Animation.

  buildRotatePlayingImage() {
    return controller.assetsAudioPlayer.builderRealtimePlayingInfos(
        builder: (context, realTimeInfo) {
      return GetBuilder<PlayingScreenController>(
        builder: (control) => RotationTransition(
          turns: control.rotateAnimation,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  spreadRadius: 1,
                  blurRadius: 1,
                  // offset: Offset(0, 0), // changes position of shadow
                ),
              ],
            ),
            child: Stack(
              // clipBehavior: Clip.none,
              children: [
                QueryArtworkWidget(
                  id: int.parse(
                    realTimeInfo.current!.audio.audio.metas.id.toString(),
                  ),
                  type: ArtworkType.AUDIO,
                  keepOldArtwork: true,
                  artworkHeight: MediaQuery.of(context).size.height * 0.37,
                  artworkWidth: MediaQuery.of(context).size.height * 0.37,
                  artworkBorder: BorderRadius.circular(150),
                  artworkBlendMode: BlendMode.darken,
                  artworkFit: BoxFit.cover,
                  nullArtworkWidget: Container(
                    height: MediaQuery.of(context).size.height * 0.37,
                    width: MediaQuery.of(context).size.height * 0.37,
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 1,
                          blurRadius: 1,
                          // offset: Offset(0, 0), // changes position of shadow
                        ),
                      ],
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/M1 LOGO.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 3),
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey.shade300,
                          radius: 30,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 100,
                  right: 100,
                  top: 100,
                  bottom: 100,
                  child: Center(
                    child: Container(
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            spreadRadius: 1,
                            blurRadius: 1,
                            // offset: Offset(0, 0), // changes position of shadow
                          ),
                        ],
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.shade300,
                        radius: 30,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  // ================================================================================
  // Its 2 icons. Its used to add to favorites and add to playlist.

  buildFavoriteAddIconPlaylistAdd(context) {
    return controller.assetsAudioPlayer.builderRealtimePlayingInfos(
        builder: (context, realTimeInfo) {
      int currentIndex = songs!.indexWhere((element) =>
          element.id.toString() ==
          realTimeInfo.current!.audio.audio.metas.id.toString());

      var check = songs!.where((element) =>
          element.id.toString() ==
          realTimeInfo.current!.audio.audio.metas.id.toString());

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () async {
              print(check);

              bool isAdded = await audioRoom.checkIn(
                RoomType.FAVORITES,
                songs![currentIndex].id,
              );

              audioRoom.addTo(
                RoomType.FAVORITES,
                songs![currentIndex].getMap.toFavoritesEntity(),
                ignoreDuplicate: false,
              );

              if (isAdded == false) {
                Get.snackbar(
                  '',
                  '',
                  animationDuration: Duration(seconds: 2),
                  backgroundColor: Colors.white,
                  titleText: Text(
                    songs![currentIndex].title,
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
                Get.snackbar(
                  '',
                  '',
                  animationDuration: Duration(seconds: 2),
                  backgroundColor: Colors.white,
                  titleText: Text(
                    songs![currentIndex].title,
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
            },
            icon: FaIcon(
              FontAwesomeIcons.gratipay,
              size: 25,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.53,
          ),
          IconButton(
            onPressed: () {
              Get.to(
                SongsAddToPlaylist(songs: songs!, songsIndex: currentIndex),
              );
            },
            icon: const Icon(
              Icons.playlist_add,
              size: 35,
            ),
          ),
        ],
      );
    });
  }

  buildSongDuration(context) {
    return PlayerBuilder.currentPosition(
        player: controller.assetsAudioPlayer,
        builder: (context, duration) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                getTimeString(duration.inMilliseconds),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.53,
              ),
              controller.assetsAudioPlayer.builderRealtimePlayingInfos(
                  builder: (context, realTimeInfo) {
                return Text(
                    getTimeString(realTimeInfo.duration.inMilliseconds));
              })
            ],
          );
        });
  }

  // =====================================================================================
  // This is a Slider widget. Its a seek bar using to audio control and change the duration.

  buildSlider(context) {
    return controller.assetsAudioPlayer.builderRealtimePlayingInfos(
        builder: (context, relTimeInfo) {
      return GetBuilder<PlayingScreenController>(builder: (controller) {
        return Slider(
          activeColor: Colors.red.shade800,
          inactiveColor: Colors.white,
          value: relTimeInfo.currentPosition.inSeconds.toDouble(),
          onChanged: (value) {
            controller.changingSliderSeek(value.toDouble());
          },
          min: 0,
          max: relTimeInfo.duration.inSeconds.toDouble(),
        );
      });
    });
  }

  // =========================================================================================
  // Its 2 icons(shuffle,repeat). Its used to audio control to reperat and suffle.

  buildRepeatAndShuffleIcon(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GetBuilder<PlayingScreenController>(
          builder: (controller) => IconButton(
            onPressed: () {
              // controller.assetsAudioPlayer.loopMode;+

              controller.repeatSong();
              if (controller.repeat) {
                controller.assetsAudioPlayer.setLoopMode(LoopMode.single);
              } else {
                controller.assetsAudioPlayer.setLoopMode(LoopMode.none);
              }

              ;
            },
            icon: Icon(
              Icons.repeat,
              color: controller.repeat ? Colors.red.shade700 : null,
              size: 30,
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.53,
        ),
        GetBuilder<PlayingScreenController>(
          builder: (controller) => IconButton(
            onPressed: () {
              controller.shuffleSong();
              if (controller.shuffle) {
                controller.assetsAudioPlayer.toggleShuffle();
              }
            },
            icon: Icon(
              Icons.shuffle,
              color: controller.shuffle ? Colors.red.shade800 : null,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }

  // =============================================================================================
  // This is a play,pause,next,previous icons. Its used to play ,pause ,next ,previous.

  buildPauseAndPlayandFastForwardIcons(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          child: Icon(
            Icons.fast_rewind_sharp,
            size: 40,
          ),
          onTap: () {
            print('from previous');

            if (!controller.iconControl.isCompleted) {
              controller.iconControl.forward();
              controller.rotateController.repeat();
            }
            controller.assetsAudioPlayer.previous();
          },
          onDoubleTap: () {
            controller.assetsAudioPlayer.seekBy(Duration(seconds: -10));
          },
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
        ),
        controller.assetsAudioPlayer.builderIsPlaying(
          builder: (context, isPlaying) => GestureDetector(
            child: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              size: 45,
              progress: controller.iconControl,
            ),
            onTap: () => onIconPress(),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.10,
        ),
        controller.assetsAudioPlayer.builderRealtimePlayingInfos(
            builder: (context, realtimeInfos) {
          return GestureDetector(
            onDoubleTap: () {
              // controller.player.forwardOrRewind(10);
              controller.assetsAudioPlayer.seekBy(Duration(seconds: 10));
            },
            child: Icon(
              Icons.fast_forward_sharp,
              size: 40,
            ),
            onTap: () {
              if (!controller.iconControl.isCompleted) {
                controller.iconControl.forward();
                controller.rotateController.repeat();
              }
              controller.assetsAudioPlayer.next();
            },
          );
        }),
      ],
    );
  }

//  =========================================================================
// This function is a play pause animation controlling and rotate animation controlling.

  void onIconPress() {
    final aniState = controller.iconControl.status;

    if (aniState == AnimationStatus.completed) {
      controller.iconControl.reverse();
      controller.assetsAudioPlayer.playOrPause();
      controller.rotateController.stop();
    } else {
      controller.assetsAudioPlayer.play();
      controller.iconControl.forward();
      controller.rotateController.repeat();
    }
  }

  // ========================================================================================
  // This function is used to convert the song duration to MINUTE AND SECOND

  getTimeString(int milisec) {
    if (milisec == null) milisec = 0;
    String min =
        "${(milisec / 60000).floor() < 10 ? 0 : ''}${(milisec / 60000).floor()}";

    String sec =
        "${(milisec / 1000).floor() % 60 < 10 ? 0 : ''}${(milisec / 1000).floor() % 60}";

    return "$min:$sec";
  }

// =======================================================================================================================

}





























// // ignore_for_file: must_be_immutable

// import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hive/hive.dart';
// import 'package:music_player/getxfunctions.dart';
// import 'package:music_player/main.dart';
// import 'package:music_player/pages/home.dart';
// import 'package:on_audio_query/on_audio_query.dart';
// // import 'package:flutter/src/foundation/change_notifier.dart';

// class PlayingScreen extends GetView<PlayingScreenController> {
//   int index;
//   List<Audio>? convertedList;

//   PlayingScreen({
//     Key? key,
//     required this.convertedList,
//     required this.index,
//   }) : super(key: key);

//   var favourites = ValueNotifier([]);
//   final box = Hive.box(dbname);

//   Widget build(BuildContext context) {
//     Get.put(PlayingScreenController());

//     controller.onInit(index, convertedList);

//     // List keys = box.keys.toList();
//     // if (keys.where((element) => element == fav).isNotEmpty) {
//     //   favourites.value = box.get(fav);
//     // }

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//             onPressed: () {
//               Get.back(closeOverlays: true);
//               // favourites.notifyListeners();
//             },
//             icon: const Icon(Icons.arrow_back)),
//         title: const Text('Now Playing'),
//         centerTitle: true,
//       ),
//       body: GetBuilder<HomeController>(
//         builder: (control) => Column(
//           children: [
//             Column(
//               children: [
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height * 0.03,
//                 ),
//                 buildRotatePlayingImage(),
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height * 0.03,
//                 ),
//                 controller.assetsAudioPlayer.builderRealtimePlayingInfos(
//                     builder: (context, realtimeInfos) {
//                   return Text(
//                     controller.assetsAudioPlayer.getCurrentAudioTitle,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       overflow: TextOverflow.ellipsis,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   );
//                 }),
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height * 0.01,
//                 ),
//                 buildFavoriteAddIconPlaylistAdd(context),
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height * 0.01,
//                 ),
//                 buildSongDuration(context),
//                 buildSlider(context),
//                 buildRepeatAndShuffleIcon(context),
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height * 0.05,
//                 ),
//                 buildPauseAndPlayandFastForwardIcons(context),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ===================================================================================
//   // This is a audio playing image  and Rotate Animation.

//   buildRotatePlayingImage() {
//     return controller.assetsAudioPlayer.builderRealtimePlayingInfos(
//         builder: (context, realTimeInfo) {
//       return GetBuilder<PlayingScreenController>(
//         builder: (control) => RotationTransition(
//           turns: control.rotateAnimation,
//           child: Container(
//             decoration: const BoxDecoration(
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   spreadRadius: 1,
//                   blurRadius: 1,
//                   // offset: Offset(0, 0), // changes position of shadow
//                 ),
//               ],
//             ),
//             child: Stack(
//               // clipBehavior: Clip.none,
//               children: [
//                 QueryArtworkWidget(
//                   id: int.parse(
//                     realTimeInfo.current!.audio.audio.metas.id.toString(),
//                   ),
//                   type: ArtworkType.AUDIO,
//                   keepOldArtwork: true,
//                   artworkHeight: MediaQuery.of(context).size.height * 0.37,
//                   artworkWidth: MediaQuery.of(context).size.height * 0.37,
//                   artworkBorder: BorderRadius.circular(150),
//                   artworkBlendMode: BlendMode.darken,
//                   artworkFit: BoxFit.cover,
//                   nullArtworkWidget: Container(
//                     height: MediaQuery.of(context).size.height * 0.37,
//                     width: MediaQuery.of(context).size.height * 0.37,
//                     decoration: const BoxDecoration(
//                       boxShadow: [
//                         BoxShadow(
//                           spreadRadius: 1,
//                           blurRadius: 1,
//                           // offset: Offset(0, 0), // changes position of shadow
//                         ),
//                       ],
//                       shape: BoxShape.circle,
//                       image: DecorationImage(
//                         image: AssetImage('assets/images/M1 LOGO.png'),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     child: Center(
//                       child: CircleAvatar(
//                         backgroundColor: Colors.grey.shade300,
//                         radius: 30,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   left: 100,
//                   right: 100,
//                   top: 100,
//                   bottom: 100,
//                   child: Center(
//                     child: CircleAvatar(
//                       backgroundColor: Colors.grey.shade300,
//                       radius: 30,
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       );
//     });
//   }

//   // ================================================================================
//   // Its 2 icons. Its used to add to favorites and add to playlist.

//   buildFavoriteAddIconPlaylistAdd(context) {
//     return controller.assetsAudioPlayer.builderRealtimePlayingInfos(
//       builder: (context, realTimeInfo) => ValueListenableBuilder(
//           valueListenable: favourites,
//           builder: (context, List addFav, _) {
//             return GetBuilder<HomeController>(
//               builder: (control) => Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   IconButton(onPressed: () {}, icon: Icon(Icons.favorite)),
//                   // favourites.value
//                   //         .where((element) =>
//                   //             element.id.toString() ==
//                   //             realTimeInfo.current!.audio.audio.metas.id
//                   //                 .toString())
//                   //         .isEmpty
//                   //     ? IconButton(
//                   //         onPressed: () async {
//                   //           List allSongs = box.get('allSongs');

//                   //           int index = allSongs.indexWhere((element) =>
//                   //               element.id.toString() ==
//                   //               realTimeInfo.current!.audio.audio.metas.id
//                   //                   .toString());

//                   //           if (favourites.value
//                   //               .where(
//                   //                 (element) =>
//                   //                     element.id.toString() ==
//                   //                     control.dataBaseList.value[index].id
//                   //                         .toString(),
//                   //               )
//                   //               .isEmpty) {
//                   //             favourites.value
//                   //                 .add(control.dataBaseList.value[index]);
//                   //             favourites.notifyListeners();
//                   //             await box.put(fav, favourites.value);
//                   //           }

//                   //           Get.snackbar(
//                   //             '',
//                   //             'Song Added to Liked Songs',
//                   //             backgroundColor: Colors.white,
//                   //             titleText: Text(
//                   //               allSongs[index].title,
//                   //               maxLines: 2,
//                   //               style: TextStyle(color: Colors.black),
//                   //             ),
//                   //           );
//                   //         },
//                   //         icon: Icon(
//                   //           Icons.favorite_border,
//                   //           // color: Colors.red,
//                   //           size: 30,
//                   //         ),
//                   //       )
//                   //     : IconButton(
//                   //         onPressed: () async {
//                   //           // List favsong = box.get(fav);

//                   //           var index2 = favsong.indexWhere((element) =>
//                   //               element.id.toString() ==
//                   //               realTimeInfo.current!.audio.audio.metas.id
//                   //                   .toString());

//                   //           Get.snackbar(
//                   //             '',
//                   //             'Song Removed to Liked Songs',
//                   //             backgroundColor: Colors.white,
//                   //             overlayColor: Colors.red,
//                   //             titleText: Text(
//                   //               favsong[index2].title,
//                   //               maxLines: 2,
//                   //             ),
//                   //           );

//                   //           favourites.value.remove(favourites.value[index2]);

//                   //           favourites.notifyListeners();

//                   //           await box.put(fav, favourites.value);
//                   //         },
//                   //         icon: Icon(
//                   //           Icons.favorite,
//                   //           color: Colors.red.shade900,
//                   //           size: 30,
//                   //         )),
//                   SizedBox(
//                     width: MediaQuery.of(context).size.width * 0.53,
//                   ),
//                   IconButton(
//                     onPressed: () {
//                       Get.bottomSheet(Container(
//                         color: Colors.white,
//                         child: Column(
//                           children: [
//                             TextField(),
//                             ListTile(
//                               leading: const Text('Malayalam'),
//                               onTap: () {},
//                             ),
//                             ListTile(
//                               leading: const Text('English'),
//                               onTap: () {},
//                             ),
//                             ListTile(
//                               leading: const Text('Malayalam'),
//                               onTap: () {},
//                             ),
//                           ],
//                         ),
//                       ));
//                     },
//                     icon: Icon(
//                       Icons.playlist_add,
//                       size: 35,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }),
//     );
//   }

//   buildSongDuration(context) {
//     return PlayerBuilder.currentPosition(
//         player: controller.assetsAudioPlayer,
//         builder: (context, duration) {
//           return Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Text(
//                 getTimeString(duration.inMilliseconds),
//               ),
//               SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.53,
//               ),
//               controller.assetsAudioPlayer.builderRealtimePlayingInfos(
//                   builder: (context, realTimeInfo) {
//                 return Text(
//                     getTimeString(realTimeInfo.duration.inMilliseconds));
//               })
//             ],
//           );
//         });
//   }

//   // =====================================================================================
//   // This is a Slider widget. Its a seek bar using to audio control and change the duration.

//   buildSlider(context) {
//     return controller.assetsAudioPlayer.builderRealtimePlayingInfos(
//         builder: (context, relTimeInfo) {
//       return GetBuilder<PlayingScreenController>(builder: (controller) {
//         return Slider(
//           activeColor: Colors.red.shade800,
//           inactiveColor: Colors.white,
//           value: relTimeInfo.currentPosition.inSeconds.toDouble(),
//           onChanged: (value) {
//             controller.changingSliderSeek(value.toDouble());
//           },
//           min: 0,
//           max: relTimeInfo.duration.inSeconds.toDouble(),
//         );
//       });
//     });
//   }

//   // =========================================================================================
//   // Its 2 icons(shuffle,repeat). Its used to audio control to reperat and suffle.

//   buildRepeatAndShuffleIcon(context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         IconButton(
//           onPressed: () {
//             // controller.assetsAudioPlayer.loopMode;
//           },
//           icon: Icon(
//             Icons.repeat,
//             size: 30,
//           ),
//         ),
//         SizedBox(
//           width: MediaQuery.of(context).size.width * 0.53,
//         ),
//         IconButton(
//           onPressed: () {
//             // controller.assetsAudioPlayer.loopMode;
//             // print('shuffle');
//           },
//           icon: Icon(
//             Icons.shuffle,
//             size: 30,
//           ),
//         ),
//       ],
//     );
//   }

//   // =============================================================================================
//   // This is a play,pause,next,previous icons. Its used to play ,pause ,next ,previous.

//   buildPauseAndPlayandFastForwardIcons(context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         GestureDetector(
//           child: Icon(
//             Icons.fast_rewind_sharp,
//             size: 40,
//           ),
//           onTap: () {
//             print('from previous');

//             if (!controller.iconControl.isCompleted) {
//               controller.iconControl.forward();
//               controller.rotateController.repeat();
//             }
//             controller.assetsAudioPlayer.previous();
//           },
//           onDoubleTap: () {
//             controller.assetsAudioPlayer.seekBy(Duration(seconds: -10));
//             print('mansoor');
//           },
//         ),
//         SizedBox(
//           width: MediaQuery.of(context).size.width * 0.1,
//         ),
//         GestureDetector(
//           child: AnimatedIcon(
//             icon: AnimatedIcons.play_pause,
//             size: 45,
//             progress: controller.iconControl,
//           ),
//           onTap: () => onIconPress(),
//         ),
//         SizedBox(
//           width: MediaQuery.of(context).size.width * 0.10,
//         ),
//         controller.assetsAudioPlayer.builderRealtimePlayingInfos(
//             builder: (context, realtimeInfos) {
//           return GestureDetector(
//               onDoubleTap: () {
//                 // controller.player.forwardOrRewind(10);
//                 controller.assetsAudioPlayer.seekBy(Duration(seconds: 10));
//               },
//               child: Icon(
//                 Icons.fast_forward_sharp,
//                 size: 40,
//               ),
//               onTap: () {
//                 if (!controller.iconControl.isCompleted) {
//                   controller.iconControl.forward();
//                   controller.rotateController.repeat();
//                 }
//                 controller.assetsAudioPlayer.next();
//               });
//         }),
//       ],
//     );
//   }

// //  =========================================================================
// // This function is a play pause animation controlling and rotate animation controlling.

//   void onIconPress() {
//     final aniState = controller.iconControl.status;

//     if (aniState == AnimationStatus.completed) {
//       controller.iconControl.reverse();
//       controller.assetsAudioPlayer.playOrPause();
//       controller.rotateController.stop();
//     } else {
//       controller.assetsAudioPlayer.play();
//       controller.iconControl.forward();
//       controller.rotateController.repeat();
//     }
//   }

//   // ========================================================================================
//   // This function is used to convert the song duration to MINUTE AND SECOND

//   getTimeString(int milisec) {
//     if (milisec == null) milisec = 0;
//     String min =
//         "${(milisec / 60000).floor() < 10 ? 0 : ''}${(milisec / 60000).floor()}";

//     String sec =
//         "${(milisec / 1000).floor() % 60 < 10 ? 0 : ''}${(milisec / 1000).floor() % 60}";

//     return "$min:$sec";
//   }
// }
