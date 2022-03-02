import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:on_audio_room/on_audio_room.dart';

class PlayListController extends GetxController {
  List<String> playListNameList = [];
  OnAudioRoom audioRoom = OnAudioRoom();

  // updateScreen() {
  //   update();
  // }

  creatingPlaylistName(value) {
    audioRoom.createPlaylist(value);
    // playlistName = value;
    update();
  }

  deletePlaylist(int playlistKey) {
    audioRoom.deletePlaylist(playlistKey);
    update();
  }

  @override
  void onClose() {
    super.onClose();
    
  }
}
