import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/AppManager/DatabaseController.dart';
import 'package:smartshuffle/Controller/AppManager/GlobalQueue.dart';
import 'package:smartshuffle/Controller/AppManager/ServicesLister.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/Model/Util.dart';
import 'package:smartshuffle/View/ViewGetter/Librairie/TabsPopupItems.dart';

class Playlist {

  static const String DEFAULT_IMAGE_URL = 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Solid_purple.svg/2048px-Solid_purple.svg.png';

  String _id;
  String _name;
  Uri _uri;
  String _ownerId;
  String _ownerName;
  String _imageUrl = DEFAULT_IMAGE_URL;
  ServicesLister _service;
  Platform _platform;

  List<MapEntry<Track, DateTime>> _tracks = <MapEntry<Track, DateTime>>[];

  Map<String, bool> _sortDirection = {'title': null, 'last_added': null, 'artist': null};

  Playlist(
      {@required String name,
      @required String id,
      @required ServicesLister service,
      @required String ownerId,
      String imageUrl,
      Uri uri,
      String ownerName,
      List<MapEntry<Track, DateTime>> tracks}) {
    _id = id;
    _name = name;
    _ownerId = ownerId;
    _uri = uri;
    _ownerName = ownerName;
    _service = service;
    _platform = PlatformsLister.platforms[_service].platform;
    if(imageUrl != null) _imageUrl = imageUrl;
    if (tracks != null) _tracks = tracks;
  }

  /*  SETTERS AND GETTER  */

  // Id
  set id(String id) {
    _id = id;
    // DataBaseController().updatePlaylist(this);
  }
  String get id => _id;

  // Name
  set name(String name) {
    _name = name;
    DataBaseController().updatePlaylist(this);
  }
  String get name => _name;
  
  // Owner
  set ownerId(String ownerId) {
    _ownerId = ownerId;
    DataBaseController().updatePlaylist(this);
  }
  String get ownerId => _ownerId;
  set ownerName(String ownerName) {
    _ownerName = ownerName;
    DataBaseController().updatePlaylist(this);
  }
  String get ownerName => _ownerName;

  // Image url
  set imageUrl(String imageUrl) {
    _imageUrl = imageUrl;
    DataBaseController().updatePlaylist(this);
  }
  String get imageUrl => _imageUrl;

  // Sort direction
  Map<String, bool> get sortDirection => _sortDirection;

  // Uri
  set uriPath(String uri) {
    _uri = Uri.parse(uri);
    DataBaseController().updatePlaylist(this);
  }
  Uri get uri => _uri;

  // Service
  set service(ServicesLister service) {
    _service = service;
    DataBaseController().updatePlaylist(this);
  }
  ServicesLister get service => _service;

  // Tracks
  List<MapEntry<Track, DateTime>> get tracks => _tracks;


  /*  TRACKS MANAGER  */

  String addTrack(Track track, {@required bool isNew}) {
    Track existingTrack = Util.checkTrackExistence(_platform, track);
    if(_platform.allPlatformTracks.isEmpty || existingTrack == null) {
      if(isNew) {
        DataBaseController().insertTrack(this, track);
      }
      _platform.allPlatformTracks.add(track);
      tracks.insert(0, MapEntry(track, DateTime.now()));
    } else {
      if(isNew) {
        DataBaseController().addRelation(this, track);
      }
      tracks.insert(0, MapEntry(existingTrack, DateTime.now()));
    }
    return track.id;
  }

  Track removeTrack(int index) {
    Track deletedTrack = tracks.removeAt(index).key;
    return deletedTrack;
  }

  List<Track> get getTracks {
    List<Track> finalTracks = <Track>[];
    for (MapEntry<Track, DateTime> track in _tracks) {
      finalTracks.add(track.key);
    }
    return finalTracks;
  }

  List<Track> setTracks(List<Track> tracks, {@required bool isNew}) {
    List<Track> allTracks = tracks;
    _tracks.clear();
    for (Track track in allTracks) {
      Track existingTrack = Util.checkTrackExistence(_platform, track);
      if(_platform.allPlatformTracks.isEmpty || existingTrack == null) {
        if(isNew) {
          DataBaseController().insertTrack(this, track);
        }
        _platform.allPlatformTracks.add(track);
        _tracks.add(MapEntry(track, track.addedDate));
      } else {
        if(isNew) {
          DataBaseController().addRelation(this, track);
        }
        _tracks.add(MapEntry(existingTrack, track.addedDate));
      }
    }
    DataBaseController().isOperationFinished.value = true;
    return allTracks;
  }

  List<Track> addTracks(List<Track> tracks, {@required bool isNew}) {
    List<Track> allTracks = tracks;
    for (Track track in allTracks) {
      bool exist = false;
      for (Track rTrack in getTracks) {
        if (rTrack.id == track.id) exist = true;
      }
      if (!exist) {
        this.addTrack(track, isNew: isNew);
      }
    }
    DataBaseController().isOperationFinished.value = true;
    return allTracks;
  }

  

  String _updateImage() {
    if(_imageUrl == Playlist.DEFAULT_IMAGE_URL) {
      if(_tracks.length >= 1) {
        _imageUrl = _tracks[0].key.imageUrlLarge;
      }
    }
    DataBaseController().updatePlaylist(this);
    return _imageUrl;
  }

  List<Track> reorder(int oldIndex, int newIndex) {
    MapEntry elem = tracks.removeAt(oldIndex);
    tracks.insert(newIndex, elem);
    //Save in system
    return getTracks;
  }

  List<Track> sort(String value) {
    
    if (value == PopupMenuConstants.SORTMODE_LASTADDED) {
      if(_sortDirection[value] == null || !_sortDirection[value]) {
        tracks.sort((a, b) {
          int _a = int.parse(a.value.year.toString() +
              a.value.month.toString() +
              a.value.day.toString());
          int _b = int.parse(b.value.year.toString() +
              b.value.month.toString() +
              b.value.day.toString());
          return _a.compareTo(_b);
        });
        for(String me in _sortDirection.keys) {
          _sortDirection[me] = null;
        }
        _sortDirection[value] = true;
      } else {
        tracks.sort((a, b) {
          int _a = int.parse(a.value.year.toString() +
              a.value.month.toString() +
              a.value.day.toString());
          int _b = int.parse(b.value.year.toString() +
              b.value.month.toString() +
              b.value.day.toString());
          return _b.compareTo(_a);
        });
        for(String me in _sortDirection.keys) {
          _sortDirection[me] = null;
        }
        _sortDirection[value] = false;
      }
    }

    if (value == PopupMenuConstants.SORTMODE_TITLE) {
      if(_sortDirection[value] == null || !_sortDirection[value]) {
        tracks.sort((a, b) {
          String _a = a.key.title;
          String _b = b.key.title;

          return _a.compareTo(_b);
        });
        for(String me in _sortDirection.keys) {
          _sortDirection[me] = null;
        }
        _sortDirection[value] = true;
      } else {
        tracks.sort((a, b) {
          String _a = a.key.title;
          String _b = b.key.title;

          return _b.compareTo(_a);
        });
        for(String me in _sortDirection.keys) {
          _sortDirection[me] = null;
        }
        _sortDirection[value] = false;
      }
    }

    if (value == PopupMenuConstants.SORTMODE_ARTIST) {
      if(_sortDirection[value] == null || !_sortDirection[value]) {
        tracks.sort((a, b) {
          String _a = a.key.artist;
          String _b = b.key.artist;

          return _a.compareTo(_b);
        });
        for(String me in _sortDirection.keys) {
          _sortDirection[me] = null;
        }
        _sortDirection[value] = true;
      } else {
        tracks.sort((a, b) {
          String _a = a.key.artist;
          String _b = b.key.artist;

          return _b.compareTo(_a);
        });
        for(String me in _sortDirection.keys) {
          _sortDirection[me] = null;
        }
        _sortDirection[value] = false;
      }
    }
    DataBaseController().updatePlaylist(this);

    return getTracks;
  }

  bool isMine(Track track) {
    return getTracks.contains(track);
  }



  // Object persistence

  factory Playlist.fromMap(Map<String, dynamic> json) => Playlist(
    id: json['id'],
    ownerId: json['ownerid'],
    ownerName: json['ownername'],
    service: PlatformsLister.nameToService(json['service']),
    name: json['name'],
    imageUrl: json['imageurl'],
    uri: Uri.parse(json['uri'])
  );

  Map<String, dynamic> toMap() =>
  {
    'id': _id,
    'service': _service.toString().split(".")[1],
    'platform_name': PlatformsLister.platforms[_service].platform.name,
    'ordersort': PlatformsLister.platforms[_service].platform.playlists.value.indexOf(this),
    'name': name,
    'ownerid': ownerId,
    'ownername': ownerName,
    'imageurl': imageUrl,
    'uri': uri.toString()
  };
}
