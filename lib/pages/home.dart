// ignore_for_file: must_be_immutable, prefer_const_constructors

import 'package:assets_audio_player/assets_audio_player.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:music_player_project/database/database.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:music_player/database/database.dart';
// import 'package:music_player/main.dart';

import 'package:music_player_project/getxfunctions.dart';

import 'package:music_player_project/pages/playing_screen.dart';

import 'package:music_player_project/pages/songs_add_to_playlist.dart';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:on_audio_room/on_audio_room.dart';

import 'search.dart';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  List<Audio> convertedList = [];

  OnAudioRoom audioRoom = OnAudioRoom();

  @override
  Widget build(BuildContext context) {
    TextEditingController playListController = TextEditingController();
    Get.put(IconChanging());
    final controller = Get.put(HomeController());

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Home'),
          backgroundColor: Colors.teal,
          actions: [
            GetBuilder<HomeController>(
              builder: (control) => IconButton(
                onPressed: () {
                  control.changeHomeBody();
                },
                icon: Icon(control.changingGridview
                    ? Icons.grid_view_sharp
                    : Icons.list),
              ),
            ),
            IconButton(
              onPressed: () {
                showSearch(
                    context: context,
                    delegate:
                        CustomSearchDelegate(songs: controller.fechsongsall));
              },
              icon: const Icon(Icons.search),
            )
          ],
        ),
        body: GetBuilder<HomeController>(
          builder: (controller) => FutureBuilder<List<SongModel>>(
            future: controller.audioQuery.querySongs(
              sortType: null,
            ),
            builder: (context, item) {
              if (item.data == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (item.data!.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              List<SongModel>? songs = item.data;

              return Column(
                children: [
                  Expanded(
                    child: CupertinoScrollbar(
                      child: controller.changingGridview
                          ? ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: songs!.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(
                                      left: 8, right: 8, top: 8, bottom: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                  child: Center(
                                    child: ListTile(
                                      // ================================================================
                                      leading: buildListTileLeading(
                                        songs,
                                        index,
                                        context,
                                      ),

                                      // ================================================================

                                      title: buildListTileTitle(
                                        songs,
                                        index,
                                        max: 1,
                                      ),
                                      subtitle: Text(
                                        songs[index].album.toString(),
                                        maxLines: 1,
                                      ),
                                      // ================================================================

                                      trailing: popmenuButton(
                                          index, songs, playListController),

                                      // ===================================================================

                                      onTap: () {
                                        convertAudioFile(controller);

                                        Get.to(
                                          PlayingScreen(
                                            index: index,
                                            convertedList: convertedList,
                                            songs: songs,
                                          ),
                                          transition: Transition.leftToRight,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            )
                          : GridView.builder(
                              physics: BouncingScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 7 / 8,
                              ),
                              itemCount: songs!.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      convertAudioFile(controller);
                                      Get.to(
                                        PlayingScreen(
                                          index: index,
                                          convertedList: convertedList,
                                          songs: songs,
                                        ),
                                        transition: Transition.leftToRight,
                                      );
                                    },
                                    child: gridViewGridTile(songs, index,
                                        context, playListController),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ));
  }

//==================================================================================
//This widget is GridTile. Its used to add to favorites and add to playlist.

  GridTile gridViewGridTile(List<SongModel> songs, int index,
      BuildContext context, TextEditingController playlistController) {
    return GridTile(
      header: ListTile(
        trailing: GetBuilder<HomeController>(
          builder: (control) => Wrap(
            children: [
              IconButton(
                onPressed: () async {
                  bool isAdded = await audioRoom.checkIn(
                    RoomType.FAVORITES,
                    songs[index].id,
                  );

                  await audioRoom.addTo(
                    RoomType.FAVORITES,
                    songs[index].getMap.toFavoritesEntity(),
                    ignoreDuplicate: false,
                  );

                  control.addToFavorites(songs, index, isAdded);
                },
                icon: Icon(Icons.favorite, color: Colors.white),
              ),
              IconButton(
                  onPressed: () {
                    Get.to(SongsAddToPlaylist(songs: songs, songsIndex: index));
                  },
                  icon: Icon(Icons.playlist_add),
                  color: Colors.white)
            ],
          ),
        ),
      ),
      footer: Container(
        height: 30,
        color: Colors.white24,
        child: Center(
          child: buildListTileTitle(songs, index, color: Colors.white, max: 1),
        ),
      ),
      child: buildListTileLeading(songs, index, context),
    );
  }

  // ======================================================================================
  // This widget is a popUpMenuButton. Its used to show the PopMenuButton.

  PopupMenuButton<dynamic> popmenuButton(
      int index, List<SongModel> songs, playlistNameController) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        popMenuItemFavorite(index, songs),
        popMenuItemPlaylist(index, songs, context, playlistNameController),
      ],
    );
  }

  // =====================================================================================+
  // This widget is a popmenuItem. Its used to add to playlist.

  PopupMenuItem<dynamic> popMenuItemPlaylist(
      index, List<SongModel> songs, context, playlistNameController) {
    return PopupMenuItem(
      child: GetBuilder<IconChanging>(builder: (controller) {
        return ListTile(
          title: Text('Add to playlist'),
          trailing: Icon(Icons.playlist_add),
          // iconColor: Colors.red,
          onTap: () {
            Get.back();
            Get.to(SongsAddToPlaylist(songs: songs, songsIndex: index));
            // playListBottomSheet(index, songs, context, playlistNameController);
          },
        );
      }),
    );
  }

//  ===============================================================================================
// This widget is a popmenuItem. Its used to add to favoritess.

  PopupMenuItem<dynamic> popMenuItemFavorite(int index, List<SongModel> songs) {
    return PopupMenuItem(
      child: GetBuilder<HomeController>(builder: (control) {
        // bool isAdded =  audioRoom.checkIn(
        //       RoomType.FAVORITES,
        //       songs[index].id,
        //     );

        return ListTile(
          title: const Text('Add to favourites'),
          trailing: const Icon(Icons.favorite),
          // iconColor: Colors.black,
          onTap: () async {
            // controller.iconChanging(index);

            // print(songs.where((element) => element.id);

            bool isAdded = await audioRoom.checkIn(
              RoomType.FAVORITES,
              songs[index].id,
            );

            audioRoom.addTo(
              RoomType.FAVORITES,
              songs[index].getMap.toFavoritesEntity(),
              ignoreDuplicate: false,
            );

            control.addToFavorites(songs, index, isAdded);
          },
        );
      }),
    );
  }

// ==================================================================================
  convertAudioFile(controller) {
    for (var item in controller.fechsongsall) {
      convertedList.add(
        Audio.file(
          item.uri.toString(),
          metas: Metas(
            id: item.id.toString(),
            title: item.title,
          ),
        ),
      );
    }
  }

// ========================================================================================
  buildListTileLeading(
    image,
    index,
    context,
  ) {
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
              'assets/images/512x512bb.jpg',
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

// ======================================================================================
  buildListTileTitle(title, index, {color, max}) {
    return Text(
      title[index].title,
      overflow: TextOverflow.ellipsis,
      maxLines: max,
      style: TextStyle(
        color: color,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.bold,
      ),
    );
  }

// =============================================================================

}

// // ignore_for_file: must_be_immutable

// import 'package:assets_audio_player/assets_audio_player.dart';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:music_player/database/database.dart';
// import 'package:music_player/main.dart';

// import 'package:music_player/getxfunctions.dart';
// import 'package:music_player/pages/playing_screen.dart';

// import 'package:on_audio_query/on_audio_query.dart';

// import 'search.dart';

// String fav = 'favourites';

// final audios = <Audio>[
//   Audio(
//     'assets/audios/Thee Minnal Lyric Video _ Minnal Murali _ Tovino Thomas _ Basil Joseph _ Sushin Shyam _ Sophia Paul.mp3',
//     metas: Metas(
//       id: '1',
//       title: 'Thee Minnal Thudangi',
//       image: MetasImage.asset(
//         'assets/images/FDwo7IhWUAowcxI.jpg',
//       ),
//     ),
//   ),
//   Audio(
//     'assets/audios/Pakaliravukal - Video Song _ Kurup _ Dulquer Salmaan _ Sobhita Dhulipala _ Sushin Shyam _ Anwar Ali.mp3',
//     metas: Metas(
//       id: '2',
//       title: 'Pakalirukalaal | KURUPP  ',
//       image: MetasImage.asset(
//         'assets/images/MV5BMDVlMjg4ZDAtYzI4Yi00NzA3LTk0N2YtYTMwODBlYTY2YmI1XkEyXkFqcGdeQXVyMTA3MDk2NDg2._V1_.jpg',
//       ),
//     ),
//   ),
//   Audio(
//     'assets/audios/Angamaly Diaries _ Thana Dhina Video Song _ Lijo Jose Pellissery _ Prashant Pillai _ Official.mp3',
//     metas: Metas(
//       id: '3',
//       title: 'Thana Dhina | Angamali Diaries',
//       image: MetasImage.asset(
//         'assets/images/47762149_500_500.jpg',
//       ),
//     ),
//   ),
// ];

// // String dbname = 'music';
// // final boxHive = Hive.box<SongModel>(dbname);

// // final boxHive = Hive.box(dbname);

// class Home extends GetView<HomeController> {
//   List<Audio> convertedList = [];
//   List favorites = [];

//   final box = Hive.box(dbname);

//   Home({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     List _keys = box.keys.toList();
//     if (_keys.where((element) => element == fav).isNotEmpty) {
//       favorites = box.get(fav);
//     }

//     Get.put(IconChanging());

//     Get.put(HomeController());

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//         backgroundColor: Colors.teal,
//         actions: [
//           IconButton(
//             onPressed: () {
//               controller.changeHomeBody();
//             },
//             icon: Icon(Icons.switch_left),
//           ),
//           IconButton(
//             onPressed: () {
//               showSearch(context: context, delegate: CustomSearchDelegate());
//             },
//             icon: const Icon(Icons.search),
//           )
//         ],
//       ),
//       body: ValueListenableBuilder(
//         valueListenable: controller.dataBaseList,
//         builder:
//             (BuildContext context, List<SongsModel> databaseList, Widget? _) {
//           final data = databaseList;
//           return GetBuilder<HomeController>(
//             builder: (controller) => FutureBuilder<List<SongModel>>(
//               future: controller.audioQuery.querySongs(
//                 sortType: null,
//               ),
//               builder: (context, item) {
//                 if (item.data == null) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (item.data!.isEmpty) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 return CupertinoScrollbar(
//                   child: controller.changingGridview
//                       ? ListView.builder(
//                           itemCount: data.length,
//                           itemBuilder: (context, index) {
//                             final data = databaseList;

//                             return Container(
//                               margin: const EdgeInsets.only(
//                                   left: 8, right: 8, top: 8, bottom: 3),
//                               decoration: BoxDecoration(
//                                 color: Colors.white12,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               height: MediaQuery.of(context).size.height * 0.1,
//                               child: Center(
//                                 child: ListTile(
//                                   // ================================================================
//                                   leading: buildListTileLeading(
//                                       data, index, context),
//                                   // ================================================================
//                                   title: buildListTileTitle(data, index),
//                                   // ================================================================
//                                   trailing: popUpMenuButton(index),

//                                   // ===================================================================
//                                   onTap: () {
//                                     convertAudioFile();
//                                     Get.to(
//                                       PlayingScreen(
//                                         index: index,
//                                         convertedList: convertedList,
//                                       ),
//                                       transition: Transition.leftToRight,
//                                     );
//                                   },
//                                 ),
//                               ),
//                             );
//                           },
//                         )
//                       : GridView.builder(
//                           gridDelegate:
//                               const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             // crossAxisSpacing: 2,
//                             // mainAxisSpacing: 2,
//                           ),
//                           itemCount: data.length,
//                           itemBuilder: (context, index) {
//                             return Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: GestureDetector(
//                                 onTap: () {
//                                   convertAudioFile();
//                                   Get.to(
//                                     PlayingScreen(
//                                       index: index,
//                                       convertedList: convertedList,
//                                     ),
//                                     transition: Transition.leftToRight,
//                                   );
//                                 },
//                                 child: GridTile(
//                                     header: ListTile(
//                                       trailing: SizedBox(
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 0.07,
//                                         child: PopupMenuButton(
//                                           itemBuilder: (context) {
//                                             return popUpMenuButton(index);
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                     footer: Container(
//                                       height: 30,
//                                       color: Colors.white24,
//                                       child: Center(
//                                         child: buildListTileTitle(data, index),
//                                       ),
//                                     ),
//                                     child: buildListTileLeading(
//                                         data, index, context)),
//                               ),
//                             );
//                           },
//                         ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }

//   //  =======================================================================================
//   // Returning List of popmenuItems. Its using to add to favorites and add to playlist.

//   popUpMenuButton(index) {
//     return PopupMenuButton(itemBuilder: (context) {
//       return [
//         PopupMenuItem(
//           child: GetBuilder<IconChanging>(
//             builder: (control) {
//               return ListTile(
//                 title: Text('Add to favorites'),
//                 trailing: Icon(Icons.favorite),
//                 iconColor: favorites
//                         .where((element) =>
//                             element.id.toString() ==
//                             controller.dataBaseList.value[index].id.toString())
//                         .isEmpty
//                     ? Colors.black
//                     : Colors.red,
//                 onTap: () async {
//                   if (favorites
//                       .where((element) =>
//                           element.id.toString() ==
//                           controller.dataBaseList.value[index].id.toString())
//                       .isEmpty) {
//                     Get.back();

//                     favorites.add(controller.dataBaseList.value[index]);

//                     await box.put(fav, favorites);

//                     Get.snackbar(
//                       controller.dataBaseList.value[index].title,
//                       'Added to Liked songs',
//                       backgroundColor: Colors.white,
//                       duration: Duration(seconds: 2),
//                     );
//                     // control
//                     //     .iconChanging(index);
//                     print(favorites);
//                   } else {
//                     // print(favorites);
//                     Get.back();
//                     print('mansoor');
//                     Get.snackbar(
//                       controller.dataBaseList.value[index].title,
//                       'Song already added',
//                       backgroundColor: Colors.white,
//                       duration: Duration(seconds: 2),
//                     );
//                   }

//                   // if (favorites.where(
//                   //         (element) =>
//                   //             element.id) ==
//                   //     controller.dataBaseList
//                   //         .value[index].id
//                   //         .toString()
//                   //         .isEmpty) {
//                   //   await box.put(
//                   //       fav, favorites);

//                   //   print(favorites);
//                   //   control
//                   //       .iconChanging(index);
//                   // } else {
//                   //   print('+++++++');
//                   //   print(favorites);
//                   // }
//                 },
//               );
//             },
//           ),
//         ),
//         PopupMenuItem(
//           child: GetBuilder<IconChanging>(builder: (controller) {
//             return ListTile(
//               title: Text('Add to playlist'),
//               trailing: Icon(Icons.playlist_add),
//               // iconColor: Colors.red,
//               onTap: () {
//                 print(favorites);
//                 Get.bottomSheet(Container(
//                   color: Colors.white,
//                   child: Column(
//                     children: [
//                       TextField(
//                         decoration:
//                             InputDecoration(hintText: 'Create New Playlist'),
//                       ),
//                       ListTile(
//                         leading: Text('Malayalam'),
//                         onTap: () {},
//                       ),
//                       ListTile(
//                         leading: Text('English'),
//                         onTap: () {},
//                       ),
//                       ListTile(
//                         leading: Text('Malayalam'),
//                         onTap: () {},
//                       ),
//                     ],
//                   ),
//                 ));
//               },
//             );
//           }),
//         ),
//       ];
//     });
//   }

// // ==================================================================================
// // This  function used to List of SongMOdel convert to Audio file to add ConvertList.

//   convertAudioFile() {
//     for (var item in controller.fechsongsall) {
//       convertedList.add(
//         Audio.file(
//           item.uri.toString(),
//           metas: Metas(
//             id: item.id.toString(),
//             title: item.title,
//           ),
//         ),
//       );
//     }
//   }

// // ============================================================================================
// // This is a ListTile Leading Widget. Its used to show a images of audios.

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

// // ======================================================================================
// // This is a ListTile Title property. Its used to show a audios names.

//   buildListTileTitle(title, index) {
//     return GetBuilder<HomeController>(
//       builder: (controller) => Text(
//         title[index].title,
//         overflow: TextOverflow.ellipsis,
//         maxLines: 2,
//         style: TextStyle(
//           // color: controller.changingGridview ?Colors.white : Colors.red,
//           color: controller.changingGridview ? null : Colors.white,
//           fontFamily: 'Roboto',
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

// // =========================================================================================

// }
