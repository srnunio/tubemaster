import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';
import 'package:tubemaster/core/data/data_base.dart';
import 'package:tubemaster/core/data/preferences.dart';
import 'package:tubemaster/utils/Translations.dart';
import 'package:tubemaster/utils/Utils.dart';
import 'package:tubemaster/utils/constants.dart';
import 'package:tubemaster/utils/styles.dart';
import 'package:tubemaster/view/pages/download_list_page.dart';

import '../model/download_data.dart';
import 'object_event.dart';
import 'object_state.dart';

class DownloadBloc extends Bloc<ObjectEvent, ObjectState> {
  initDownload() {
    FlutterDownloader.registerCallback(downloadCallback);
  }

  Future<String> validLink() async {
    var link = await Clipboard.getData(Clipboard.kTextPlain);
    print('Get link ${link.text}');
    return link.text;
  }

  void unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static Future downloadCallback(
      String id, DownloadTaskStatus status, int progress) async {
    print(
        'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
//    var task = await DataBaseUtils.getTask(id);
//    if(task == null){
//      Utils.logs('downloadCallback Get Task nullo ');
//    }else {
//      task.progress =  progress;
//      task.stateFile =  status.value;
//      Utils.logs('downloadCallback -- Update ${await DataBaseUtils.insertOrUpadateDb(task,column: DownloaderColmn.stateFile)}');
//      Utils.logs('downloadCallback -- Update ${await DataBaseUtils.insertOrUpadateDb(task,column: DownloaderColmn.progress)}');
//    }
  }

  void requestDownload(TaskDownloader task, int index) async {
    if (!(currentState is ObjectLoaded)) return;
    await netWork();
    var tasks = (currentState as ObjectLoaded).objects as List<TaskDownloader>;
    Utils.logs('Tools.onDir() ${Tools.onDir()}');
    task.taskId = await FlutterDownloader.enqueue(
        url: task.linkDownload,
        fileName: '${task.title}.${Utils.format(task.format())}',
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: Tools.onDir(),
        showNotification: true,
        requiresStorageNotLow: false,
        openFileFromNotification: true);
//
    tasks[index].taskId = task.taskId;
    await DataBaseUtils.insertOrUpadateDb(task, column: DownloaderColmn.taskId);
  }

  void cancelDownload(TaskDownloader task) async {
    await FlutterDownloader.cancel(taskId: task.taskId);
  }

  void retryDownload(TaskDownloader task, int index) async {
    await netWork();
    String newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
    task.taskId = newTaskId;
//    tasks[index].taskId = newTaskId;
//    DataBaseUtils.insertOrUpadateDb(task, column: DownloaderColmn.taskId);
  }

  void pauseDownload(TaskDownloader task) async {
    await FlutterDownloader.pause(taskId: task.taskId);
  }

  void resumeDownload(TaskDownloader task, int index) async {
    await netWork();
    var list = await FlutterDownloader.loadTasks();
    bool isValid = false;
    list?.forEach((t) async {
      if (t.taskId == task.taskId) {
        isValid = true;
      }
    });

    if (!isValid) {
      await prepare(task);
      await requestDownload(task, index);
      return;
    }
    String newTaskId = await FlutterDownloader.resume(taskId: task.taskId);
    task.taskId = newTaskId;
//    if ((currentState is ObjectLoaded)) {
//      ((currentState as ObjectLoaded).objects as List<TaskDownloader>)[index]
//          .taskId = newTaskId;
//    }
//    await DataBaseUtils.insertOrUpadateDb(task, column: DownloaderColmn.taskId);
  }

  Future netWork() async {
    if (!await Utils.isConection()) {
      Utils.messageToas(message: Translations.current.text('no_connection'));
      return;
    }
  }

  DownloadBloc() {
    dispatch(InitEvent());
  }

//  List<TaskDownloader> tasks = [];
//

  Future<TaskDownloader> prepare(TaskDownloader downloader) async {
    if (currentState is Uninitialized) return downloader;
    final tasks1 = await FlutterDownloader.loadTasks();
    tasks1?.forEach((task) async {
      for (TaskDownloader info
          in ((currentState as ObjectLoaded).objects as List<TaskDownloader>)) {
        if (info.taskId == task.taskId) {
          print(' ${info.taskId} == ${task.taskId}');
          info.taskId = task.taskId;
          info.stateFile = task.status.value;
          info.progress = task.progress;
          downloader.progress = task.progress;
          downloader.stateFile = task.status.value;
          downloader.taskId = task.taskId;
        } else {
          print(' ${info.taskId} != ${task.taskId}');
        }
      }
    });
    return downloader;
  }

  Future<List<TaskDownloader>> _reads() async {
//    DataBaseUtils.deleteTask(id: 1);
    List<TaskDownloader> _tasks = [];
    try {
      var filter = 'id desc';
      var query =
          'select * from ${Vars.DB_TASKS_TABLE_NAME} order by ${filter} ';
      List<Map> jsons = await DataBaseUtils.database.rawQuery(query);
      for (Map json in jsons) {
        var downloader = TaskDownloader();
        downloader.id = json['id'];
        downloader.taskId = json['taskId'];
        downloader.idVideo = json['idVideo'];
        downloader.title = json['title'];
        downloader.description = json['description'];
        downloader.linkDownload = json['linkDownload'];
        downloader.formatFile = json['formatFile'];
        downloader.cover = json['cover'];
        downloader.dir_url = json['dir_url'];
        downloader.date = json['date'];
        downloader.progress = json['progress'];
        downloader.size = json['size'];
        downloader.stateFile = json['stateFile'];
        _tasks.add(downloader);
//        _tasks.add(await prepare(downloader));
      }
    } catch (ex) {
      print('_reads:Exception => ${ex.toString()}');
    } finally {
//      await DataBaseUtils.database.close();
    }

    return _tasks;
  }

  @override
  get initialState => Uninitialized();

  onSetTask(TaskDownloader downloader) async {
//    var tasks = (currentState as ObjectLoaded).objects as List<TaskDownloader>;

//    if(((currentState as ObjectLoaded).objects as List<TaskDownloader>).length > 0) {
//      tasks.insert(0,downloader);
//    }else{
//      tasks.add(downloader);
//    }
    var rs = await DataBaseUtils.insertOrUpadateDb(downloader);
    Utils.logs('onSetTask => insertOrUpadateDb => : ${rs}');
    if (rs > 0) {
      downloader.id = rs;
      downloader = await prepare(downloader);
      dispatch(InsertNewEvent(downloader));
    }else{
      Utils.messageToas(message: Translations.current.text('try_again'));
    }
  }

  Future deleteItemDialog(int index, BuildContext context) async {
    var tasks = (currentState as ObjectLoaded).objects as List<TaskDownloader>;
    var downloader = tasks[index];

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext c) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(16.0),
              height: 300,
              decoration: BoxDecoration(
                  color: Styles.backgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: Styles.titleWidget(downloader.title,
                        overflow: false,
                        fontWeight: FontWeight.bold,
                        color: Styles.titleColor),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Center(
                      child: Styles.titleWidget('delete_file',
                          reference: true,
                          overflow: false,
                          fontWeight: FontWeight.bold,
                          color: Styles.titleColor)),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Styles.titleWidget('no',
                              reference: true,
                              overflow: false,
                              fontWeight: FontWeight.bold,
                              color: Styles.titleColor)),
                      FlatButton(
                          onPressed: () async {
                            var result = await DataBaseUtils.deleteTask(
                                id: downloader.id);
                            if (result > 0) {
                              tasks.removeAt(index);
                              await FlutterDownloader.remove(taskId: downloader.taskId);
                              if (tasks.length == 0) {
                                tasks.clear();
                              }
                              Utils.messageToas(
                                  message:
                                      Translations.current.text('deleted'));
                              dispatch(RefreshEvent());
                              DownlaodListPage.homeBloc.dispatch(InitSettings());
                              Navigator.pop(context);
                            } else {
                              Utils.messageToas(
                                  message: Translations.current
                                      .text('message_delete_error_anotation'));
                              return;
                            }
                          },
                          child: Styles.titleWidget('yes',
                              reference: true,
                              overflow: false,
                              fontWeight: FontWeight.bold,
                              color: Styles.titleColor)),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Stream<ObjectState> mapEventToState(ObjectEvent event) async* {
    try {
      if (currentState is Uninitialized) {
        var tasks = await _reads();
        yield ObjectLoaded(objects: tasks, hasReachedMax: true);
//        final tasks1 = await FlutterDownloader.loadTasks();
        return;
      }
      if (event is InsertNewEvent) {
        var obj = ((event as InsertNewEvent).object) as TaskDownloader;
        List<TaskDownloader> list = [];
        list.add(obj);
        yield ObjectLoaded(
            objects: (currentState as ObjectLoaded).objects + list,
            hasReachedMax: false);
      }
      if ((currentState as ObjectLoaded).objects.length == 0) {
        var tasks = await _reads();
        yield ObjectLoaded(objects: tasks, hasReachedMax: false);
        return;
      }
      if (event is RefreshEvent) {
        var tasks = await _reads();
        yield ObjectLoaded(objects: tasks, hasReachedMax: false);
        return;
      }
      if( (currentState as ObjectLoaded).objects.length > 0) {
        yield (currentState as ObjectLoaded).copyWith(hasReachedMax: true);
      }else {
        yield ObjectLoaded(
            objects: List<TaskDownloader>(), hasReachedMax: true);
      }
    } catch (ex) {
      print('catch ${ex.toString()}');
      yield ObjectError();
    }
  }
}
