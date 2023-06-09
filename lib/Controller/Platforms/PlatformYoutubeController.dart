import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/AppManager/DatabaseController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/Players/Youtube/YoutubeRetriever.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/Services/youtube/api_controller.dart' as ytController;

class PlatformYoutubeController extends PlatformsController {
  PlatformYoutubeController(Platform platform, {bool isBack}) : super(platform, isBack: isBack) {
    platform.platformInformations['logo'] = 'assets/logo/youtube_logo.png';
    platform.platformInformations['icon'] =
        'assets/logo/icons/youtube_icon.png';
    platform.platformInformations['main_color'] = Colors.red[500];
    platform.platformInformations['secondary_color'] = Colors.red[200];

    features = {
      PlatformsCtrlFeatures.PLAYLIST_ADD: false,
      PlatformsCtrlFeatures.PLAYLIST_GET: true,
      PlatformsCtrlFeatures.PLAYLIST_CLONE: true,
      PlatformsCtrlFeatures.PLAYLIST_MERGE: true,
      PlatformsCtrlFeatures.PLAYLIST_REMOVE: false,
      PlatformsCtrlFeatures.PLAYLIST_RENAME: false,
      PlatformsCtrlFeatures.TRACK_ADD_ANOTHER_PLAYLIST: false,
      PlatformsCtrlFeatures.TRACK_ADD: false,
      PlatformsCtrlFeatures.TRACK_GET: true,
      PlatformsCtrlFeatures.TRACK_REMOVE: false
    };
  }

  ytController.API yt = new ytController.API();

  @override
  get platformInformations {
    return platform.platformInformations;
  }

  @override
  get userInformations {
    return platform.userInformations;
  }

  @override
  Future<List<Playlist>> getPlaylists({bool refreshing}) async {
    var parent = await super.getPlaylists(refreshing: refreshing);
    if(parent != null) return parent;
    List<Playlist> finalPlaylists = <Playlist>[];
    List<Playlist> playlists = await yt.getPlaylistsList();
    for (Playlist play in platform.playlists.value) {
      for (int i = 0; i < playlists.length; i++) {
        if (play.id == playlists[i].id) {
          finalPlaylists.add(playlists[i]);
          playlists.removeAt(i);
        }
      }
    }
    for (Playlist play in playlists) {
      play.setTracks(await yt.getPlaylistSongs(play), isNew: true);
      finalPlaylists.add(play);
    }
    for (int i = 0; i < platform.playlists.value.length; i++) {
      if (platform.playlists.value[i].getTracks.length == 0 || refreshing == true) {
        finalPlaylists[i]
            .setTracks(await yt.getPlaylistSongs(finalPlaylists[i]), isNew: true);
      }
      else
        finalPlaylists[i].setTracks(platform.playlists.value[i].getTracks, isNew: true);
    }
    List<Playlist> platPlaylists = platform.setPlaylist(finalPlaylists, isNew: true);
    super.getAllPlatformTracks();
    return platPlaylists;
  }

  @override
  ValueNotifier<List<Playlist>> getPlaylistsUpdate() {
    return platform.playlists;
  }

  @override
  Future<List<Track>> getTracks(Playlist playlist) async {
    List<Track> finalTracks = <Track>[];

    if (playlist.getTracks.length == 0) {
      List<Track> tracks = await yt.getPlaylistSongs(playlist);
      for (Track track in playlist.getTracks) {
        for (int i = 0; i < tracks.length; i++) {
          if (track.id == tracks[i].id) {
            finalTracks.add(tracks[i]);
            tracks.removeAt(i);
          }
        }
      }
      for (Track track in tracks) {
        finalTracks.add(track);
      }
    } else {
      finalTracks = playlist.getTracks;
    }

    return playlist.setTracks(finalTracks, isNew: true);
  }

  @override
  connect() async {
    await yt.login();
    platform.userInformations['isConnected'] = yt.isLoggedIn;
    platform.userInformations['name'] = yt.displayName;
    platform.userInformations['email'] = yt.email;
    super.connect();
  }

  @override
  disconnect() async {
    yt.disconnect();
    platform.userInformations['isConnected'] = yt.isLoggedIn;
    for(int i=0; i<platform.playlists.value.length; i++) {
      platform.removePlaylist(i);
    }
    this.platform.removeAllPlaylists();
    DataBaseController().removePlatform(this.platform);
    super.disconnect();
  }

  @override
  FutureOr<Playlist> addPlaylist(
      {Playlist playlist,
      String name,
      String ownerId,
      String ownerName,
      String imageUrl,
      String playlistUri,
      List<MapEntry<Track, DateTime>> tracks}) {
    // TODO: implement addPlaylist
    throw UnimplementedError();
  }

  @override
  Playlist removePlaylist(int playlistIndex) {
    throw UnimplementedError();
  }

  @override
  Playlist mergePlaylist(Playlist toMergeTo, Playlist toMerge) {
    // TODO: implement mergePlaylist
    throw UnimplementedError();
  }

  @override
  void renamePlaylist(Playlist playlist, String name) {
    // TODO: implement renamePlaylist
    throw UnimplementedError();
  }

  @override
  Future<MapEntry<Track,File>> getFile(Track tr) async => MapEntry(tr, await YoutubeRetriever().streamById(tr.id));

  // @override
  // pause() {
  //   // TODO: implement pause
  //   throw UnimplementedError();
  // }

  // @override
  // play(String youtubeUri) {
  //   // TODO: implement play
  //   throw UnimplementedError();
  // }

  // @override
  // resume() {
  //   // TODO: implement resume
  //   throw UnimplementedError();
  // }

  // @override
  // seekTo(Duration duration) {
  //   // TODO: implement seekTo
  //   throw UnimplementedError();
  // }

}
