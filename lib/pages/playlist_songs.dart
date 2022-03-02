import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player_project/controllers/add_songs_to_playlist.dart';
import 'package:music_player_project/getxfunctions.dart';
import 'package:music_player_project/pages/add_songs_to_playlist.dart';
import 'package:music_player_project/pages/bottomnavbar.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:on_audio_room/details/rooms/favorites/favorites_entity.dart';
import 'package:on_audio_room/details/rooms/song_entity.dart';
import 'package:on_audio_room/on_audio_room.dart';
import 'home.dart';
import 'playing_screen.dart';

class PlayListSongs extends StatelessWidget {
  final dynamic playListName;
  final int playListKey;

   PlayListSongs({
    Key? key,
    this.playListName,
    required this.playListKey,
  }) : super(key: key);

 
  final List<Audio> convertedList = [];

  // final controller = Get.put(HomeController());

  final OnAudioRoom audioRoom = OnAudioRoom();
  final OnAudioQuery audioQuery = OnAudioQuery();

  @override
  Widget build(BuildContext context) {
    Get.put(AddSongPlaylistController(), permanent: true);
    
    return GetBuilder<AddSongPlaylistController>(
      builder: (control) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Get.to(
                BottomNavBar(),
              );
            },
            icon: Icon(Icons.arrow_back),
          ),
          title: Text(playListName),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: () {
            Get.bottomSheet(
              Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Add songs to ${playListName}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: FutureBuilder<List<SongModel>>(
                      future: audioQuery.querySongs(
                        sortType: null,
                      ),
                      builder: (context, item) {
                        if (item.data == null) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (item.data!.isEmpty) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        List<SongModel>? songs = item.data;

                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ListView.separated(
                            itemCount: songs!.length,
                            itemBuilder: (context, index) {
                              return Center(
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
                                    color: Colors.black,
                                  ),

                                  // ================================================================
                                  // trailing: popmenuButton(index, songs),

                                  // ===================================================================

                                  onTap: () async {
                                    bool isAdded = await audioRoom.checkIn(
                                      RoomType.PLAYLIST,
                                      songs[index].id,
                                      playlistKey: playListKey,
                                    );

                                    control.songAddingPlaylist(
                                      index: index,
                                      playListkey: playListKey,
                                      songs: songs,
                                    );
                                    // audioRoom.addTo(
                                    //   RoomType.PLAYLIST,
                                    //   songs[index].getMap.toSongEntity(),
                                    //   playlistKey: widget.playListKey,
                                    //   ignoreDuplicate: true,
                                    // );
                                    // setState(() {});
                                    // Get.to(
                                    //   PlayingScreen(
                                    //     index: index,
                                    //     convertedList: convertedList,
                                    //     songs: songs,
                                    //   ),
                                    //   transition: Transition.leftToRight,
                                    // );
                                  },
                                ),
                              );
                            },
                            separatorBuilder: (conext, index) {
                              return Divider();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.white,
            );
          },
          child: Icon(
            Icons.queue_music,
            color: Colors.white,
          ),
        ),
        body: CupertinoScrollbar(
          child: FutureBuilder<List<SongEntity>>(
              future: OnAudioRoom().queryAllFromPlaylist(
                playListKey,
                limit: 200,
                sortType: null,
              ),
              builder: (context, item) {
                if (item.data == null) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }
                if (item.data!.isEmpty) {
                  return const Center(
                    child: Text('No songs'),
                  );
                }

                List<SongEntity> playlistSongs = item.data!;

                return ListView.builder(
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(
                          left: 8, right: 8, top: 8, bottom: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white24,
                      ),
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: Center(
                        child: ListTile(
                          leading: buildListTileLeading(
                              playlistSongs, index, context),
                          title: listTileAudioTitle(playlistSongs, index),
                          // trailing: removeSongFromPlaylist(index),
                          trailing: IconButton(
                              onPressed: () async {
                                control.songDeleteFromPlaylist(
                                    index: index,
                                    playListKey: playListKey,
                                    playlistSongs: playlistSongs);
                             
                              },
                              icon: Icon(Icons.playlist_remove)),
                          onTap: () {
                            convertAudioFile(playlistSongs);
                            Get.to(
                              PlayingScreen(
                                index: index,
                                convertedList: convertedList,
                                songs: Get.find<HomeController>().fechsongsall,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  itemCount: playlistSongs.length,
                );
              }),
        ),
      ),
    );
  }

// =================================================================

// =====================================================================================
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
                'assets/images/music-playlist-icon-vector-33740985.jpg'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        width: MediaQuery.of(context).size.width * 0.15,
        height: MediaQuery.of(context).size.height * 0.14,
      ),
    );
  }

//=================================================================================
  Text listTileAudioTitle(List<SongEntity> playListSongs, int index) {
    return Text(
      playListSongs[index].title,
      maxLines: 2,
      style: TextStyle(overflow: TextOverflow.ellipsis),
    );
  }

// ==================================================================================
  convertAudioFile(List<SongEntity> playListSongs) {
    for (var item in playListSongs) {
      convertedList.add(
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
}

// const double fabSize = 60;

// class CustomFabWidget extends StatelessWidget {
//   int playListKey;
//   CustomFabWidget({Key? key, required this.playListKey}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return OpenContainer(
//       transitionDuration: Duration(milliseconds: 700),
//       openBuilder: (context, action) {
//         // Get.to(AddSongsToPlaylist(playListKey: playListKey));
//         return AddSongsToPlaylist(
//           playListKey: playListKey,
//         );
//       },
//       closedBuilder: (context, openContainer) => Container(
//         decoration: const BoxDecoration(
//           // shape: BoxShape.circle,
//           color: Colors.white,
//           // borderRadius: BorderRadius.circular(60),
//         ),
//         height: fabSize,
//         width: fabSize,
//         child: Icon(
//           Icons.add,
//           color: Colors.black,
//         ),
//       ),
//     );
//   }
// }



















// import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hive/hive.dart';
// import 'package:music_player/database/database.dart';
// import 'package:music_player/getxfunctions.dart';
// import 'package:music_player/main.dart';
// import 'package:music_player/pages/playlist.dart';
// import 'home.dart';
// import 'playing_screen.dart';

// class PlayListSongs extends StatelessWidget {
//   int index;

//   PlayListSongs({Key? key, required this.index}) : super(key: key);

//   final box = Hive.box(dbname);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//             onPressed: () {
//               Get.back();
//             },
//             icon: Icon(Icons.arrow_back)),
//         title: Text('Playlist Name'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//               onPressed: () {
//                 // Get.to(PlayList());

//                 Get.defaultDialog(
//                   title: 'Delete The Playlist',
//                   content: Text('Are you sure ?'),
//                   cancel: ElevatedButton(
//                     onPressed: () {},
//                     child: Text('Cancel'),
//                   ),
//                   onConfirm: () {
//                     Get.to(Playlist());
//                   },
//                   confirm: ElevatedButton(
//                     onPressed: () {
//                       List playListNames = box.get('playListName');
//                       playListNames.removeAt(index);
//                       // Get.off(PlayList());
//                       Get.back();
//                     },
//                     child: Text('Ok'),
//                   ),
//                 );
//               },
//               icon: Icon(Icons.delete_forever))
//         ],
//       ),
//       body: CupertinoScrollbar(
//         child: ListView.builder(
//           itemBuilder: (context, index) {
//             return Container(
//               margin:
//                   const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 3),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 color: Colors.white24,
//               ),
//               height: MediaQuery.of(context).size.height * 0.1,
//               child: Center(
//                 child: ListTile(
//                     leading: Container(
//                       decoration: BoxDecoration(
//                           color: Colors.transparent,
//                           image: DecorationImage(
//                             image: AssetImage(audios[index].metas.image!.path),
//                             fit: BoxFit.cover,
//                           ),
//                           borderRadius: BorderRadius.circular(7)),
//                       width: 50,
//                       height: 50,
//                     ),
//                     title: Text(
//                       audios[index].metas.title.toString(),
//                       maxLines: 2,
//                       style: TextStyle(overflow: TextOverflow.ellipsis),
//                     ),
//                     trailing: GetBuilder<IconChanging>(builder: (controller) {
//                       return IconButton(
//                           onPressed: () {
//                             controller.iconChanging(index);
//                           },
//                           icon: Icon(
//                             controller.isChanged
//                                 ? Icons.playlist_add_outlined
//                                 : Icons.play_disabled_sharp,
//                             size: 30,
//                             color: controller.clr,
//                           ));
//                     }),
//                     onTap: () {
//                       Get.to(PlayingScreen(
//                         index: index,
//                         convertedList: audios.obs,
//                       ));
//                     }),
//               ),
//             );
//           },
//           itemCount: audios.length,
//         ),
//       ),
//     );
//   }
// }
