import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player_project/controllers/playlist.dart';
// import 'package:hive_generator/hive_generator.dart';
import 'package:music_player_project/getxfunctions.dart';
import 'package:on_audio_room/on_audio_room.dart';
import 'playlist_songs.dart';

class PlayList extends StatelessWidget {
  PlayList({Key? key}) : super(key: key);

  final OnAudioRoom audioRoom = OnAudioRoom();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    TextEditingController playlistNameController = TextEditingController();

    Get.put(PlayListController());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: const Text(
          'Playlists',
          // style: TextStyle(fontSize: 30),
        ),
        centerTitle: true,
      ),
      floatingActionButton: creatingPlayList(playlistNameController),
      body: GetBuilder<PlayListController>(builder: (context) {
        return FutureBuilder<List<PlaylistEntity>>(
          future: OnAudioRoom().queryPlaylists(),
          builder: (context, item) {
            // ==============================================

            if (item.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (item.data!.isEmpty) {
              return Center(
                child: AnimatedTextKit(
                  repeatForever: true,
                  animatedTexts: [
                    WavyAnimatedText(
                      'No Playlists',
                      textStyle: const TextStyle(fontSize: 15),
                    ),
                    // WavyAnimatedText('Add songs to Favourites'),
                  ],
                ),
              );
            }

            List<PlaylistEntity> playLists = item.data!;

            // ==============================================

            return ListView.separated(
              separatorBuilder: (context, index) => const Divider(
                indent: 28,
                endIndent: 10,
              ),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: buildPlayListImage(context),
                  // =======================================================================
                  title: Text(playLists[index].playlistName),
                  // =======================================================================
                  subtitle: Text(
                      '${playLists[index].playlistSongs.length.toString()} Songs'),
                  //=======================================================================
                  trailing: deletePlayList(playLists, index),
                  // =======================================================================
                  onTap: () {
                    Get.off(
                      PlayListSongs(
                        playListName: playLists[index].playlistName,
                        playListKey: playLists[index].key,
                      ),
                    );
                  },
                );
              },
              itemCount: playLists.length,
            );
          },
        );
      }),
    );
  }

// ===================================================================================
// This is a IconButton widget. Its used to delete playlist.

  IconButton deletePlayList(List<PlaylistEntity> playLists, int index) {
    return IconButton(
      // color: Colors.black,
      onPressed: () {
        showDialog(
            context: Get.overlayContext!,
            builder: (BuildContext context) => CupertinoAlertDialog(
                  title: Text("Delete The Playlist"),
                  content: Text("Are you sure ?"),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      onPressed: () {
                        final controller = Get.find<PlayListController>();
                        controller.deletePlaylist(playLists[index].key);
                        Get.back();
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
      },
      icon: const Icon(Icons.delete),
    );
  }

  //================================================================
  //This is a container widget. Its used to show the Playlist Image.

  Container buildPlayListImage(BuildContext context) {
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

// ==============================================================================================
// This is a floatingActionButton Widget. Its used to create a playlist.

  FloatingActionButton creatingPlayList(
      TextEditingController playlistNameController) {
    return FloatingActionButton(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      onPressed: () {
        createPlaylistDilaogue(playlistNameController);
      },
      child: const Icon(Icons.playlist_add),
    );
  }

  // ============================================================================================
  //This is a Cupertino Alert Dilagoue. Its shows the alert dialogue for the create playlist.

  Future<bool?> createPlaylistDilaogue(
      TextEditingController playlistNameController) {
    return showDialog<bool>(
      context: Get.overlayContext!,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Create a playlist'),
          content: Card(
            color: Colors.transparent,
            elevation: 0.0,
            child: Column(
              children: <Widget>[
                Form(
                  key: formKey,
                  child: TextFormField(
                    controller: playlistNameController,
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
                if (formKey.currentState!.validate()) {
                  Get.back();
                  final controller = Get.find<PlayListController>();
                  controller.creatingPlaylistName(playlistNameController.text);
                  playlistNameController.clear();
                }
              },
            ),
            CupertinoDialogAction(
              onPressed: () {
                Get.back();
                playlistNameController.clear();
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
  }

// ===============================================================================================================

}

// import 'dart:ffi';

// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:music_player/getxfunctions.dart';
// import 'package:music_player/main.dart';
// import 'playlist_songs.dart';

// class PlayList extends GetView<PlayListController> {
//   PlayList({Key? key}) : super(key: key);

//   // final box = Hive.box(dbname);
//   // List<String> playListName = [];

//   @override
//   Widget build(BuildContext context) {
//     Get.put(PlayListController());

//     TextEditingController playListNameController = TextEditingController();

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         title: Text(
//           'Playlist',
//           // style: TextStyle(fontSize: 30),
//         ),
//         centerTitle: true,
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         onPressed: () => playlistCreationDialogue(playListNameController),
//         child: Icon(Icons.playlist_add),
//       ),
//       body: ValueListenableBuilder(
//           valueListenable: box.listenable(),
//           builder: (context, Box boxDb, _) {
//             List playListNames = box.get('playListName');

//             return ListView.builder(
//               itemCount: playListNames.length,
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   child: Container(
//                     margin: const EdgeInsets.all(7),
//                     decoration: BoxDecoration(
//                       image: const DecorationImage(
//                         image: AssetImage(
//                           'assets/images/productivity+playlist.jpg',
//                         ),
//                         fit: BoxFit.cover,
//                       ),
//                       borderRadius: BorderRadius.circular(5),
//                       color: Colors.amber,
//                     ),
//                     height: MediaQuery.of(context).size.height * 0.2,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(10.0),
//                           child: Text(
//                             playListNames[index],
//                             style: TextStyle(
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   onTap: () {
//                     Get.to(PlayListSongs(
//                       index: index,
//                     ));
//                   },
//                 );
//               },
//             );
//           }),
//     );
//   }

//   playlistCreationDialogue(playListNameController) {
//     Get.defaultDialog(
//       title: 'Add a playlist',
//       content: GetBuilder<PlayListController>(
//         builder: (control) => TextField(
//           controller: playListNameController,
//           cursorColor: Colors.red,
//         ),
//       ),
//       cancel: ElevatedButton(
//         onPressed: () {
//           Get.back();
//         },
//         child: Text('Cancel'),
//       ),
//       confirm: ElevatedButton(
//         onPressed: () async {
//           Get.reload();
//           Get.back();
//           controller.creatingPlaylistName(playListNameController.text);
//           await box.put('playListName', controller.playListNameList);
//         },
//         child: const Text('OK'),
//       ),
//     );
//   }
// }
