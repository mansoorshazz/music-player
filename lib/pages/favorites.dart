
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player_project/getxfunctions.dart';
import 'package:music_player_project/pages/playing_screen.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:on_audio_room/on_audio_room.dart';

class FavoritePage extends StatefulWidget {
  FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final List<Audio> convertList = [];

  final OnAudioRoom _audioRoom = OnAudioRoom();


  

  @override
  Widget build(BuildContext context) {
    Get.put(FavoritesController());
    Get.put(HomeController());

 

    return Scaffold(
      appBar: buildAppBar(),
      body: FutureBuilder<List<FavoritesEntity>>(
          future: OnAudioRoom().queryFavorites(
            limit: 100,
            // reverse: false,
          ),
          builder: (context, item) {
            if (item.data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (item.data!.isEmpty) {
              return Center(
                child: AnimatedTextKit(
                  repeatForever: true,
                  animatedTexts: [
                    WavyAnimatedText('No Songs',
                        textStyle: TextStyle(fontSize: 15)),
                    // WavyAnimatedText('Add songs to Favourites'),
                  ],
                ),
              );
            }

            List<FavoritesEntity> favorites = item.data!;

            return ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white24,
                    ),
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: Center(
                      child: GetBuilder<HomeController>(
                        builder: (controller) => ListTile(
                          iconColor: Colors.red.shade900,
                          // =================================================================
                          leading:
                              buildListTileLeading(favorites, index, context),
                          // ===================================================================
                          title: Text(
                            favorites[index].title,
                            maxLines: 2,
                          ),
                          // ==================================================================
                          trailing: buildListTileTrailing(favorites, index),
                          // ================================================================
                          onTap: () {
                            convertAudioFile(favorites);
                            Get.to(
                              PlayingScreen(
                                index: index,
                                convertedList: convertList,
                                songs: controller.fechsongsall,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
    );
  }

  buildAppBar() {
    return AppBar(
      title: const Text('My Favourites'),
      centerTitle: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.red.shade800,
    );
  }

  //  ===========================================================================================
  buildListTileLeading(image, index, context) {
    return QueryArtworkWidget(
      id: image[index].id,
      type: ArtworkType.AUDIO,
      artworkWidth: MediaQuery.of(context).size.width * 0.15,
      artworkHeight: MediaQuery.of(context).size.height * 0.14,
      artworkBorder: BorderRadius.circular(7),
      keepOldArtwork: true,
      // artworkClipBehavior: Clip.none,
      nullArtworkWidget: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          image: const DecorationImage(
            image: AssetImage(
              'assets/images/ilovemusic.jpg',
            ),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        width: MediaQuery.of(context).size.width * 0.15,
        height: MediaQuery.of(context).size.height * 0.14,
      ),
    );
  }

  // ==============================================================================
  buildListTileTrailing(favorites, index) {
    return GetBuilder<FavoritesController>(
      builder: (control) {
        return IconButton(
          onPressed: () async {
            showDialog(
                context: context,
                builder: (BuildContext context) => CupertinoAlertDialog(
                      title: Text("Remove Song ?"),
                      content: Text("Are you sure ?"),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          onPressed: () async {
                            await _audioRoom.deleteFrom(
                              RoomType.FAVORITES,
                              favorites[index].key,
                            );
                            Get.back();
                            setState(() {});
                          },
                          isDefaultAction: true,
                          child: Text(
                            'Yes',
                            style: TextStyle(color: Colors.green.shade600),
                          ),
                        ),
                        CupertinoDialogAction(
                          onPressed: () => Get.back(),
                          child: Text(
                            "No",
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                        )
                      ],
                    ));
            // controller.iconChanging(index);

            // control.deleteSong(favorites, index);
          },
          icon: Icon(
            Icons.favorite,
          ),
        );
      },
    );
  }

  //===================================================================================
  convertAudioFile(List<FavoritesEntity> favorites) {
    for (var item in favorites) {
      convertList.add(
        Audio.file(
          item.lastData,
          metas: Metas(
            id: item.id.toString(),
            title: item.title,
          ),
        ),
      );
    }
  }
}






















// import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:music_player/getxfunctions.dart';
// import 'package:music_player/main.dart';
// import 'package:music_player/pages/home.dart';
// import 'package:music_player/pages/playing_screen.dart';
// // import 'package:on_audio_room/details/rooms/favorites/favorites_entity.dart';
// import 'package:hive/hive.dart';
// import 'package:on_audio_query/on_audio_query.dart';

// class FavoritePage extends StatelessWidget {
//   FavoritePage({Key? key}) : super(key: key);

//   final box = Hive.box(dbname);

//   final favoritesAllSongs = ValueNotifier([]);

//   List<Audio> convertFavSongs = [];

//   @override
//   Widget build(BuildContext context) {
//     // List _keys = box.keys.toList();
//     // if (_keys.where((element) => element == fav).isNotEmpty) {
//     //   favoritesAllSongs.value = box.get(fav);
//     // }

//     return Scaffold(
//       appBar: buildAppBar(),
//       body: ValueListenableBuilder(
//         valueListenable: favoritesAllSongs,
//         builder: (BuildContext context, List favorites, _) {
//           // if (favorites.value == null) {
//           //   return Center(child: CircularProgressIndicator());
//           // }
//           List favList = favorites.toList();

//           if (favoritesAllSongs.value.isEmpty) {
//             return const Center(
//               child: Text(
//                 'No songs',
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             );
//           }

//           return ListView.builder(
//             itemBuilder: (BuildContext context, int index) {
//               return Container(
//                 margin:
//                     const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 3),
//                 decoration: BoxDecoration(
//                   color: Colors.white30,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 height: MediaQuery.of(context).size.height * 0.1,
//                 child: Center(
//                   child: ListTile(
//                     title: Text(
//                       favList[index].title,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     leading: buildListTileLeading(favList, index, context),
//                     trailing: IconButton(
//                       onPressed: () async {
//                         // favoritesAllSongs.value
//                         //     .remove(favoritesAllSongs.value[index]);
//                         // favoritesAllSongs.notifyListeners();
//                         // await box.put(fav, favoritesAllSongs.value);
//                       },
//                       icon: const Icon(Icons.favorite_rounded),
//                       color: Colors.red.shade900,
//                     ),
//                     // ================================================================
//                     onTap: () {
//                       for (var item in favList) {
//                         convertFavSongs.add(
//                           Audio.file(item.uri.toString(),
//                               metas: Metas(
//                                 id: item.id.toString(),
//                                 title: item.title,
//                               )),
//                         );
//                       }
//                       Get.to(
//                         PlayingScreen(
//                           convertedList: convertFavSongs,
//                           index: index,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               );
//             },
//             itemCount: favorites.length,
//           );
//         },
//       ),
//     );
//   }

//   buildAppBar() {
//     return AppBar(
//       title: const Text('Favourites'),
//       centerTitle: true,
//       backgroundColor: Colors.red.shade700,
//     );
//   }

//   //  ===========================================================================================
//   // This is a ListTile Leading Property. Its used to show a images of favorites audios.
//   buildListTileLeading(image, index, context) {
//     return QueryArtworkWidget(
//       id: image[index].id,
//       type: ArtworkType.AUDIO,
//       artworkWidth: MediaQuery.of(context).size.width * 0.15,
//       artworkHeight: MediaQuery.of(context).size.height * 0.14,
//       artworkBorder: BorderRadius.circular(7),
//       keepOldArtwork: true,
//       // artworkClipBehavior: Clip.none,
//       nullArtworkWidget: Container(
//         decoration: BoxDecoration(
//           color: Colors.transparent,
//           image: const DecorationImage(
//             image: AssetImage(
//               'assets/images/M1 LOGO.png',
//             ),
//             fit: BoxFit.cover,
//           ),
//           borderRadius: BorderRadius.circular(7),
//         ),
//         width: MediaQuery.of(context).size.width * 0.15,
//         height: MediaQuery.of(context).size.height * 0.14,
//       ),
//     );
//   }

//   // ==============================================================================
//   // This is a ListTile Trailing Property. Its used to remove from favorites songs.

//   buildListTileTrailing() {
//     return GetBuilder<IconChanging>(builder: (controller) {
//       return IconButton(
//           onPressed: () {
//             // controller.iconChanging(index);
//           },
//           icon: Icon(
//             controller.isChanged ? Icons.favorite : Icons.favorite,
//             size: 30,
//             color: controller.clr,
//           ));
//     });
//   }

//   convertAudioFile(List favList) {
//     // for (var item in favList) {
//     //   convertFavSongs.add(
//     //     Audio.file(item.uri.toString(),
//     //         metas: Metas(
//     //           id: item.id.toString(),
//     //           title: item.title,
//     //         )),
//     //   );
//     // }
//   }
// }
