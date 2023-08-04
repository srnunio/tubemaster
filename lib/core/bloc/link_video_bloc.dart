import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';
import 'package:tubemaster/core/data/preferences.dart';
import 'package:tubemaster/core/model/data.dart';
import 'package:tubemaster/utils/Utils.dart';
import 'package:tubemaster/utils/constants.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:youtube_extractor/youtube_extractor.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../model/download_data.dart';
import 'object_event.dart';
import 'object_state.dart';

class LinkVideoBloc extends Bloc<ObjectEvent, ObjectState> {
  YoutubeAPI api = new YoutubeAPI(Vars.KEY_API);
  List<YT_API> ytResult = [];
   http.Client client;
  String _link;

  onSetLink(String link) {
    this._link = link;
    dispatch(FetchEvent(link));
    print('Start link = ${link}');
  }

  _initApi() {
    api = new YoutubeAPI(Vars.KEY_API);
    ytResult = [];
  }

  @override
  get initialState => Uninitialized();

  @override
  Stream<ObjectState> mapEventToState(ObjectEvent event) async* {
    try {
      if (currentState is Uninitialized) {
        yield ObjectLoaded(
            objects: List<TaskDownloader>(), hasReachedMax: true);
        onSetLink(_link);
        return;
      }
      if(event is RefreshVideo){
        var state = (currentState as VideoDetailState);
        var newVideo = (event as RefreshVideo).video;
        yield VideoDetailState(videos: state.videos , currentVideo: newVideo);
        return;
      }
      if (event is FetchEvent) {
        yield Uninitialized();
        _initApi();


        var link = (event as FetchEvent).link; 

        TaskDownloader result = TaskDownloader();
        String query = YoutubePlayer.convertUrlToId(link);
        Utils.logs('query ${query}');
        var results = await api.search(query);
        ytResult = results;
        for (YT_API yt_api in ytResult) {
          if (yt_api.id == query) { 
            var download = TaskDownloader();
            download.idVideo = yt_api.id;
            download.title = yt_api.title; 
            download.description = yt_api.description;
            download.cover = yt_api.thumbnail['high']['url']; 
            download.stateFile = DownloadTaskStatus.undefined.value;
            print('download.cover = ${download.cover}');
            result = download;
            break;
          }
        }
        var extractor = YouTubeExtractor();
        var media = await extractor.getMediaStreamsAsync(result.idVideo); 

        var audio = Audio(
          url: media.audio.first.url,
          size: media.audio.first.size,
        );
        List<Video> listVideos = [];

        for(var v in media.video){
          var video = Video(
            url: v.url,
            size:v.size,
            quality: EViedoQuality.values[v.videoQuality.index]
          );
          v.videoEncoding;
          print('------------------------------------------');
          Utils.logs(' v.url ${ v.url}');
          Utils.logs(' v.videoEncoding ${ v.videoEncoding}');
          Utils.logs(' v.iTag ${ v.iTag}');
          Utils.logs(' v.Size ${Utils.formatBytes(v.size, 2)}');
          listVideos.add(video);
          print('------------------------------------------'); 
        }
        yield VideoDetailState(downloader: result,audio: audio,videos: listVideos);
      } else {
        yield ObjectError();
      }
    } catch (ex) {
      print('catch ${ex.toString()}');
      yield ObjectError();
    }
  }
}
