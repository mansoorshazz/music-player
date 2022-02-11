import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:music_player_project/getxfunctions.dart';
import 'package:music_player_project/pages/playing_screen.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:text_scroll/text_scroll.dart';

class BottomMiniPlayer extends StatelessWidget {
  final AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer.withId('music');

  // BottomMiniPlayer({

  //   Key? key,
  // }) : super(key: key);

  final List<Audio> convertedList = [];

  BottomMiniPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final control = Get.put(PlayingScreenController());

    return assetsAudioPlayer.builderRealtimePlayingInfos(
      builder: (context, realTimeInfo) {
        int currentIndex = controller.fechsongsall.indexWhere((element) =>
            element.id.toString() ==
            realTimeInfo.current!.audio.audio.metas.id.toString());

        if (realTimeInfo.isPlaying) {
          control.iconControl.forward();
          control.rotateController.repeat();
        } else {
          control.iconControl.reverse();
          control.rotateController.stop();
        }

        return ListTile(
          horizontalTitleGap: 10,
          leading: buildListTileLeading(
            controller.fechsongsall,
            currentIndex,
            context,
          ),
          title: assetsAudioPlayer.builderRealtimePlayingInfos(
            builder: ((context, realtimePlayingInfos) => realTimeInfo.isPlaying
                ? TextScroll(
                    '${control.assetsAudioPlayer.getCurrentAudioTitle}       ',
                    velocity: Velocity(pixelsPerSecond: Offset(35, 15)),
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text(
                    control.assetsAudioPlayer.getCurrentAudioTitle,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
          ),
          trailing: assetsAudioPlayer.builderIsPlaying(
            builder: (context, isPlaying) => buildPauseNext(isPlaying),
          ),
          onTap: () {
            Get.to(
              PlayingScreen(
                convertedList: const [],
                index: currentIndex,
                songs: controller.fechsongsall,
              ),
              transition: Transition.downToUp,
            );
          },
        );
      },
    );
  }

// ==================================================================
// Its used to audio next and pause and play.

  Row buildPauseNext(bool isPlaying) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PlayerBuilder.currentPosition(
          player: assetsAudioPlayer,
          builder: (context, duration) {
            return Center(
              child: Text(
                getTimeString(duration.inMilliseconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            );
          },
        ),
        IconButton(
          onPressed: () {
            isPlaying ? assetsAudioPlayer.pause() : assetsAudioPlayer.play();
          },
          icon: Icon(
            !isPlaying ? Icons.play_arrow_rounded : Icons.pause_circle,
            color: Colors.white,
            size: 35,
          ),
        ),
      ],
    );
  }

//===============================================================
  buildListTileLeading(
    image,
    index,
    context,
  ) {
    return QueryArtworkWidget(
      id: image[index].id,
      type: ArtworkType.AUDIO,
      artworkWidth: MediaQuery.of(context).size.width * 0.15,
      artworkHeight: MediaQuery.of(context).size.height * 0.06,
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
        height: MediaQuery.of(context).size.height * 0.06,
      ),
    );
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

// ===============================================================================================

}
