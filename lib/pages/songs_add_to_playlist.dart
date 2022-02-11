import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:on_audio_room/on_audio_room.dart';

class SongsAddToPlaylist extends StatefulWidget {
  SongsAddToPlaylist({Key? key, required this.songs, required this.songsIndex})
      : super(key: key);

  final List<SongModel> songs;

  final int songsIndex;

  @override
  State<SongsAddToPlaylist> createState() => _SongsAddToPlaylistState();
}

class _SongsAddToPlaylistState extends State<SongsAddToPlaylist> {
  final OnAudioRoom audioRoom = OnAudioRoom();

  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final TextEditingController playListNameController =
        TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Add To Playlist'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          ListTile(
            leading: buildILeadingImage(context),
            title: Text(
              'Create a new playlist',
              style: TextStyle(
                fontSize: 17,
              ),
            ),
            onTap: () {
              createPlaylist(playListNameController);
            },
          ),
          Divider(
            thickness: 5,
            color: Colors.black12,
          ),
          Expanded(
            child: FutureBuilder<List<PlaylistEntity>>(
              future: OnAudioRoom().queryPlaylists(),
              builder: (context, item) {
                if (item.data == null) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (item.data!.isEmpty) {
                  return Center(
                    child: Text('No Playlists'),
                  );
                }

                List<PlaylistEntity> playLists = item.data!;

                return ListView.separated(
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: playLists.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      child: ListTile(
                        leading: Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: MediaQuery.of(context).size.height * 0.2,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/macos_big_sur_folder_icon_186046.png'),
                            ),
                          ),
                        ),
                        title: Text(
                          playLists[index].playlistName,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      onTap: () async {
                        bool isAdded = await audioRoom.checkIn(
                          RoomType.PLAYLIST,
                          // songs[index].id,
                          widget.songs[widget.songsIndex].id,
                          playlistKey: playLists[index].key,
                        );

                        await audioRoom.addTo(
                          RoomType.PLAYLIST,
                          widget.songs[widget.songsIndex].getMap.toSongEntity(),
                          playlistKey: playLists[index].key,
                          ignoreDuplicate: false,
                        );

                        Get.back();
                        // print(isAdded);
                        if (isAdded == true) {
                          Get.snackbar(
                            '',
                            '',
                            titleText: Text(
                              'Message from ${playLists[index].playlistName}',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black),
                            ),
                            messageText: Text(
                                'Song Already Added to ${playLists[index].playlistName}'),
                            backgroundColor: Colors.white,
                          );
                        } else {
                          Get.snackbar(
                            '',
                            '',
                            titleText: Text(
                              'Message from ${playLists[index].playlistName}',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black),
                            ),
                            // messageText: ,
                            messageText: Text(
                              '${widget.songs[widget.songsIndex].title}  Song Added to ${playLists[index].playlistName} ',
                              maxLines: 2,
                            ),
                            backgroundColor: Colors.white,
                          );
                        }

                        // Get.to(
                        //   PlayListSongs(
                        //     playListName: playLists[index].playlistName,
                        //     playListKey: playLists[index].key,
                        //   ),
                        // );

                        // Get.to(PlayListSongs());
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> createPlaylist(TextEditingController controller) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Create a playlist'),
          content: Card(
            color: Colors.transparent,
            elevation: 0.0,
            child: Column(
              children: <Widget>[
                Form(
                  key: formkey,
                  child: TextFormField(
                    controller: controller,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'please enter a name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "Enter a name ?",
                      border: OutlineInputBorder(),
                      // filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.green.shade600),
              ),
              onPressed: () {
                if (formkey.currentState!.validate()) {
                  Get.back();
                  audioRoom.createPlaylist(controller.text);
                  setState(() {});
                }
              },
            ),
            CupertinoDialogAction(
              onPressed: () {
                Get.back();
                setState(() {});
              },
              child: Text(
                "No",
                style: TextStyle(color: Colors.red.shade600),
              ),
            )
          ],
        );
      },
    );
    // return Get.defaultDialog(
    //   title: 'Add a playlist',
    //   content: TextFormField(
    //     controller: controller,
    //     cursorColor: Colors.red,
    //   ),
    //   cancel: ElevatedButton(
    //     onPressed: () {
    //       Get.back();
    //     },
    //     child: Text('Cancel'),
    //   ),
    //   confirm: ElevatedButton(
    //     onPressed: () {
    //       Get.back();
    //       audioRoom.createPlaylist(controller.text.trim());

    //       // setState(() {});
    //       // controller.creatingPlaylistName(playlistNameController.text);
    //     },
    //     child: Text('OK'),
    //   ),
    // );
  }

  Container buildILeadingImage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      height: MediaQuery.of(context).size.height * 0.2,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/images/macos_big_sur_folder_icon_186046.png',
          ),
        ),
      ),
    );
  }
}
