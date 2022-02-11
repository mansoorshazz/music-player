import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player_project/pages/playlist_songs.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:on_audio_room/on_audio_room.dart';

import '../getxfunctions.dart';
import 'playing_screen.dart';

class AddSongsToPlaylist extends StatefulWidget {
  int playListKey;

  AddSongsToPlaylist({Key? key, required this.playListKey}) : super(key: key);

  @override
  State<AddSongsToPlaylist> createState() => _AddSongsToPlaylistState();
}

class _AddSongsToPlaylistState extends State<AddSongsToPlaylist> {
  final OnAudioRoom audioRoom = OnAudioRoom();

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Add Songs'),
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

            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: CupertinoScrollbar(
                  child: ListView.separated(
                itemCount: songs!.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: ListTile(
                      // ================================================================
                      leading: buildListTileLeading(songs, index, context),

                      // ================================================================

                      title: buildListTileTitle(songs, index, max: 1),

                      // ================================================================

                      // trailing: popmenuButton(index, songs),

                      // ===================================================================

                      onTap: () async {
                        bool isAdded = await audioRoom.checkIn(
                          RoomType.PLAYLIST,
                          songs[index].id,
                          playlistKey: widget.playListKey,
                        );

                        print(isAdded);

                        audioRoom.addTo(
                          RoomType.PLAYLIST,
                          songs[index].getMap.toSongEntity(),
                          playlistKey: widget.playListKey,
                          ignoreDuplicate: false,
                        );
                        setState(() {});
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
              )),
            );
          },
        ),
      ),
    );
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
              'assets/images/M1 LOGO.png',
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
}
