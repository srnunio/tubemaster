import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tubemaster/core/model/data.dart';

import '../model/download_data.dart';

abstract class ObjectState extends Equatable {
  ObjectState([List props = const []]) : super(props);
}


abstract class HomeState extends Equatable {
}



class VideoDetailState extends ObjectState {
  final TaskDownloader downloader;
  final Audio audio;
   Video currentVideo;
  final List<Video> videos;

  bool isValidDownloadVideo(){
    if(currentVideo.size == null)
      return true;


    if(currentVideo.size > 80000000)
      return false;
    else
      return true;
  }


  bool isValid(){
    return (isAudio() && isVideo());
  }

  bool isAudio(){
    return audio == null ? false : true;
  }

  bool isVideo(){
    return videos == null || videos.length == 0 ? false : true;
  }

  onSetCurrentVideo(Video video){
    this.currentVideo = video;
  }

  VideoDetailState({this.downloader,this.audio, this.videos,this.currentVideo}){
    if(isVideo() && currentVideo == null) {
      currentVideo = videos[0];
    }
  }

  @override
  String toString() => 'VideoDetailState';
}

//class LinkViewState extends ObjectState{
//  final Linked audio;
//  final Linked video;
//
//  bool isValid(){
//    return (isAudio() && isVideo());
//  }
//
//  bool isAudio(){
//    return audio == null ? false : true;
//  }
//
//  bool isVideo(){
//    return video == null ? false : true;
//  }
//
//  LinkViewState({this.audio, this.video});
//
//  @override
//  String toString() => 'LinkViewState';
//}
//



class HomeNewsState extends HomeState {
  @override
  String toString() => 'HomeViewState';
}

class HomeVideoState extends HomeState {
  @override
  String toString() => 'HomeVideoState';
}

class HomeNotificationState extends HomeState {
  @override
  String toString() => 'HomeNotificationState';
}

class InitHome extends HomeState {
  InitHome();

  @override
  String toString() => 'InitHome';
}

class Uninitialized extends ObjectState {
  Uninitialized();

  @override
  String toString() => 'Uninitialized';
}

class ObjectNetWorkError extends ObjectState {
  @override
  String toString() => 'ObjectNetWorkError';
}

class ObjectError extends ObjectState {
  @override
  String toString() => 'ObjectError';
}

class ObjectLoaded extends ObjectState {
  final List<Object> objects;
  final bool hasReachedMax;

  ObjectLoaded({
    this.objects,
    this.hasReachedMax,
  }) : super([objects, hasReachedMax]);

  ObjectLoaded copyWith({
    List<TaskDownloader> downloads,
    bool hasReachedMax,
  }) {
    return ObjectLoaded(
      objects: downloads ?? this.objects,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() =>
      'PostLoaded { posts: ${objects.length}, hasReachedMax: $hasReachedMax }';
}
