import 'package:smartshuffle/Model/Object/Playlist.dart';

class APIPath {
  static String getPlaylistsList() {
    return "https://api.spotify.com/v1/me/playlists";
  }

  static String getPlaylistSongs(Playlist playlist) {
    return playlist.uri;
  }

  static String getUserProfile() {
    return "https://api.spotify.com/v1/me";
  }

  static String getPlaylist(Playlist playlist) {
    return "https://api.spotify.com/v1/playlists/" + playlist.id;
  }
}