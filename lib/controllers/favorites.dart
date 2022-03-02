import 'package:get/get.dart';
import 'package:on_audio_room/on_audio_room.dart';

class FavoritesController extends GetxController {
  OnAudioRoom _audioRoom = OnAudioRoom();

  songsDeleteFromFavorites({
    required int index,
    required List favorites,
  }) async {
    await _audioRoom.deleteFrom(
      RoomType.FAVORITES,
      favorites[index].key,
    );
    update();
  }
}
