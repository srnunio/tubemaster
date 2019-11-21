import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_svg/svg.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:tubemaster/core/bloc/home_bloc.dart';
import 'package:tubemaster/core/data/data_base.dart';
import 'package:tubemaster/core/data/preferences.dart';
import 'package:tubemaster/core/model/data.dart';
import 'package:tubemaster/core/model/download_data.dart';
import 'package:tubemaster/utils/Translations.dart';
import 'package:tubemaster/view/widget/item_download.dart';

import '../../core/bloc/history_bloc.dart';
import '../../core/bloc/object_event.dart';
import '../../core/bloc/object_state.dart';
import '../../utils/Utils.dart';
import '../../utils/styles.dart';

DownloadBloc bloc;

class DownlaodListPage extends StatelessWidget {
  static HomeBloc homeBloc;

  @override
  Widget build(BuildContext context) {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    return BlocProvider<DownloadBloc>(
        builder: (context) => DownloadBloc(),
        child: BlocBuilder<DownloadBloc, ObjectState>(
            builder: (context, objectState) {
          return DownlaodListView();
        }));
  }
}

class DownlaodListView extends StatefulWidget {
  @override
  _DownlaodListView createState() => _DownlaodListView();
}

class _DownlaodListView extends State<DownlaodListView> {
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<DownloadBloc>(context);
    _bindBackgroundIsolate();
    bloc.initDownload();
    DownlaodListPage.homeBloc.checkPermission(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DownloadBloc>(
        builder: (context) => bloc,
        child:
            BlocBuilder<DownloadBloc, ObjectState>(builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              title: Styles.titleWidget('TubeMaster',
                  fontWeight: FontWeight.bold, textSize: 25, maxLines: 1),
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Styles.progressColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              margin: EdgeInsets.all(16.0),
              child: FlatButton(
                  padding: EdgeInsets.all(0),
                  onPressed: () async {
                    _startLinked();
                  },
                  child: Container(
                    height: 50.0,
                    decoration: BoxDecoration(
                      color: Styles.progressColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: Styles.titleWidget('paste_link',
                          reference: true,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  )),
            ),
            body: _build(state),
          );
        }));
  }

  _build(ObjectState state) {
    if (state is ObjectError) {
      return Center(
        child: Styles.titleWidget('no_history',
            reference: true, color: Colors.white),
      );
    }
    if (state is ObjectLoaded) {
      if (state.objects.isEmpty) {
        return Center(
          child: Styles.titleWidget('no_history',
              reference: true, color: Colors.white),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          TaskDownloader downloader = state.objects[index];
          return downloader.status == DownloadTaskStatus.complete
              ? ItemDownloadComplete(downloader, onTapLong: () async {
                  await bloc.deleteItemDialog(index, context);
                }, onPlayer: (value) async {
                  _open(downloader);
                  Utils.logs('onPlayer ${downloader.title}');
                }, onDelete: (value) async {
                  Utils.logs('onDelete ${downloader.title}');
                  _delete(index);
                }, onShared: (value) async {
                  Utils.logs('onShared ${downloader.title}');
                  _shared(downloader);
                }, onTapTouch: () async {
                  _open(downloader);
                })
              : ItemDownload(
                  downloader,
                  onTapDownload: (value) async {
                    await _function(value, index);
                  },
                  onTap: (value) async {
                    Utils.logs('onTap');
                    await bloc.deleteItemDialog(index, context);
                  },
                );
        },
        itemCount: state.objects.length,
      );
    }
    return Utils.progress();
  }

  _startLinked() async {
    if (!await DownlaodListPage.homeBloc.checkPermission(context)) return;
    await bloc.netWork();
    var result = await bloc.validLink();

    if (!Utils.validPlayListYoutube(result)) {
      Styles.alertErrorLink(
          context, Translations.current.text('invalid_link_video_list'));
    } else if (!Utils.validLinkYoutube(result)) {
      Styles.alertErrorLink(
          context,
          Translations.current
              .text('invalid_link_video')
              .replaceAll('#', '\n\n\n\n${result}'));
    } else {
      Navigator.pushNamed(context, '/processLink', arguments: result);
    }
  }

  _delete(int index) async {
    await bloc.deleteItemDialog(index, context);
  }

  _shared(TaskDownloader downloader) async {
    Utils.logs('_shared ${downloader.dir_url}');
    String val = await OpenFile.open(downloader.dir_url, type: 'share');
    Utils.logs('_shared ${val}');
//    await Share.share(downloader.title,
//        subject: Uri.parse(downloader.dir_url).toString());

//      const MethodChannel _channel = const MethodChannel('tube_download_master');
//
//      Map<String, String> map = {"file_path": downloader.dir_url, "type": '${Utils.format(downloader.format())}',"uti":''};
//      return await _channel.invokeMethod('open', map);
  }

  _open(TaskDownloader downloader) async {
    String val;
    if (Utils.fileFormat(downloader.format()) == EFile.audio) {
      val = await OpenFile.open(downloader.dir_url, type: 'audio');
    } else {
      val = await OpenFile.open(downloader.dir_url, type: 'video');
    }
    Utils.logs('OpenFile ${val}');
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      bloc.unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) async {
      print('UI Isolate Callback: $data');
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      final task = (((bloc.currentState as ObjectLoaded).objects)
              as List<TaskDownloader>)
          .firstWhere((task) => task.taskId == id);

      print('UI task.status : ${task.status}');
      if (task != null) {
        setState(() {
          task.stateFile = status.value;
          task.progress = progress;
        });

        Utils.logs('DataBaseUtils.insertOrUpadateDb(task,column: DownloaderColmn.progress)');
        await DataBaseUtils.insertOrUpadateDb(task,
            column: DownloaderColmn.progress);
        Utils.logs('DataBaseUtils.insertOrUpadateDb(task,column: DownloaderColmn.stateFile)');
        await DataBaseUtils.insertOrUpadateDb(task,
            column: DownloaderColmn.stateFile);
      }
    });
  }

  _function(TaskDownloader downloader, int index) async {
    print('_function Download...');
    if (!await DownlaodListPage.homeBloc.checkPermission(context)) {
      return;
    }
    if (downloader.status == DownloadTaskStatus.complete) {
    } else if (downloader.status == DownloadTaskStatus.running) {
      await bloc.pauseDownload(downloader);
    } else if (downloader.status == DownloadTaskStatus.paused) {
      await bloc.resumeDownload(downloader,index);
    } else if (downloader.status == DownloadTaskStatus.failed) {
      await bloc.prepare(downloader);
      await bloc.requestDownload(downloader, index);
    } else if (downloader.status == DownloadTaskStatus.canceled) {
      await bloc.prepare(downloader);
      await bloc.requestDownload(downloader, index);
    } else if (downloader.status == DownloadTaskStatus.undefined) {
      await bloc.prepare(downloader);
      await bloc.requestDownload(downloader, index);
    }
  }

  @override
  void dispose() {
    bloc.unbindBackgroundIsolate();
    super.dispose();
  }
}
