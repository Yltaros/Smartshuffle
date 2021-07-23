import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smartshuffle/Controller/DatabaseController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformDefaultController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformSpotifyController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformYoutubeController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';

import 'package:smartshuffle/Services/spotify/api_controller.dart' as SP;
import 'package:smartshuffle/Services/youtube/api_controller.dart' as YT;


enum ServicesLister {
  DEFAULT,
  SPOTIFY,
  YOUTUBE
}

String serviceToString(ServicesLister service) => service.toString().split(".")[1];


class GlobalAppController {

  static List<PlatformsController> getAllControllers() {
    List<PlatformsController> plat = List<PlatformsController>();
    PlatformsLister.platforms.forEach((key, value) {
      plat.add(value);
    });
    return plat;
  }

  static Future<void> storageInit() async {
    final storage = FlutterSecureStorage();
    print('la ca part');
    Map<String, Platform> platforms = await DataBaseController().getPlatforms();

    print('checking..');

    if(platforms['SmartShuffle'] != null) {
      PlatformsLister.platforms[ServicesLister.DEFAULT].platform = platforms['Smartshuffle'];
    } else {
      PlatformsLister.platforms[ServicesLister.DEFAULT] = new PlatformDefaultController(Platform("SmartShuffle"));
    }

    // if(await storage.containsKey(key: serviceToString(ServicesLister.SPOTIFY).toLowerCase())) {
    if(platforms['Spotify'] != null) {
      print('spotify');
      String spToken = await storage.read(key: serviceToString(ServicesLister.SPOTIFY).toLowerCase());
      PlatformsLister.tokens[ServicesLister.SPOTIFY] = spToken;
      await SP.API().login(storeToken: spToken);

      PlatformsLister.platforms[ServicesLister.SPOTIFY].platform = platforms['Spotify'];
    } else {
      PlatformsLister.platforms[ServicesLister.SPOTIFY] = new PlatformSpotifyController(Platform("Spotify", platformInformations: {'package': 'com.spotify.music'}));
    }

    // if(await storage.containsKey(key: serviceToString(ServicesLister.YOUTUBE).toLowerCase())) {
    if(platforms['Youtube'] != null) {
      String ytToken = await storage.read(key: serviceToString(ServicesLister.YOUTUBE).toLowerCase());
      PlatformsLister.tokens[ServicesLister.YOUTUBE] = ytToken;
      await YT.API().login(storeToken: ytToken);

      PlatformsLister.platforms[ServicesLister.YOUTUBE].platform = platforms['Youtube'];
    } else {
      PlatformsLister.platforms[ServicesLister.YOUTUBE] = new PlatformYoutubeController(Platform("Youtube", platformInformations: {'package': 'com.google.android.youtube'}));
    }

    print('on va update');
  }

  static Future<void> initApp(State state) async {
    print('init');
    await DataBaseController().database;
    state.setState(() {});
    print('c update');
  }

}

class PlatformsLister {

  static Map<ServicesLister, String> tokens = {};

  static Map<ServicesLister, PlatformsController> platforms = Map<ServicesLister, PlatformsController>();
  // {
  //   ServicesLister.DEFAULT: new PlatformDefaultController(Platform("SmartShuffle")),
  //   ServicesLister.SPOTIFY: new PlatformSpotifyController(Platform("Spotify", platformInformations: {'package': 'com.spotify.music'})),
  //   ServicesLister.YOUTUBE: new PlatformYoutubeController(Platform("Youtube", platformInformations: {'package': 'com.google.android.youtube'}))
  // };

  static ServicesLister nameToService(String name) {
    if(name == "DEFAULT") return ServicesLister.DEFAULT;
    if(name == "SPOTIFY") return ServicesLister.SPOTIFY;
    if(name == "YOUTUBE") return ServicesLister.YOUTUBE;
  }

}
