import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_file/open_file.dart';
import 'package:tubemaster/core/model/download_data.dart';
import 'package:tubemaster/utils/Translations.dart';
import 'package:tubemaster/utils/Utils.dart';
import 'package:tubemaster/utils/styles.dart';

class ItemDownloadComplete extends StatelessWidget {
  final TaskDownloader downloader;
  final Function onTapTouch;
  final Function onTapLong;
  final Function onPlayer;
  final Function onShared;
  final Function onDelete;
  List<String> opTask;

  List<PopupMenuItem<String>> menusPopup;

  void initOpts() {
    opTask = [
      Translations.current.text('play'),
//      Translations.current.text('shared'),
      Translations.current.text('delete'),

//      Translations.current.text('open_dir_file'),
    ];
    menusPopup = opTask
        .map((String value) => PopupMenuItem<String>(
              child: Styles.titleWidget(value, overflow: false),
              value: value,
            ))
        .toList();
  }

  _buildShowMores() {
    return PopupMenuButton<String>(
      padding: EdgeInsets.only(left: 8.0),
//      icon: Icon(Icons.more_horiz,color: Colors.white,),
      child: Container(
        padding: EdgeInsets.all(6.0),
        child: Center(
          child: SvgPicture.asset('assets/icons/more.svg',
              height: 40, width: 40, color: Colors.white),
        ),
      ),
//      child: Styles.titleWidget(Translations.current.text('more_options')),
      itemBuilder: (BuildContext context) => menusPopup,
      onSelected: (String value) {
        if (value == opTask[0]) {
          if (onPlayer == null) return;
          onPlayer(downloader);
        }else if (value == opTask[1]) {
          if (onDelete == null) return;
          onDelete(downloader);
        }
      },
    );
  }

  ItemDownloadComplete(this.downloader,
      {this.onTapTouch, this.onPlayer, this.onDelete, this.onShared,this.onTapLong});

  Widget _buildStateDownload() {
    if (downloader.status == DownloadTaskStatus.complete) {
      return FlatButton(
          onPressed: null,
          child: Styles.titleWidget('Open', color: Colors.white));
    }
    if (downloader.status == DownloadTaskStatus.running) {
      return SvgPicture.asset('assets/icons/pause.svg',
          height: 40, width: 40, color: Styles.titleColor);
    }

    if (downloader.status == DownloadTaskStatus.undefined ||
        downloader.status == DownloadTaskStatus.paused) {
      return SvgPicture.asset('assets/icons/arrow.svg',
          height: 40, width: 40, color: Styles.titleColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    initOpts();
    return GestureDetector(
      onTap: onTapTouch,
      onLongPress: onTapLong,
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            color: Styles.placeholderColor,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        margin: EdgeInsets.all(8.0),
        child: ListTile(
          isThreeLine: false,
          leading: Container(
              padding: EdgeInsets.all(6.0),
              height: 45.0,
              width: 45.0,
              child: Center(
                child: _buildShowMores(),
              ),
//              IconButton(
//                  icon: Center(
//                    child: SvgPicture.asset('assets/icons/more.svg',
//                        height: 40, width: 40, color: Colors.white),
//                  ),
//                  onPressed: () {
//                    if(onPlayer == null) return;
//                    onPlayer(downloader);
//                  }),
              decoration: BoxDecoration(
                  color: Colors.green[600],
                  borderRadius: BorderRadius.all(Radius.circular(4.0)))),
          title: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Styles.titleWidget(downloader.title,
                          fontWeight: FontWeight.normal,
                          color: Styles.titleColor,
                          maxLines: 2),
                    ],
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.only(left: 4.0),
                  width: 50,
                  height: 50,
                  child: downloader.cover != null
                      ? CachedNetworkImage(
                          imageUrl: downloader.cover,
                          imageBuilder: (context, imageProvider) => Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                      colorFilter: ColorFilter.mode(
                                          Colors.grey[400],
                                          BlendMode.colorBurn)),
                                ),
                              ),
                          placeholder: (context, url) => Align(
                              alignment: Alignment.center,
                              child: Utils.progress()),
                          errorWidget: (context, url, error) =>
                              Styles.buildErrorImage())
                      : Styles.buildErrorImage())
            ],
          ),
//        trailing: Container(
//          height: 50.0,
//            width: 50.0,
//            child: Center(
//              child:  Styles.titleWidget('Play',color: Colors.white,fontWeight: FontWeight.bold,textSize: Styles.textSize16,maxLines: 1),
//            ),
//            padding: EdgeInsets.all(10.0),
//            decoration: BoxDecoration(
//                color: Styles.iconColor,
//                borderRadius: BorderRadius.all(Radius.circular(10)))),
        ),
      ),
    );
  }
}

class ItemDownload extends StatelessWidget {
  final TaskDownloader downloader;
  Function _onTapDownload;
  Function _onTapPause;
  Function _onTapResume;
  Function _onTapStop;
  Function _onTap;

  ItemDownload(this.downloader, {Function onTapDownload, Function onTap}) {
    this._onTap = onTap;
    this._onTapDownload = onTapDownload;
  }
  Widget _buildStateDownload(TaskDownloader downloader) {
    if (downloader.status == DownloadTaskStatus.complete) {
      return FlatButton(
          onPressed: null,
          child: Styles.titleWidget('Open', color: Colors.white));
    }

    if (downloader.status == DownloadTaskStatus.running) {
      return Container(
        padding: EdgeInsets.all(8.0),
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Styles.progressColor,
        ),
        child: Center(
          child: SvgPicture.asset('assets/icons/pause.svg',
              height: 40, width: 40, color: Styles.titleColor),
        ),
      );
    }

    if (downloader.status == DownloadTaskStatus.undefined) {
      return Container(
        padding: EdgeInsets.all(8.0),
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Styles.backgroundColor,
        ),
        child: Center(
          child: SvgPicture.asset('assets/icons/download.svg',
              height: 40, width: 40, color: Styles.titleColor),
        ),
      );
    }

    if (downloader.status == DownloadTaskStatus.failed) {
      return Container(
        padding: EdgeInsets.all(8.0),
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red[600],
        ),
        child: Center(
          child: SvgPicture.asset('assets/icons/rotate.svg',
              height: 32, width: 32, color: Styles.titleColor),
        ),
      );
    }

    if (downloader.status == DownloadTaskStatus.paused) {
      return Container(
        padding: EdgeInsets.all(8.0),
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Styles.backgroundColor,
        ),
        child: Center(
          child: SvgPicture.asset('assets/icons/play.svg',
              height: 40, width: 40, color: Styles.titleColor),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onLongPress: (){
        _onTap(downloader);
      },
      child: Container(
        child: Stack(children: <Widget>[
          Container(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      print('Download...');
                      if(_onTapDownload == null) return;
                      _onTapDownload(downloader);
                    },
                    iconSize: 45,
                    icon: _buildStateDownload(downloader),
                  ),
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Styles.titleWidget(downloader.title,
                              fontWeight: FontWeight.bold,
                              color: Styles.titleColor,
                              maxLines: 2),
                          SizedBox(
                            height: 4,
                          ),
                          Row(
                            children: <Widget>[
                              downloader.status ==
                                  DownloadTaskStatus.failed
                                  ? Container()
                                  : Styles.titleWidget(
                                  Utils.formatBytes(
                                      downloader.size, 2),
                                  fontWeight: FontWeight.bold,
                                  textSize: Styles.textSize13,
                                  color: Styles.iconColor,
                                  maxLines: 1),
                              (downloader.status ==
                                  DownloadTaskStatus.failed)
                                  ? Styles.titleWidget(
                                  'failed_download',
                                  reference: true,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  textSize: Styles.textSize13,
                                  maxLines: 1)
                                  : Styles.titleWidget(
                                  ' - ${Utils.format(downloader.format())}',
                                  fontWeight: FontWeight.bold,
                                  color: Styles.iconColor,
                                  textSize: Styles.textSize13,
                                  maxLines: 1)
                            ],
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          downloader.status ==
                              DownloadTaskStatus.running ||
                              downloader.status ==
                                  DownloadTaskStatus.paused
                              ? Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10))),
                            height: 2,
                            child: new LinearProgressIndicator(
                              backgroundColor: Colors.grey[300],
                              valueColor:
                              AlwaysStoppedAnimation<Color>(
                                  Styles.progressColor),
                              value: downloader.progress / 100,
                            ),
                          )
                              : Container()
                        ],
                      ),
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 4.0),
                      width: 80,
                      height: 80,
                      child: downloader.cover != null
                          ? CachedNetworkImage(
                          imageUrl: downloader.cover,
                          imageBuilder: (context,
                              imageProvider) =>
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(4.0),
                                  image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                      colorFilter:
                                      ColorFilter.mode(
                                          Colors.grey[400],
                                          BlendMode
                                              .colorBurn)),
                                ),
                              ),
                          placeholder: (context, url) => Align(
                              alignment: Alignment.center,
                              child: Utils.progress()),
                          errorWidget: (context, url, error) =>
                              Styles.buildErrorImage())
                          : Styles.buildErrorImage())
                ],
              )),
        ]),
        decoration: BoxDecoration(
            color: Styles.placeholderColor,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        margin: EdgeInsets.all(8.0),
      ),
    );
  }
}
