import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player_project/pages/playlist.dart';
import 'package:music_player_project/pages/settings.dart';
import 'package:music_player_project/widgets/miniplayer.dart';

import '../getxfunctions.dart';
import 'favorites.dart';
import 'home.dart';

// ============================================
// This List used to Change to another page using bottom navigation bar.

List childrens = [
  Home(),
  FavoritePage(),
  PlayList(),
  Settings(),
];

class BottomNavBar extends StatelessWidget {
  BottomNavBar({
    Key? key,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    Get.put(BottomNavbarControlls());
    return Scaffold(
      bottomNavigationBar: bottomNavbar(),
      body: GetBuilder<BottomNavbarControlls>(
        builder: (controller) {
          return Column(
            children: [
              Expanded(
                child: childrens[controller.currentIndex],
              ),

              Container(
                margin: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                decoration: const BoxDecoration(
                  color: Colors.blueGrey,
                  // border: Border.all(color: Colors.white),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: BottomMiniPlayer(),
              ),
              // BottomMiniPlayer(visible: visible)
            ],
          );
        },
      ),
    );
  }
}

// =======================================================================
// Bottom Navigation Bar.....

bottomNavbar() {
  Get.put(BottomNavbarControlls());
  return GetBuilder<BottomNavbarControlls>(
    builder: (controller) {
      return BottomNavyBar(
        // backgroundColor: controller.bgcolor[controller.currentIndex],

        animationDuration: const Duration(milliseconds: 1000),

        selectedIndex: controller.currentIndex,
        curve: Curves.bounceOut,

        itemCornerRadius: 10,
        items: [
          buildBottomNavyBarItem(
            Icon(Icons.home),
            Text('Home'),
            Colors.teal,
            Colors.black,
          ),
          buildBottomNavyBarItem(
            Icon(Icons.favorite),
            Text('Favorites'),
            Colors.red,
            Colors.black,
          ),
          buildBottomNavyBarItem(
            Icon(Icons.playlist_play),
            Text('Playlist'),
            Colors.blue,
            Colors.black,
          ),
          buildBottomNavyBarItem(
            Icon(Icons.settings),
            Text('Settings'),
            Colors.green.shade700,
            Colors.black,
          ),
        ],
        onItemSelected: (index) {
          controller.selectedItemChanging(index);
        },
      );
    },
  );
}

// ========================================================================================
// This is a bottom navigatin bar items.

buildBottomNavyBarItem(
  Icon icon,
  Text iconName,
  Color activeColor,
  Color inactiveColor,
) {
  return BottomNavyBarItem(
    icon: icon,
    title: iconName,
    activeColor: activeColor,
    inactiveColor: inactiveColor,
  );
}
