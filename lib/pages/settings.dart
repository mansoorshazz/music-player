import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import 'package:music_player_project/getxfunctions.dart';
import 'package:music_player_project/widgets/miniplayer.dart';
import 'package:share_plus/share_plus.dart';

class Settings extends StatelessWidget {
  Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Settings',
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: themChangeListTile(),
          ),
          buildNotificationSwitch(),
          buildShare(context),

          buildListTile(title: 'Terms and Conditions', context: context),
          buildListTile(title: 'Privacy Policy', context: context),
          buildAbout(),

          const Spacer(),
          // -=============================
          // VERSION
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Version',
                style: TextStyle(
                    letterSpacing: 1, fontSize: 17, color: Colors.grey),
              ),
              Text(
                '1.0.0',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
        ],
      ),
    );
  }

  buildShare(context) {
    return ListTile(
      title: Text('Share App'),
      trailing: SizedBox(
          width: MediaQuery.of(context).size.width * 0.12,
          child: SizedBox(
            child: Icon(Icons.share),
          )),
      onTap: () async {
        await Share.share(
          'https://play.google.com/store/apps/details?id=in.brototype.music_player_project',
          subject: 'Enjoy the Music App',
        );
      },
    );
  }

  ListTile buildAbout() {
    return ListTile(
      title: Text('About'),
      onTap: () => Get.to(
        LicensePage(
          applicationName: 'Music',
          applicationVersion: '1.0.0',
          applicationIcon: Image.asset('assets/images/M1 LOGO.png'),
        ),
      ),
    );
  }

// =============================================================================
// Change Theme. Light Theme and Dark Theme.

  themChangeListTile() {
    return GetBuilder<SettingsController>(
      builder: (control) => ListTile(
        leading: GetBuilder<SettingsController>(builder: (controller) {
          return Text(controller.textTheme, style: TextStyle(fontSize: 16));
        }),
        trailing: GetBuilder<SettingsController>(
          builder: (controller) => IconButton(
            onPressed: () {
              // Get.changeThemeMode(
              //     Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
              //  controller.changeTheme(controller.isDark);
              controller.themeChange();
            },
            icon: Icon(
              controller.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 25,
            ),
          ),
        ),
        onTap: () {
          control.themeChange();
        },
      ),
    );
  }

  // ==================================================================================
  // Notification Switch. Background playing conrol switch.

  buildNotificationSwitch() {
    return GetBuilder<PlayingScreenController>(
      builder: (controller) {
        return SwitchListTile(
          title: Text('Notification'),
          value: controller.notificationSwitch,
          onChanged: (value) {
            controller.switchChangeState(value);
          },
        );
      },
    );
  }

//  ========================================================
//  ListTile. REusing Function.

  buildListTile(
      {required String title, Icon? icon, required BuildContext context}) {
    return ListTile(
        title: Text(title),
        trailing: SizedBox(
          width: MediaQuery.of(context).size.width * 0.12,
          child: icon,
        ),
        onTap: () {});
  }
}
