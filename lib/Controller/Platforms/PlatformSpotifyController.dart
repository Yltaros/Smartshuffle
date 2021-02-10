import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/Services/spotify/api_controller.dart' as spotify;

class PlatformSpotifyController extends PlatformsController {
  PlatformSpotifyController(Platform platform) : super(platform);

  spotify.API spController = new spotify.API();

  @override
  getPlatformInformations() {
    platform.platformInformations['logo'] = 'assets/logo/spotify_logo.png';
    platform.platformInformations['icon'] =
        'assets/logo/icons/spotify_icon.png';
    platform.platformInformations['color'] = Colors.green[800];
    return platform.platformInformations;
  }

  @override
  getUserInformations() {
    return platform.userInformations;
  }

  @override
  Future<List<Playlist>> getPlaylists() async {
    List<Playlist> finalPlaylists = List<Playlist>();
    List<Playlist> playlists = await spController.getPlaylistsList();
    for(Playlist play in platform.playlists) {
      for(int i=0; i<playlists.length; i++) {
        if(play.id == playlists[i].id) {
          finalPlaylists.add(playlists[i]);
          playlists.removeAt(i);
        }
      }
    }
    for(Playlist play in playlists) {
      play.setTracks(await spController.getPlaylistSongs(play));
      finalPlaylists.add(play);
    }
    for(int i=0; i<platform.playlists.length; i++) {
      if(platform.playlists[i].getTracks().length == 0)
        finalPlaylists[i].setTracks(await spController.getPlaylistSongs(finalPlaylists[i]));
      else
        finalPlaylists[i].setTracks(platform.playlists[i].getTracks());
    }
    return platform.setPlaylist(finalPlaylists);
  }

  @override
  Future<List<Track>> getTracks(Playlist playlist) async {
    List<Track> finalTracks = List<Track>();

    if(playlist.getTracks().length == 0) {
      List<Track> tracks = await spController.getPlaylistSongs(playlist);
      for(Track track in playlist.getTracks()) {
        for(int i=0; i<tracks.length; i++) {
          if(track.id == tracks[i].id) {
            finalTracks.add(tracks[i]);
            tracks.removeAt(i);
          }
        }
      }
      for(Track track in tracks) {
        finalTracks.add(track);
      }
    } else {
      finalTracks = playlist.getTracks();
    }
    
    return playlist.setTracks(finalTracks);
  }

  @override
  connect() async {
    await spController.login();
    platform.userInformations['isConnected'] = spController.isLoggedIn;
    this.updateStates();
  }

  @override
  disconnect() {
    spController.disconnect();
    platform.userInformations['isConnected'] = spController.isLoggedIn;
    this.updateStates();
  }

  @override
  updateInformations() {
    return null;
  }

  @override
  Playlist addPlaylist({@required String name, @required String ownerId, String ownerName, String imageUrl, String playlistUri, List<MapEntry<Track, DateTime>> tracks}) {
    // TODO: implement removePlaylist
    throw UnimplementedError();
  }

  @override
  Playlist removePlaylist(int playlistIndex) {
    // TODO: implement removePlaylist
    throw UnimplementedError();
  }
}
