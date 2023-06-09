import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smartshuffle/Controller/AppManager/AppInit.dart';
import 'package:smartshuffle/Controller/AppManager/ServicesLister.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/Players/FrontPlayer.dart';

import 'package:smartshuffle/Model/Util.dart';
import 'package:smartshuffle/View/ViewGetter/Librairie/CustomLibrairieWidget.dart';
import 'package:smartshuffle/View/ViewGetter/Librairie/TabsView.dart';


class PlaylistsPage extends StatefulWidget {

  PlaylistsPage({Key key}) : super(key: key);

  @override
  PlaylistsPageState createState() => PlaylistsPageState();
}

class PlaylistsPageState extends State<PlaylistsPage> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {

  final MaterialColor _materialColor = GlobalTheme.material_color;
  final ThemeData _themeData = GlobalTheme.themeData;

  Key key = UniqueKey();
  Key tabKey = UniqueKey();

  bool exitPage = true;
  TabController tabController;
  int initialTabIndex = 0;

  Map<TabView, bool> isPlaylistOpen = <TabView, bool>{};

  Map<ServicesLister, PlatformsController> userPlatforms = new Map<ServicesLister, PlatformsController>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    FrontPlayerController().addView('playlist', this);
    super.initState();
  }




  void exitDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).globalQuit, style: TextStyle(color: Colors.white)),
          actions: [
            FlatButton(child: Text(AppLocalizations.of(context).no, style: TextStyle(color: Colors.white)), onPressed: () => Navigator.pop(dialogContext)),
            FlatButton(child: Text(AppLocalizations.of(context).yes, style: TextStyle(color: Colors.white)), onPressed: () => exit(0)),
          ],
          backgroundColor: Colors.grey[800],
        );
      }
    );
  }




  // Widget tabBar() {
  //   List elements = <Widget>[];
  //   for(MapEntry elem in this.userPlatforms.entries) {
  //     elements.add(Tab(icon: ImageIcon(AssetImage(elem.value.platformInformations['icon']))));
  //   }
  //   return TabBar(
  //     controller: this.tabController,
  //     indicatorColor: _materialColor.shade300,
  //     tabs: elements,
  //   );
  // }

  void userPlatformsInit() {
    this.userPlatforms.clear();
    for(MapEntry<ServicesLister, PlatformsController> elem in PlatformsLister.platforms.entries) {
      if(elem.value.userInformations['isConnected'] == true)
        this.userPlatforms[elem.key] = elem.value;
    }
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    StatesManager.setPlaylistsPageState(this);

    userPlatformsInit();
    List<PlatformsController> platformsList = GlobalAppController.getAllConnectedControllers();

    if(initialTabIndex >= platformsList.length) initialTabIndex = 0;
    tabController = TabController(initialIndex: initialTabIndex, length: this.userPlatforms.length, vsync: this);
    tabController.addListener(() {
      initialTabIndex = tabController.index;
    });

    List<TabView> tabs = List.generate(platformsList.length, (index) {
      return TabView(platformsList[index], parent: this);
    });

    List elements = <Widget>[];
    for(MapEntry elem in this.userPlatforms.entries) {
      elements.add(Tab(icon: ImageIcon(AssetImage(elem.value.platformInformations['icon']))));
    }

    return MaterialApp(
      theme: _themeData,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('fr', ''),
        const Locale('en', ''),
      ],
      home: Scaffold(
        key: this.tabKey,
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Theme(
            data: ThemeData(
              brightness: Brightness.dark,
              primaryColor: Colors.black,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            child: AppBar(
              title: TabBar(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                indicator: CircularTabIndicator(color: _materialColor.shade300, radius: 3, width: 70, index: tabController.index),
                onTap: (int index) {
                  if(index == tabController.index) {
                    if(!isPlaylistOpen[tabs[tabController.index]]) {
                      tabs[tabController.index].playlistScrollController.animateTo(0, duration: Duration(milliseconds: 150), curve: Curves.ease);
                    } else {
                      tabs[tabController.index].tracksScrollController.animateTo(0, duration: Duration(milliseconds: 150), curve: Curves.ease);
                    }
                  }
                },
                controller: tabController,
                indicatorColor: _materialColor.shade300,
                tabs: elements
              ),
            )
          )
        ),
        body: WillPopScope(
            child: TabBarView(
            controller: tabController,
            children: tabs,
          ),
          onWillPop: () async {
            if(!isPlaylistOpen[tabs[tabController.index]]) {
              if(tabController.index == 0) exitDialog();
              else tabController.animateTo(0);
              return false;
            } else {
              return true;
            }
          }
        )
      )
    );
    
  }
}