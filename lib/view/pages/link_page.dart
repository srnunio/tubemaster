
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tubemaster/core/bloc/home_bloc.dart';
import 'package:tubemaster/core/bloc/link_video_bloc.dart';
import 'package:tubemaster/core/data/preferences.dart';
import 'package:tubemaster/core/model/data.dart';
import 'package:tubemaster/core/model/download_data.dart';
import 'package:tubemaster/utils/Translations.dart';
import 'package:tubemaster/view/widget/audio.dart';
import 'package:tubemaster/view/widget/video.dart';
import '../../core/bloc/object_event.dart';
import '../../core/bloc/object_state.dart';
import '../../utils/Utils.dart';
import '../../utils/styles.dart';
import 'download_list_page.dart';

class ProcessLinkPage extends StatelessWidget {
  static HomeBloc homeBloc;
  final String link;

  ProcessLinkPage(this.link);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LinkVideoBloc>(
        builder: (context) => LinkVideoBloc(),
        child:
            BlocBuilder<LinkVideoBloc, ObjectState>(builder: (context, objectState) {
          return ProcessLinkView(link);
        }));
  }
}

class ProcessLinkView extends StatefulWidget {
  final String link;

  ProcessLinkView(this.link);

  @override
  _ProcessLinkView createState() => _ProcessLinkView(link);
}

class _ProcessLinkView extends State<ProcessLinkView> {
  LinkVideoBloc _bloc;
  final String link;
  static const videoFormats = ['mp4', 'mkv'];

  Audio _audio;

  int sizeDownoload = 0;
  bool _audioSelect = true;
  bool _videoSelect = false;

  _ProcessLinkView(this.link);

  List<Video> list = [
    Video(url: 'uyreuiryieu', size: 100000, quality: EViedoQuality.High1080),
    Video(url: '454444', size: 1200000, quality: EViedoQuality.Medium480),
    Video(url: 'cvsfgf', size: 800000, quality: EViedoQuality.High2880),
    Video(url: 'rwrtwrt4', size: 13400000, quality: EViedoQuality.Medium480),
    Video(url: '44444', size: 2300000, quality: EViedoQuality.Low240),
  ];

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<LinkVideoBloc>(context);
    _bloc.onSetLink(link);
  }

  @override
  Widget build(BuildContext context) {
    var video = VideoDetailState(videos: list);
    return BlocProvider<LinkVideoBloc>(
        builder: (context) => _bloc,
        child: BlocBuilder<LinkVideoBloc, ObjectState>(builder: (context, state) {
          return SafeArea(child: _build(state));

//          return SafeArea(
//              child: Scaffold(
//            body: VideoSection(list[0], list, onSelectQuality: (value) {
//              var r = (value as Video);
//              Utils.logs('onSelectQuality : ${r.quality}');
//            }, onSelectFormat: (value) {
//              var r = (value as Video);
//              Utils.logs('onSelectFormat : ${r.format}');
//            }),
//          ));
        }));
  }

  _build(ObjectState state) {
    print('_build state ${state}');
    if (state is ObjectError) {
      return Scaffold(
        backgroundColor: Styles.backgroundColor,
        body: Center(
          child: _buildNoResults(),
        ),
      );
    }
    if (state is VideoDetailState) {
      var linkState = (state as VideoDetailState);
      if (linkState.downloader == null) {
        return Scaffold(
          body: _buildNoResults(),
        );
      }
      return _bulidData(linkState);
    }
    return Scaffold(
      backgroundColor: Styles.backgroundColor,
      body: Utils.progress(),
    );
  }

  _size(VideoDetailState state) {
    if ((state.isAudio() && state.isVideo()) &&
        (_audioSelect && _videoSelect)) {
      return state.audio.size + state.currentVideo.size;
    }

    if ((state.isAudio() && _audioSelect)) {
      return state.audio.size;
    }

    if ((state.isVideo() && _videoSelect)) {
      return state.currentVideo.size;
    }
    return 0;
  }

  _bulidData(VideoDetailState videoDetailState) {
    return Scaffold(
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Styles.backgroundColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          margin: EdgeInsets.all(16.0),
          child: FlatButton(
              padding: EdgeInsets.all(0),
              onPressed: ((_videoSelect) || _audioSelect)
                  ? () async {
               await  _submit(videoDetailState);
                    }
                  : null,
              child: Container(
                height: 50.0,
                decoration: BoxDecoration(
                  color: (_videoSelect || _audioSelect)
                      ? (!videoDetailState.isValidDownloadVideo() &&
                              _videoSelect)
                          ? Styles.placeholderColor
                          : Styles.progressColor
                      : Styles.placeholderColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Styles.titleWidget(
                      '${Translations.current.text('download')} (${Utils.formatBytes(_size(videoDetailState), 2)})',
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              )),
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              elevation: 0.0,
              floating: true,
              expandedHeight: 180,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Container(
                  height: 180,
                  color: Styles.placeholderColor,
                  child: videoDetailState.downloader.cover == null
                      ? Styles.buildErrorImage()
                      : CachedNetworkImage(
                          height: 180,
                          imageUrl: videoDetailState.downloader.cover,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          placeholder: (context, url) => Align(
                            alignment: Alignment.center,
                            child: Utils.progress(),
                          ),
                          errorWidget: (context, url, error) =>
                              Styles.buildErrorImage(),
                        ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Styles.titleWidget(videoDetailState.downloader.title,
                        fontWeight: FontWeight.bold,
                        color: Styles.iconColor,
                        overflow: false),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Styles.titleWidget(
                          videoDetailState.downloader.description,
                          color: Styles.titleColor,
                          overflow: false),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Styles.line(),
                    SizedBox(
                      height: 20,
                    ),
                    videoDetailState.isAudio()
                        ? AudioSection(
                            videoDetailState.audio,
                            value: _audioSelect,
                            onActive: (value) {
                              print('Select audio ${value}');
                              setState(() {
                                _audioSelect = value;
                              });
                            },
                          )
                        : Container(),
                    SizedBox(
                      height: 20,
                    ),
                    Styles.line(),
                    SizedBox(
                      height: 20,
                    ),
                    videoDetailState.isVideo()
                        ? VideoSection(
                            videoDetailState.currentVideo,
                            videoDetailState.videos,
                            value: _videoSelect,
                            isValidDownload:
                                videoDetailState.isValidDownloadVideo(),
                            onSelectQuality: (value) {
                              var video = (value as Video);
                              setState(() {
                                videoDetailState.onSetCurrentVideo(video);
//                              _bloc.dispatch(RefreshVideo(video));
                              });
                            },
                            onSelectFormat: (value) {
                              var format = (value as Format);
                              setState(() {
                                var video = videoDetailState.currentVideo;
                                video.format = format;
                                videoDetailState.onSetCurrentVideo(video);
                              });
                            },
                            onActive: (value) {
                              setState(() {
                                _videoSelect = value;
                              });
                              print('Active Video ${value}');
                            },
                          )
                        : Container()
                  ],
                ),
              ),
            )
          ],
        ));
  }



  Widget _buildNoResults() {
    return Center(
      child: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Styles.titleWidget('no_results',
                  reference: true, color: Colors.white),
            ),
            Center(
              child: Styles.titleWidget('non',
                  textSize: Styles.textSize13,
                  reference: true,
                  color: Colors.white),
            ),
            Container(
              width: 200,
              height: 40,
              decoration: BoxDecoration(
                color: Styles.progressColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              margin: EdgeInsets.all(16.0),
              child: FlatButton(
                  padding: EdgeInsets.all(0),
                  onPressed: () async {
                    _bloc.dispatch(FetchEvent(link));
                  },
                  child: Container(
                    height: 50.0,
                    decoration: BoxDecoration(
                      color: Styles.progressColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: Styles.titleWidget('try_again',
                          reference: true,
                          overflow: false,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  _submit(VideoDetailState state) {
    if (!state.isValidDownloadVideo() && _videoSelect) {
      Utils.messageToas(
          message: Translations.current
              .text('waring_download_video')
              .replaceAll('#', Utils.formatBytes(state.currentVideo.size, 2)));
      return;
    }
    if (bloc != null) {
      if (state.isAudio() && _audioSelect) {
        var downloader = TaskDownloader(id: -1,taskId: '',progress: 0);
        downloader.size = state.audio.size;
        downloader.taskId = state.downloader.idVideo;

        downloader.formatFile = state.audio.format.index;
        downloader.linkDownload = state.audio.url;
        downloader.title =  Utils.text(state.downloader.title);
        downloader.description = state.downloader.description;
        downloader.cover = state.downloader.cover;
        downloader.date = state.downloader.date;
        downloader.stateFile = state.downloader.stateFile;
        downloader.idVideo = state.downloader.idVideo;
        downloader.dir_url =
            '${Tools.onDir()}/${downloader.title}.${Utils.format(state.audio.format)}';
        bloc.onSetTask(downloader);
      }

      if (state.isVideo() && _videoSelect) {
        var downloader = TaskDownloader(id: -1,taskId: '',progress: 0);
        downloader.size = state.currentVideo.size;
        downloader.taskId = '${state.downloader.idVideo}${EFile.video}';
        downloader.formatFile = state.currentVideo.format.index;
        downloader.linkDownload = state.currentVideo.url;
        downloader.title = Utils.text(state.downloader.title);
        downloader.description = state.downloader.description;
        downloader.cover = state.downloader.cover;
        downloader.date = state.downloader.date;
        downloader.stateFile = state.downloader.stateFile;
        downloader.idVideo = state.downloader.idVideo;
        downloader.dir_url =
            '${Tools.onDir()}/${downloader.title}.${Utils.format(state.currentVideo.format)}';
        bloc.onSetTask(downloader);
      }
//      bloc.dispatch(RefreshEvent());
      Navigator.pop(context);
    }
  }
}
