import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smartshuffle/Controller/AppManager/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Track.dart';

import 'api_path.dart';

import 'package:http/http.dart';
import 'dart:io';
import 'dart:convert';

import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'api_auth.dart';

class API {
  static final API _instance = API._internal();
  String _token;
  bool _isLoggedIn;
  static final storage = new FlutterSecureStorage();
  
  String _displayName;
  String _email;
  String _userId;

  get displayName => _displayName;
  get email => _email;

  factory API() {
    return _instance;
  }

  API._internal();

  get isLoggedIn {
    return _isLoggedIn;
  }

  ///
  ///Getter
  ///

  Future<List<Playlist>> getPlaylistsList() async {
    Response response =
        await get(APIPath.getPlaylistsList(), headers: _prepareHeader());
    Map json = jsonDecode(response.body);

    String next = json['next'];

    List<Playlist> list = <Playlist>[];

    do {
      next = json['next'];
      _playlistList(list, json);

      if (json['next'] != null) {
        response = await get(Uri.parse(next), headers: _prepareHeader());
        json = jsonDecode(response.body);
      }
    } while (next != null);
    return list;
  }

  Future<List<Track>> getPlaylistSongs(Playlist playlist) async {
    Response response = await get(APIPath.getPlaylistSongs(playlist),
        headers: _prepareHeader());
    Map json = jsonDecode(response.body);

    String next = json['next'];

    List<Track> tracks = <Track>[];

    do {
      next = json['next'];
      _songsList(tracks, json);

      if (json['next'] != null) {
        response = await get(Uri.parse(next), headers: _prepareHeader());
        json = jsonDecode(response.body);
      }
    } while (next != null);

    return tracks;
  }

  Future _getUserProfile() async {
    Response response = await get(APIPath.getUserProfile(),
        headers: _prepareHeader());
    Map json = jsonDecode(response.body);

    _displayName = json['display_name'];
    _email = json['email'];
    _userId = json['id'];
  }

  ///
  ///Setter
  ///
  void setPlaylistName(Playlist p) {
    String body = '{"name": "' + p.name + '"}';
    put(APIPath.getPlaylist(p), headers: _prepareHeader(), body: body);
  }

  Future<Playlist> createPlaylist(Playlist p) async {
    String body = '{"name": "${p.name}", "public": false}';
    final response = await post(APIPath.createPlaylist(_userId), headers: _prepareHeader(), body: body);
    p.uriPath = jsonDecode(response.body)['uri'];
    p.id = jsonDecode(response.body)['id'];
    return p;
  }

  void addTracks(Playlist p, List<String> uris) {
    post(APIPath.addTracks(p, uris), headers: _prepareHeader());
  }

  void removeTracks(Playlist p, List<String> uris) {
    String body = '{"tracks": [';
    for(String uri in uris) {
      body += '{"uri":"$uri"},';
    }
    body.substring(0, body.length-1);
    body += ']}';
    delete(APIPath.removeTracks(p, uris), body: body);
  }

  ///
  ///Public
  ///
  Future login({String storeToken}) async {
    if(storeToken == null) {
      var token = await APIAuth.login();
      if (token == null) {
        _isLoggedIn = false;
      } else {
        _isLoggedIn = true;
        _token = token;
        storage.write(key: 'spotify', value: token);
        await _getUserProfile();
      }
    } else {
      _isLoggedIn = true;
      _token = storeToken;
      await _getUserProfile();
    }
    // print('Spotify token :');
    // print(token);
  }

  void disconnect() async {
    _isLoggedIn = await APIAuth.logout();
    await storage.delete(key: 'spotify');
  }

  ///
  ///Private
  ///
  Map<String, String> _prepareHeader() {
    return {
      HttpHeaders.contentTypeHeader: "application/json", // or whatever
      HttpHeaders.authorizationHeader: "Bearer $_token",
    };
  }

  void _playlistList(List<Playlist> list, Map json) {
    List<dynamic> items = json['items'];
    for (int i = 0; i < items.length; i++) {
      String id = items[i]['id'];
      String name = items[i]['name'];
      String trackUri = items[i]['tracks']['href'];
      String ownerId =
          items[i]['owner']['external_urls']['spotify'].split('user/')[1];
      String ownerName = items[i]['owner']['display_name'];
      String imageUrl = 'https://source.unsplash.com/random';
      try {
        imageUrl = items[i]['images'][0]['url'];
      } catch (e) {}
      list.add(Playlist(
          id: id,
          name: name,
          uri: Uri.parse(trackUri),
          ownerId: ownerId,
          ownerName: ownerName,
          imageUrl: imageUrl,
          service: ServicesLister.SPOTIFY));
    }
  }

  void _songsList(List<Track> list, Map json) {
    List<dynamic> items = json['items'];
    for (int i = 0; i < items.length; i++) {
      String name = "None";
      String artist = "None";
      String id = null;
      //* Le format d'image est 64x64
      String imageUrlLittle = null;
      //* Le format d'image est 640x640
      String imageUrlLarge = null;
      String addDate = null;

      Duration duration = null;
      try {
        id = items[i]['track']['id'];
        name = items[i]['track']['name'];
        addDate = items[i]['added_at'];
        artist = _getAllArtist(items[i]['track']['album']['artists']);
        imageUrlLittle = items[i]['track']['album']['images'][2]['url'];
        imageUrlLarge = items[i]['track']['album']['images'][0]['url'];
        duration = Duration(milliseconds: items[i]['track']['duration_ms']);
      } catch (e) {
        imageUrlLittle = "https://source.unsplash.com/random";
      }
      if (id != null) {
        list.add(Track(
            id: id,
            title: name,
            artist: artist,
            addedDate: DateTime.parse(addDate),
            imageUrlLittle: imageUrlLittle,
            imageUrlLarge: imageUrlLarge,
            totalDuration: duration,
            service: ServicesLister.SPOTIFY,));
      }
    }
  }

  String _getAllArtist(dynamic json) {
    String artists = "";
    for (int i = 0; i < json.length - 1; i++) {
      artists += json[i]['name'] + ", ";
    }
    artists += json[json.length - 1]['name'];
    return artists;
  }
}
