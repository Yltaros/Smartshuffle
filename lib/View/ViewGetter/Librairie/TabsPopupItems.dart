import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:smartshuffle/Model/Object/Playlist.dart';


class PopupMenuConstants {
  static const String SORTMODE_LASTADDED = 'last_added';
  static const String SORTMODE_TITLE = 'title';
  static const String SORTMODE_ARTIST = 'artist';

  static const String TRACKSMAINDIALOG_ADDTOQUEUE = 'TRACKSMAINDIALOG:add_to_queue';
  static const String TRACKSMAINDIALOG_ADDTOANOTHERPLAYLIST = 'TRACKSMAINDIALOG:add_to_another_playlist';
  static const String TRACKSMAINDIALOG_REMOVEFROMPLAYLIST = 'TRACKSMAINDIALOG:remove_from_playlist';
  static const String TRACKSMAINDIALOG_INFORMATIONS = 'TRACKSMAINDIALOG:informations';
  static const String TRACKSMAINDIALOG_REPORT = 'TRACKSMAINDIALOG:report';

  static const String PLAYLISTSMAINDIALOG_RENAME = "PLAYLISTMAINDIALOG:rename";
  static const String PLAYLISTSMAINDIALOG_CLONE = "PLAYLISTMAINDIALOG:clone";
  static const String PLAYLISTSMAINDIALOG_MERGE = "PLAYLISTMAINDIALOG:merge";
  static const String PLAYLISTSMAINDIALOG_DELETE = "PLAYLISTMAINDIALOG:delete";
}


/*  SORT TRACKS ITEMS  */

class SortPopupItemLastAdded extends StatelessWidget {

  final Playlist playlist;

  SortPopupItemLastAdded(this.playlist);

  @override
  PopupMenuItem build(BuildContext context) {
    return PopupMenuItem(
      value: PopupMenuConstants.SORTMODE_LASTADDED,
      child: Row(
        children: [
          Text(AppLocalizations.of(context).popupItemAddedRecently),
          (playlist.sortDirection['last_added'] != null ?
            Icon(
              (playlist.sortDirection['last_added'] ? Icons.arrow_upward : Icons.arrow_downward)
            ) : Container(width: 0,height: 0,)
          ),
        ]
      )
    );
  }

}

class SortPopupItemTitle extends StatelessWidget {

  final Playlist playlist;

  SortPopupItemTitle(this.playlist);

  @override
  PopupMenuItem build(BuildContext context) {
    return PopupMenuItem(
      value: PopupMenuConstants.SORTMODE_TITLE,
      child: Row(
        children: [
          Text(AppLocalizations.of(context).popupItemTitle),
          (playlist.sortDirection['title'] != null ?
            Icon(
              (playlist.sortDirection['title'] ? Icons.arrow_upward : Icons.arrow_downward)
            ) : Container(width: 0,height: 0,)
          ),
        ]
      ),
    );
  }

}

class SortPopupItemArtist extends StatelessWidget {

  final Playlist playlist;

  SortPopupItemArtist(this.playlist);

  @override
  PopupMenuItem build(BuildContext context) {
    return PopupMenuItem(
      value: PopupMenuConstants.SORTMODE_ARTIST,
      child: Row(
        children: [
          Text(AppLocalizations.of(context).globalArtist),
          (playlist.sortDirection['artist'] != null ?
            Icon(
              (playlist.sortDirection['artist'] ? Icons.arrow_upward : Icons.arrow_downward)
            ) : Container(width: 0,height: 0,)
          ),
        ]
      ),
    );
  }

}



/*  TRACKS MAIN DIALOG OPTIONS  */

class TracksPopupItemAddToQueue extends StatelessWidget {

  @override
  PopupMenuItem build(BuildContext context) {
    return PopupMenuItem(
      value: PopupMenuConstants.TRACKSMAINDIALOG_ADDTOQUEUE,
      child: Text(AppLocalizations.of(context).popupItemAddToQueue)
    );
  }

}

class TracksPopupItemAddToAnotherPlaylist extends StatelessWidget {

  @override
  PopupMenuItem build(BuildContext context) {
    return PopupMenuItem(
      value: PopupMenuConstants.TRACKSMAINDIALOG_ADDTOANOTHERPLAYLIST,
      child: Text(AppLocalizations.of(context).popupItemAddToAnotherPlaylist)
    );
  }

}

class TracksPopupItemRemoveFromPlaylist extends StatelessWidget {

  @override
  PopupMenuItem build(BuildContext context) {
    return PopupMenuItem(
      value: PopupMenuConstants.TRACKSMAINDIALOG_REMOVEFROMPLAYLIST,
      child: Text(AppLocalizations.of(context).popupItemRemoveFromPlaylist)
    );
  }

}

class TracksPopupItemInformations extends StatelessWidget {

  @override
  PopupMenuItem build(BuildContext context) {
    return PopupMenuItem(
      value: PopupMenuConstants.TRACKSMAINDIALOG_INFORMATIONS,
      child: Text(AppLocalizations.of(context).globalInformations)
    );
  }

}

class TracksPopupItemReport extends StatelessWidget {

  @override
  PopupMenuItem build(BuildContext context) {
    return PopupMenuItem(
      value: PopupMenuConstants.TRACKSMAINDIALOG_REPORT,
      child: Text(AppLocalizations.of(context).globalReport)
    );
  }

}



/*  PLAYLISTS MAIN DIALOG OPTIONS  */

class PlaylistsPopupItemRename extends StatelessWidget {

  @override
  PopupMenuItem build(BuildContext context) {
    return PopupMenuItem(
      value: PopupMenuConstants.PLAYLISTSMAINDIALOG_RENAME,
      child: Text(AppLocalizations.of(context).globalRename)
    );
  }

}

class PlaylistsPopupItemClone extends StatelessWidget {

  @override
  PopupMenuItem build(BuildContext context) {
    return PopupMenuItem(
      value: PopupMenuConstants.PLAYLISTSMAINDIALOG_CLONE,
      child: Text(AppLocalizations.of(context).tabsViewClonePlaylist)
    );
  }

}

class PlaylistsPopupItemMerge extends StatelessWidget {

  @override
  PopupMenuItem build(BuildContext context) {
    return PopupMenuItem(
      value: PopupMenuConstants.PLAYLISTSMAINDIALOG_MERGE,
      child: Text(AppLocalizations.of(context).tabsViewMergePlaylist)
    );
  }

}

class PlaylistsPopupItemDelete extends StatelessWidget {

  @override
  PopupMenuItem build(BuildContext context) {
    return PopupMenuItem(
      value: PopupMenuConstants.PLAYLISTSMAINDIALOG_DELETE,
      child: Text(AppLocalizations.of(context).delete)
    );
  }

}