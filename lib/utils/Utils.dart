import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tubemaster/core/model/data.dart';
import 'package:tubemaster/core/model/download_data.dart';
import 'package:tubemaster/core/model/enums.dart';
import 'package:tubemaster/utils/styles.dart';

import 'Translations.dart';
import 'constants.dart';

class Utils {
  static String text(String value) {
    return '''${value.replaceAll('"', '').replaceAll('|', '')}''';
  }


  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  static bool validLinkYoutube(String link){
    if(link.isEmpty || !link.contains(Vars.LINKED_TUBE_VIDEO))
      return false;
    else
      return true;
  }
  static bool validPlayListYoutube(String link){
    if(link.contains(Vars.PLAYLIST_TUBE_VIDEO))
      return false;
    else
      return true;
  }

  static logs(String message) {
    print(message);
  }

  static List<Format> formatFile(EFile eFile) {
    switch (eFile) {
      case EFile.audio:
        return [Format.mp3];
      case EFile.video:
        return [Format.mp4, Format.mkv, Format.webm];
    }
  }

  static EFile fileFormat(Format format) {
    return [Format.mp4, Format.mkv, Format.avc].contains(format) ? EFile.video : EFile.audio;
  }


  static String format(Format format) {
    return format.toString().replaceAll('Format.', '');
  }

  static String quality(EViedoQuality quality) {
    var value = quality.toString().replaceAll('EViedoQuality.', '');
    if (value.contains('Low')) {
      var newValue = value.replaceAll('Low', '');
      var size = int.tryParse(newValue);
      return size == 0
          ? Translations.current.text('low')
          : '${Translations.current.text('low')} (${size})';
    }

    if (value.contains('Medium')) {
      var newValue = value.replaceAll('Medium', '');
      var size = int.tryParse(newValue);
      return size == 0
          ? Translations.current.text('medium')
          : '${Translations.current.text('medium')} (${size})';
    }

    if (value.contains('High')) {
      var newValue = value.replaceAll('High', '');
      var size = int.tryParse(newValue);
      return size == 0
          ? Translations.current.text('high')
          : '${Translations.current.text('high')} (${size})';
    }
    return '---';
  }

  static progress({Color color = null}) {
    color = color == null ? Styles.progressColor : color;
    return Center(
      child: Container(
        padding: EdgeInsets.all(5.0),
        child: CircularProgressIndicator(
            strokeWidth: 1.0, valueColor: AlwaysStoppedAnimation<Color>(color)),
      ),
    );
  }

  static void messageToas({String message}) {
    Fluttertoast.showToast(
        msg: message,
        backgroundColor: Colors.black.withOpacity(0.7),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static Future<bool> isConection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }

  static Color parseColor(String color) {
    String hex = color.replaceAll("#", "");
    if (hex.isEmpty) hex = "ffffff";
    if (hex.length == 3) {
      hex =
          '${hex.substring(0, 1)}${hex.substring(0, 1)}${hex.substring(1, 2)}${hex.substring(1, 2)}${hex.substring(2, 3)}${hex.substring(2, 3)}';
    }
    Color col = Color(int.parse(hex, radix: 16)).withOpacity(1.0);
    return col;
  }
}
