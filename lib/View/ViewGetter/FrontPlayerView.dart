

import 'dart:ui';

import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:smartshuffle/Controller/GlobalQueue.dart';
import 'package:smartshuffle/Controller/Players/FrontPlayer.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/Model/Object/UsefullWidget/extents_page_view.dart';
import 'package:smartshuffle/View/GlobalApp.dart';
import 'package:smartshuffle/View/ViewGetter/Librairie/TabsPopupItems.dart';
import 'package:smartshuffle/View/ViewGetter/Librairie/TabsView.dart';

class FrontPlayerView extends StatefulWidget {

  final MaterialColor materialColor = MaterialColorApplication.material_color;

  @override
  State<StatefulWidget> createState() => _FrontPlayerViewState();
  
}


class _FrontPlayerViewState extends State<FrontPlayerView> {

  // Controllers
  PanelController _panelCtrl = PanelController();
  PanelController _panelQueueCtrl = PanelController();

  // Queue panel is locked when _panelCtrl is close
  ValueNotifier<bool> _isPanelQueueDraggable = ValueNotifier<bool>(true);


  /* =========================== */
  
  // Global frontend strucutre variables;
  double _screen_width;
  double _screen_height;
  double _ratio = 1;

  // Front constant
  static double _image_size_large;
  static double _image_size_little;
  static double _side_marge;
  static double _botbar_height = 56;
  static double _playbutton_size_large;
  static double _playbutton_size_little;
  static double _text_size_large;
  static double _text_size_little;
  static Color _main_image_color = Colors.black87;

  // Front variables
  double _botBarHeight;
  double _imageSize;
  double _sideMarge;
  double _playButtonSize;
  double _textSize;
  double _elementsOpacity;
  double _currentSliderValue;


  /* =========================== */

  void _constantBuilder() {
    _screen_width = MediaQuery.of(context).size.width;
    _screen_height = MediaQuery.of(context).size.height;

    _image_size_large = _screen_width * 0.7;
    _image_size_little = _screen_width * 0.16;
    _side_marge = (_screen_width - _image_size_little) * 0.5;
    _playbutton_size_large = _screen_width * 0.15;
    _playbutton_size_little = _screen_width * 0.1;
    _text_size_large = _screen_height * 0.02;
    _text_size_little = _screen_height * 0.015;
  }

  void _sizeBuilder() {
    if (_imageSize == null) _imageSize = _image_size_little;
    if (_sideMarge == null) _sideMarge = _side_marge;
    if (_playButtonSize == null) _playButtonSize = _playbutton_size_little;
    if (_textSize == null) _textSize = _text_size_little;
    if (_elementsOpacity == null) _elementsOpacity = 0;
  }

  void _preventFromNullValue(double height) {
    if (_imageSize < _image_size_little) _imageSize = _image_size_little;
    if (_playButtonSize < _playbutton_size_little) _playButtonSize = _playbutton_size_little;
    if (_textSize < _text_size_little) _textSize = _text_size_little;
  }

  void _switchPanelSize(double height) {
    setState(() {
      FocusScope.of(context).unfocus();

      _ratio = height;

      _botBarHeight = _botbar_height - (_ratio * _botbar_height);
      if (_imageSize >= _image_size_little) _imageSize = _image_size_large * _ratio;
      _sideMarge = (1 - _ratio) * _side_marge;
      if(_playButtonSize >= _playbutton_size_little) _playButtonSize = _playbutton_size_large * _ratio;
      if(_textSize >= _text_size_little) _textSize = _text_size_large * _ratio;
      _elementsOpacity = _ratio;

      _preventFromNullValue(_ratio);
    });
  }


  /* =========================== */

  Future<void> _initAudioService() async {
    await AudioService.connect();
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
  }

  @override
  void initState() {
    FrontPlayerController().onBuildPage();
    _initAudioService();
    super.initState();
  }

  @override
  void dispose() {
    AudioService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    _constantBuilder();
    _sizeBuilder();

    return Stack(
      children: [
        WillPopScope(
          onWillPop: () async {
            if(_panelCtrl.isPanelOpen) {
              if(_panelQueueCtrl.isPanelOpen) {
                _panelQueueCtrl.close();
              } else {
                _panelCtrl.close();
              }
              return false;
            } else
              return true;
          },
          child: SlidingUpPanel(
            isDraggable: FrontPlayerController().pageCtrl.hasClients ? ((FrontPlayerController().pageCtrl.page??0.0 % 1) < 0 && (FrontPlayerController().pageCtrl.page??0.0 % 1) > 1 ? false : true) : true,
            onPanelSlide: (height) => _switchPanelSize(height),
            controller: _panelCtrl,
            minHeight: _botbar_height+10,
            maxHeight: _screen_height,
            panelBuilder: (scrollCtrl) {
              if(FrontPlayerController().currentTrack.value.id == null) _panelCtrl.hide();
              return GestureDetector(
                onTap: () => _panelCtrl.panelPosition < 0.3 ? _panelCtrl.open() : null,
                child: Stack(
                  key: ValueKey('FrontPLayer'),
                  children: [
                    ValueListenableBuilder(
                      valueListenable: GlobalQueue.queue,
                      builder: (_, List<MapEntry<Track, bool>> queue ,__) {

                        FrontPlayerController().currentTrack.value = queue[GlobalQueue.currentQueueIndex].key;
                        FrontPlayerController().currentTrack.value.seekTo(Duration.zero, false);
                        // FrontPlayerController().currentTrack.value.currentDuration.addListener(positionCheck);
                        
                        return ExtentsPageView.extents(
                          extents: 3, 
                          physics: _panelCtrl.panelPosition < 1 && _panelCtrl.panelPosition > 0.01 ? NeverScrollableScrollPhysics() : PageScrollPhysics(),
                          //itemCount: GlobalQueue.queue.value.length,
                          onPageChanged: (index) {
                            if(index >= GlobalQueue.queue.value.length) {
                              FrontPlayerController().pageCtrl.jumpToPage(index % GlobalQueue.queue.value.length);
                              FrontPlayerController().nextTrack(backProvider: false);
                            }
                          },
                          controller: FrontPlayerController().pageCtrl,
                          itemBuilder: (buildContext, index) {

                                int realIndex = index % GlobalQueue.queue.value.length;

                                Track trackUp = queue[realIndex].key;
                                print('trackup : $trackUp');
                                // _timer?.cancel();
                                // _timer = Timer.periodic(Duration(seconds: 1), (timer) {
                                //   _timer = timer;
                                //   if(trackUp.currentDuration.value < trackUp.totalDuration.value) {
                                //     trackUp.currentDuration.value = Duration(seconds: trackUp.currentDuration.value.inSeconds+1);
                                //     trackUp.currentDuration.notifyListeners();
                                //   } else {
                                //     _timer.cancel();
                                //   }
                                // });

                                return Stack(
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(trackUp.imageUrlLittle),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          ClipRect(
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                                child: Container(
                                                  color: Colors.black.withOpacity(0.55),
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                      ValueListenableBuilder(
                                        valueListenable: trackUp.totalDuration,
                                        builder: (BuildContext context, Duration duration, __) {
                                          return Positioned(
                                            top: (_screen_height * 0.77),
                                            right: (_screen_width / 2) - _screen_width * 0.45,
                                            child: Opacity(
                                              opacity: _elementsOpacity,
                                              child: InkWell(
                                                child: Text(duration.toString().split(':')[1] +
                                                    ':' + duration.toString().split(':')[2].split('.')[0]
                                                )
                                              )
                                            )
                                          );
                                        }
                                      ),
                                      ValueListenableBuilder(
                                        valueListenable: trackUp.currentDuration,
                                        builder: (BuildContext context, Duration duration, __) {
                                          // print(duration);
                                          return Stack(
                                            children: [
                                              Positioned(
                                                top: (_screen_height * 0.77),
                                                left: (_screen_width / 2) - _screen_width * 0.45,
                                                child: Opacity(
                                                  opacity: _elementsOpacity,
                                                  child: InkWell(
                                                    child: Text(duration.toString().split(':')[1] +
                                                      ':' + duration.toString().split(':')[2].split('.')[0]
                                                    )
                                                  )
                                                )
                                              ),
                                              Positioned(
                                                top: (_screen_height * 0.75),
                                                left: _screen_width / 2 - ((_screen_width - (_screen_width / 4)) / 2),
                                                child: Opacity(
                                                  opacity: _elementsOpacity,
                                                  child: Container(
                                                    width: _screen_width - (_screen_width / 4),
                                                    child: Slider.adaptive(
                                                      value: () {
                                                        duration.inSeconds / trackUp.totalDuration.value.inSeconds >= 0
                                                        && duration.inSeconds / trackUp.totalDuration.value.inSeconds <= 1
                                                          ? _currentSliderValue = duration.inSeconds / trackUp.totalDuration.value.inSeconds
                                                          : _currentSliderValue = 0.0;
                                                          return _currentSliderValue;
                                                      }.call(),
                                                      onChanged: (double value) {
                                                        _panelCtrl.open();
                                                      },
                                                      onChangeEnd: (double value) {
                                                        trackUp.seekTo(Duration(seconds: (value * trackUp.totalDuration.value.inSeconds).toInt()), true);
                                                      },
                                                      min: 0,
                                                      max: 1,
                                                      activeColor: Colors.cyanAccent,
                                                    )
                                                  )
                                                )
                                              )
                                            ]
                                          );
                                        }
                                      ),
                                      Positioned(
                                        width: _imageSize,
                                        height: _imageSize,
                                        left: (_screen_width / 2 - (_imageSize / 2) - _sideMarge),
                                        top: (_screen_height / 4) * _ratio,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(trackUp.imageUrlLarge),
                                            )
                                          ),
                                        )
                                      ),
                                      Positioned(
                                        left: _screen_width * 0.2 * (1 - _ratio),
                                        top: (_screen_height * 0.60) * _ratio + (_sideMarge*0.06),
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(left: _screen_width * 0.15 * _ratio),
                                                  width: _screen_width - (_screen_width * 0.1 * 4),
                                                  child: Text(
                                                    trackUp.name,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(fontSize: _textSize + (5 * _ratio)),
                                                  )
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(left: _screen_width * 0.15 * _ratio),
                                                  width: _screen_width - (_screen_width * 0.1 * 4),
                                                  child: Text(
                                                    trackUp.artist,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontSize: _textSize,
                                                      fontWeight: FontWeight.w200),
                                                  )
                                                )
                                              ],
                                            ),
                                            IgnorePointer(
                                              ignoring: (_elementsOpacity == 1 ? false : true),
                                              child: Opacity(
                                                opacity: _elementsOpacity,
                                                child: InkWell(
                                                    onTap: () {
                                                      TabsView(this).addToPlaylist(trackUp, ctrl: PlatformsLister.platforms[trackUp.service]);
                                                    },
                                                    child: Icon(
                                                    Icons.add,
                                                    size: _playButtonSize - 10,
                                                  )
                                                )
                                              )
                                            )
                                          ]
                                        )
                                      ),
                                      Opacity(
                                        opacity: 1 - _elementsOpacity,
                                        child: ValueListenableBuilder(
                                          valueListenable: trackUp.currentDuration,
                                          builder: (BuildContext context, Duration duration, __) {
                                            return Container(
                                              constraints: BoxConstraints(
                                                maxWidth: duration.inSeconds * _screen_width / trackUp.totalDuration.value.inSeconds,
                                                minWidth: duration.inSeconds * _screen_width / trackUp.totalDuration.value.inSeconds
                                              ),
                                              color: Colors.white,
                                              width: duration.inSeconds * _screen_width / trackUp.totalDuration.value.inSeconds,
                                              height: 2,
                                            );
                                          }
                                        )
                                      )
                                    ]
                                  );
                                },
                              );
                      }
                    ),
                    Positioned(
                      top: (_screen_height * 0.05),
                      right: (_screen_width * 0.03),
                      child: IgnorePointer(
                        ignoring: (_elementsOpacity < 0.8 ? true : false),
                        child: Opacity(
                          opacity: _elementsOpacity,
                          child: PopupMenuButton(
                            iconSize: 35,
                            icon: Icon(Icons.more_vert),
                            tooltip: AppLocalizations.of(context).options,
                            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                              TracksPopupItemAddToQueue().build(context),
                              TracksPopupItemAddToAnotherPlaylist().build(context),
                              TracksPopupItemRemoveFromPlaylist().build(context),
                              TracksPopupItemInformations().build(context),
                              TracksPopupItemReport().build(context)
                            ],
                            onSelected: (value) {
                              TabsView(this).trackMainDialogOptions(
                                value,
                                name: FrontPlayerController().currentTrack.value.name,
                                ctrl: PlatformsLister.platforms[FrontPlayerController().currentTrack.value.service],
                                track: FrontPlayerController().currentTrack.value,
                                index: FrontPlayerController().currentPlaylist.getTracks.indexOf(FrontPlayerController().currentTrack.value)
                              );
                            },
                          )
                        )
                      )
                    ),
                    ValueListenableBuilder(
                      valueListenable: FrontPlayerController().currentTrack.value.isPlaying,
                      builder: (BuildContext context, bool isPlaying, Widget child) {
                        return Positioned(
                          top: (_screen_height * 0.80) * _ratio + (_sideMarge*0.07),
                          right: ((_screen_width / 2) - (_playButtonSize / 2) - _sideMarge),
                          child: InkWell(
                            onTap: () {
                              FrontPlayerController().currentTrack.value.playPause();
                            },
                            child: Icon(
                              !FrontPlayerController().currentTrack.value.isPlaying.value ? Icons.play_arrow : Icons.pause,
                              size: _playButtonSize,
                            )
                          )
                        );
                      }
                    ),
                    Positioned(
                      top: (_screen_height * 0.8),
                      right: (_screen_width / 2) - (_screen_width / 4),
                      child: Opacity(
                        opacity: _elementsOpacity,
                        child: InkWell(
                            onTap: () => FrontPlayerController().nextTrack(backProvider: false),
                            child: Icon(
                            Icons.skip_next,
                            size: _playButtonSize,
                          )
                        )
                      )
                    ),
                    Positioned(
                      top: (_screen_height * 0.8),
                      right: _screen_width - (_screen_width / 2.5),
                      child: Opacity(
                        opacity: _elementsOpacity,
                        child: InkWell(
                            onTap: () => FrontPlayerController().previousTrack(backProvider: false),
                            child: Icon(
                            Icons.skip_previous,
                            size: _playButtonSize,
                          )
                        )
                      )
                    ),
                    Positioned(
                      top: (_screen_height * 0.82),
                      right: (_screen_width / 2) - (_screen_width / 2.5),
                      child: Opacity(
                        opacity: _elementsOpacity,
                        child: InkWell(
                            onTap: () {
                              setState(() {
                                if(FrontPlayerController().isRepeatOnce && !FrontPlayerController().isRepeatAlways) {
                                  FrontPlayerController().isRepeatOnce = false;
                                  FrontPlayerController().isRepeatAlways = true;
                                } else if(FrontPlayerController().isRepeatAlways && !FrontPlayerController().isRepeatOnce) {
                                  FrontPlayerController().isRepeatAlways = false;
                                  FrontPlayerController().isRepeatOnce = false;
                                } else if(!FrontPlayerController().isRepeatOnce && !FrontPlayerController().isRepeatAlways) {
                                  FrontPlayerController().isRepeatOnce = true;
                                  FrontPlayerController().isRepeatAlways = false;
                                }
                              });
                            },
                            child: Icon(
                            () {
                              if(!FrontPlayerController().isRepeatOnce && !FrontPlayerController().isRepeatAlways) return Icons.repeat;
                              else if(FrontPlayerController().isRepeatOnce && !FrontPlayerController().isRepeatAlways) return Icons.repeat_one;
                              else if(FrontPlayerController().isRepeatAlways && !FrontPlayerController().isRepeatOnce) return Icons.repeat;
                            }.call(),
                            color: () {
                              if(!FrontPlayerController().isRepeatOnce && !FrontPlayerController().isRepeatAlways) return Colors.white;
                              else if(FrontPlayerController().isRepeatOnce && !FrontPlayerController().isRepeatAlways) return Colors.cyanAccent;
                              else if(FrontPlayerController().isRepeatAlways && !FrontPlayerController().isRepeatOnce) return Colors.cyanAccent;
                            }.call(),
                            size: _playButtonSize - 30,
                          )
                        )
                      )
                    ),
                    Positioned(
                      top: (_screen_height * 0.82),
                      left: (_screen_width / 2) - (_screen_width / 2.5),
                      child: Opacity(
                        opacity: _elementsOpacity,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if(FrontPlayerController().isShuffle) {
                                FrontPlayerController().setPlayType(isShuffle: false);
                              } else {
                                FrontPlayerController().setPlayType(isShuffle: true);
                              }
                            });
                          },
                            child: Icon(
                            Icons.shuffle,
                            color: () {
                              if(FrontPlayerController().isShuffle) return Colors.cyanAccent;
                              else return Colors.white;
                            }.call(),
                            size: _playButtonSize - 30,
                          )
                        )
                      )
                    )
                  ],
                ),
              );
          },
        ),
      ),
        ValueListenableBuilder(
          valueListenable: _isPanelQueueDraggable,
          builder: (BuildContext context, bool value, Widget child) {
            return IgnorePointer(
              ignoring: (_elementsOpacity < 0.8 ? true : false),
              child: Opacity(
                opacity: _elementsOpacity,
                child: SlidingUpPanel(
                  controller: _panelQueueCtrl,
                  isDraggable: value,
                  minHeight: _botbar_height-10,
                  maxHeight: _screen_height,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
                  panelBuilder: (ScrollController scrollCtrl) {

                    List<DragAndDropList> allList;

                    return GestureDetector(
                      onTap: () => _panelQueueCtrl.panelPosition < 0.3 ? _panelQueueCtrl.open() : null,
                      onVerticalDragStart: (vertDragStart) {
                        _isPanelQueueDraggable.value = true;
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: Container(
                          decoration: new BoxDecoration(
                            borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(15.0),
                              topRight: const Radius.circular(15.0),
                            ),
                            color: _main_image_color,
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.all(10),
                                width: 30,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.all(Radius.circular(12.0))
                                ),
                              ),
                              Container(
                                height: _screen_height-30,
                                child: DefaultTabController(
                                  length: 2,
                                  child: Scaffold(
                                    backgroundColor: _main_image_color,
                                    appBar: AppBar(
                                      backgroundColor: _main_image_color,
                                      toolbarHeight: 50,
                                      bottom: TabBar(
                                        tabs: [
                                          Tab(text: AppLocalizations.of(context).globalAppTracksQueue),
                                          Tab(text: AppLocalizations.of(context).globalAppTrackLyrics),
                                        ],
                                      ),
                                    ),
                                    body: GestureDetector(
                                      onVerticalDragStart: (vertDragStart) {
                                        _isPanelQueueDraggable.value = true;
                                      },
                                      child: TabBarView(
                                        children: [

                                            DragAndDropLists(
                                              onItemDraggingChanged: (DragAndDropItem details, bool isChanging) {
                                                if(isChanging == null || isChanging) _isPanelQueueDraggable.value = false;
                                                else _isPanelQueueDraggable.value = true;
                                              },
                                              onItemReorder: (int i1, int l1, int i2, int l2) { },
                                              itemOnAccept: (DragAndDropItem i1, DragAndDropItem i2) {
                                                /*print("------------");
                                                print(i1.child.key);
                                                print(i2.child.key);*/
                                                if(i1 != null && i2 != null) {
                                                  int oldItemIndex = int.parse(i1.child.key.toString().split(':')[2]);
                                                  int newItemIndex = int.parse(i2.child.key.toString().split(':')[2]);
                                                  if(allList.length == 1) {
                                                    GlobalQueue().reorder(oldItemIndex, 1, newItemIndex, 1);
                                                  } else {
                                                    String oldList = i1.child.key.toString().split(':')[1];
                                                    String newList = i2.child.key.toString().split(':')[1];
                                                    switch(oldList) {
                                                      case 'PermanentQueue': {
                                                        switch(newList) {
                                                          case 'PermanentQueue': GlobalQueue().reorder(oldItemIndex, 0, newItemIndex, 0); break;
                                                          case 'NoPermanentQueue': GlobalQueue().reorder(oldItemIndex, 0, newItemIndex, 1); break;
                                                        }
                                                      } break;
                                                      case 'NoPermanentQueue': {
                                                        switch(newList) {
                                                          case 'PermanentQueue': GlobalQueue().reorder(oldItemIndex, 1, newItemIndex, 0); break;
                                                          case 'NoPermanentQueue': GlobalQueue().reorder(oldItemIndex, 1, newItemIndex, 1); break;
                                                        }
                                                      } break;
                                                    }
                                                  }
                                                }
                                              },
                                              scrollController: scrollCtrl,
                                              children: () {

                                                int permaLength = GlobalQueue.permanentQueue.value.length;
                                                int noPermaLength = (GlobalQueue.noPermanentQueue.value.length-(GlobalQueue.currentQueueIndex+1) > -1 ?
                                                    GlobalQueue.noPermanentQueue.value.length-(GlobalQueue.currentQueueIndex+1) : 0);

                                                if(!_panelQueueCtrl.isPanelOpen) {
                                                  permaLength = permaLength > 10 ? 10 : permaLength;
                                                  noPermaLength = noPermaLength > 10 ? 10 : noPermaLength;
                                                } else {
                                                  permaLength = GlobalQueue.permanentQueue.value.length;
                                                  noPermaLength = (GlobalQueue.noPermanentQueue.value.length-(GlobalQueue.currentQueueIndex+1) > -1 ?
                                                    GlobalQueue.noPermanentQueue.value.length-(GlobalQueue.currentQueueIndex+1) : 0);
                                                }

                                                
                                                List<DragAndDropItem> permanentItems = 
                                                List.generate(
                                                    permaLength,
                                                    (index) {

                                                      return DragAndDropItem(
                                                        child: ValueListenableBuilder(
                                                          valueListenable: GlobalQueue.permanentQueue,
                                                          key: ValueKey('ReorderableListView:PermanentQueue:$index:'),
                                                          builder: (BuildContext context, List<Track> value, Widget child) {
                                                      
                                                            List<Track> queue = List<Track>();
                                                            
                                                            for(Track tr in GlobalQueue.permanentQueue.value) {
                                                              queue.add(tr);
                                                            }

                                                            return Container(
                                                              margin: EdgeInsets.only(left: 20, right: 20),
                                                              
                                                              child:  Card(
                                                                color: _main_image_color,
                                                                child: Row(
                                                                  children: [
                                                                    Flexible(
                                                                      flex: 5,
                                                                      child: ListTile(
                                                                        title: Text(queue.elementAt(index).name),
                                                                        leading: FractionallySizedBox(
                                                                          heightFactor: 0.8,
                                                                          child: AspectRatio(
                                                                            aspectRatio: 1,
                                                                            child: new Container(
                                                                              decoration: new BoxDecoration(
                                                                                image: new DecorationImage(
                                                                                  fit: BoxFit.fitHeight,
                                                                                  alignment: FractionalOffset.center,
                                                                                  image: NetworkImage(queue.elementAt(index).imageUrlLittle),
                                                                                )
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ),
                                                                        subtitle: Text(queue.elementAt(index).artist),
                                                                      )
                                                                    ),
                                                                    Flexible(
                                                                      flex: 1,
                                                                      child: Container (
                                                                        margin: EdgeInsets.only(left:20, right: 20),
                                                                        child: Icon(Icons.drag_handle)
                                                                      )
                                                                    )
                                                                  ]
                                                                )
                                                              )
                                                            );
                                                          }
                                                        )
                                                      );
                                                    },
                                                  );


                                                List<DragAndDropItem> noPermanentItems = 
                                                List.generate(
                                                    noPermaLength,
                                                    (index) {

                                                      return DragAndDropItem(
                                                        child: ValueListenableBuilder(
                                                          valueListenable: GlobalQueue.noPermanentQueue,
                                                          key: ValueKey('ReorderableListView:NoPermanentQueue:$index:'),
                                                          builder: (BuildContext context, List<Track> value, Widget child) {
                                                      
                                                            List<Track> queue = List<Track>();
                                                            
                                                            for(int i=0; i<GlobalQueue.noPermanentQueue.value.length; i++) {
                                                              if(i>GlobalQueue.currentQueueIndex) {
                                                                queue.add(GlobalQueue.noPermanentQueue.value[i]);
                                                              }
                                                            }

                                                            return Container(
                                                              margin: EdgeInsets.only(left: 20, right: 20),
                                                              
                                                              child: Card(
                                                                color: _main_image_color,
                                                                child: Row(
                                                                  children: [
                                                                    Flexible(
                                                                      flex: 5,
                                                                      child: ListTile(
                                                                        title: Text(queue.elementAt(index).name),
                                                                        leading: FractionallySizedBox(
                                                                          heightFactor: 0.8,
                                                                          child: AspectRatio(
                                                                            aspectRatio: 1,
                                                                            child: new Container(
                                                                              decoration: new BoxDecoration(
                                                                                image: new DecorationImage(
                                                                                  fit: BoxFit.fitHeight,
                                                                                  alignment: FractionalOffset.center,
                                                                                  image: NetworkImage(queue.elementAt(index).imageUrlLittle),
                                                                                )
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ),
                                                                        subtitle: Text(queue.elementAt(index).artist),
                                                                      )
                                                                    ),
                                                                    Flexible(
                                                                      flex: 1,
                                                                      child: Container (
                                                                          margin: EdgeInsets.only(left:20, right: 20),
                                                                          child: Icon(Icons.drag_handle)
                                                                        )
                                                                      )
                                                                    ]
                                                                  )
                                                                )
                                                              );
                                                          }
                                                        )
                                                      );
                                                    },
                                                  );

                                              
                                                  DragAndDropList permanentList = DragAndDropList(
                                                    canDrag: false,
                                                    header: Container(
                                                      margin: EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
                                                      child: Text(
                                                        AppLocalizations.of(context).globalAppTracksNextInQueue,
                                                        textAlign: TextAlign.left,
                                                        style: TextStyle(
                                                          fontSize: 20
                                                        )
                                                      )
                                                    ),
                                                    children: permanentItems
                                                  );

                                                  DragAndDropList noPermanentList = DragAndDropList(
                                                    canDrag: false,
                                                    header: Container(
                                                      margin: EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
                                                      child: Text(
                                                        AppLocalizations.of(context).globalAppPlaylistNextFrom + FrontPlayerController().currentPlaylist.name,
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 20
                                                        )
                                                      )
                                                    ),
                                                    children: noPermanentItems
                                                  );

                                                  if(GlobalQueue.permanentQueue.value.isEmpty)
                                                    allList = [noPermanentList];
                                                  else
                                                    allList = [permanentList, noPermanentList];

                                                  return allList;

                                              }.call(),
                                            ),


                                          Text(AppLocalizations.of(context).globalWIP),
                                        ],
                                      ),
                                    )
                                  )
                                )
                              )
                            ],
                          )
                        )
                      )
                    );
                  }
                )
              )
            );
          }
        )
      ]
    );
  }

}