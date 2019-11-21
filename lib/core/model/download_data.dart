import 'dart:convert';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:tubemaster/utils/Utils.dart';

abstract class DownloaderColmn {
  static const taskId = 'taskId';
  static const progress = 'progress';
  static const stateFile = 'stateFile';
}

class TaskDownloader {
  int id = -1;
  String taskId;
  String idVideo;
  String title;
  String description;
  int size;

  String linkDownload;
  int formatFile;
  String cover;
  String dir_url;
  String date;
  int progress = 0;
  int stateFile = DownloadTaskStatus.undefined.value;

  TaskDownloader(
      {this.id,
      this.taskId,
      this.idVideo,
      this.title,
      this.description,
      this.size,
      this.linkDownload,
      this.formatFile,
      this.cover,
      this.dir_url,
      this.date,
      this.progress,
      this.stateFile});

  get status => DownloadTaskStatus.from(stateFile);

  Format format() {
    return Format.values[formatFile];
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "taskId": taskId,
        "idVideo": idVideo,
        "title": title,
        "description": description,
        "size": size,
        "linkDownload": linkDownload,
        "formatFile": format().index,
        "cover": cover,
        "dir_url": dir_url,
        "date": date,
        "progress": progress,
        "stateFile": status.value,
      };

  TaskDownloader.fromJsonMap(Map<String, dynamic> map)
      :
        id = int.tryParse(map['id']),
        taskId = map['taskId'],
        idVideo = map['idVideo'],
        title = map['title'],
        description = map['description'],
        linkDownload = map['linkDownload'],
        formatFile = int.tryParse(map['formatFile']),
        cover = map['cover'],
        dir_url = map['dir_url'],
        date = map['date'],
        progress = int.tryParse(map['progress']),
        size = int.tryParse(map['size']),
        stateFile = int.tryParse(map['stateFile']);
}

enum Format { mp3, mp4, wav, webm, mkv, avc }
