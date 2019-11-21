import 'package:flutter/material.dart';

import 'download_data.dart';
import 'enums.dart';
import 'package:youtube_extractor/youtube_extractor.dart';

class File {
    String url;
    int size;
    Container container;
    final EFile eFile;

  File({this.url, this.size, this.container, this.eFile});
}

class Audio extends File {
  Format format = Format.mp3;
  Audio({String url , Container container,int size}):super(eFile:EFile.audio,url:url,container:container,size:size);
}

class Video extends File {
  final EViedoQuality quality ;
  Format format = Format.mp4;
  Video({this.quality,String url , Container container,int size}):super(eFile:EFile.video,url:url,container:container,size:size);
}

enum EViedoQuality {
  /// Low quality (144p).
  Low144,

  /// Low quality (240p).
  Low240,

  /// Medium quality (360p).
  Medium360,

  /// Medium quality (480p).
  Medium480,

  /// High quality (720p).
  High720,

  /// High quality (1080p).
  High1080,

  /// High quality (1440p).
  High1440,

  /// High quality (2160p).
  High2160,

  /// High quality (2880p).
  High2880,

  /// High quality (3072p).
  High3072,

  /// High quality (4320p).
  High4320
}

enum EVideoEncoding {
  /// MPEG-4 Visual.
  Mp4V,

  /// MPEG-4 Part 10, Advanced Video Coding.
  H263,

  /// MPEG-4 Part 10, Advanced Video Coding.
  H264,

  /// VP8.
  Vp8,

  /// VP9.
  Vp9,

  /// AV1.
  Av1
}
enum EFile {
 video,audio
}
