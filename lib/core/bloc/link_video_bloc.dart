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
//        if(!Utils.validPlayListYoutube(link)){
//          var p = new YoutubeAPI(Vars.KEY_API,type:'youtube#playlistItem',maxResults : 25);
//          var r = await p.search('PL_N6VL1gm0aLlr0HQ6yl2lRXdSfuxMt-s');
//          Utils.logs('PlaysList ${r}');
////          client = http.Client();
////          var response = await client.get('https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=PL_N6VL1gm0aLlr0HQ6yl2lRXdSfuxMt-s&key=AIzaSyCaP-NwGuO4H9u1Y1Ly5g8b34YROBrhSII');
////          Utils.logs('PlaysList ${response.body}');
////          'https://www.googleapis.com/youtube/v3/playlists'
//        }

        TaskDownloader result = TaskDownloader();
        String query = YoutubePlayer.convertUrlToId(link);
        Utils.logs('query ${query}');
        var results = await api.search(query);
        ytResult = results;
        for (YT_API yt_api in ytResult) {
          if (yt_api.id == query) {
//            var extractor = YouTubeExtractor();
//            var audioInfo = await extractor.getMediaStreamsAsync(yt_api.id);
            var download = TaskDownloader();
            download.idVideo = yt_api.id;
            download.title = yt_api.title;
//            download.linkDownload = audioInfo.audio.first.url;
//            download.size = audioInfo.audio.first.size;
            download.description = yt_api.description;
            download.cover = yt_api.thumbnail['high']['url'];
//            download.format = Format.mp3;
//            download.dir_url = '${Tools.onDir()}/${download.title}.mp3';
            download.stateFile = DownloadTaskStatus.undefined.value;
            print('download.cover = ${download.cover}');
            result = download;
            break;
          }
        }
        var extractor = YouTubeExtractor();
        var media = await extractor.getMediaStreamsAsync(result.idVideo);

//        client = http.Client();
//        var response = await client.get(
//            'http://youlink.epizy.com/?url=https://www.youtube.com/watch?v=${result.idVideo}');
//        Utils.logs('PlaysList ${response.body}');

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
//          print('------------------------------------------');
//          print('Size Video : ${Utils.formatBytes(v.size, 2)}');
//          print('videoQuality : ${v.videoQuality}');
//          print('------------------------------------------');
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
