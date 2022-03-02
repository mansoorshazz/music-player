import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/sockets/src/socket_notifier.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music_player_project/pages/home.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../getxfunctions.dart';
import 'playing_screen.dart';

class CustomSearchDelegate extends SearchDelegate {
  List<SongModel> songs = [];

  CustomSearchDelegate({required this.songs});

  List<Audio> convetedList = [];

  @override
  TextStyle get searchFieldStyle => TextStyle(
        fontWeight: FontWeight.w600,
        fontFamily: GoogleFonts.poppins().fontFamily,
      );

  @override
  buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
    // // TODO: implement buildActions
    // throw UnimplementedError();
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var item in songs) {
      if (item.title.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(item.title);
      }
    }

    // final suggestionList = query.isEmpty
    //     ? matchQuery
    //     : matchQuery.where((element) => element.startsWith(query)).toList();

    if (matchQuery.isEmpty) {
      return const Center(
        child: Text('No songs'),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ListView.separated(
        separatorBuilder: (context, index) => const Divider(),
        itemCount: matchQuery.length,
        itemBuilder: (context, index) {
          var result = matchQuery[index];

          int filterIndex =
              songs.indexWhere((element) => element.title == matchQuery[index]);

          return ListTile(
            leading: buildListTileLeading(songs, filterIndex, context),
            title: Text(
              result,
              maxLines: 2,
            ),
            onTap: () {
              FocusScope.of(context).unfocus();

              Get.to(
                PlayingScreen(
                  convertedList: convetedList,
                  songs: songs,
                  index: filterIndex,
                ),
              );
            },
          );
        },
      ),
    );
    // TODO: implement buildResults
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var item in songs) {
      if (item.title.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(item.title);
      }
    }

    // final suggestionList = query.isEmpty
    //     ? matchQuery
    //     : matchQuery.where((element) => element.startsWith(query)).toList();

    if (matchQuery.isEmpty) {
      return const Center(
        child: Text('No songs'),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: matchQuery.length,
        itemBuilder: (context, index) {
          var result = matchQuery[index];

          int filterIndex =
              songs.indexWhere((element) => element.title == matchQuery[index]);

          return ListTile(
            leading: buildListTileLeading(songs, filterIndex, context),
            title: Text(
              result,
              maxLines: 2,
            ),
            onTap: () {
              // print(index);
              FocusScope.of(context).unfocus();
              convertAudioFile(songs);

              Get.to(PlayingScreen(
                convertedList: convetedList,
                songs: songs,
                index: filterIndex,
              ));
            },
          );
        },
      ),
    );
  }

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

  convertAudioFile(List<SongModel> songs) {
    for (var item in songs) {
      convetedList.add(
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
}
