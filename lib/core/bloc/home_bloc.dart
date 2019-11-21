import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tubemaster/core/data/preferences.dart';
import 'package:tubemaster/utils/Translations.dart';
import 'package:tubemaster/utils/styles.dart';
import 'package:tubemaster/main.dart';
import 'package:youtube_api/generated/i18n.dart';
import 'package:path_provider/path_provider.dart';

import 'object_event.dart';

class Setting {
  ThemeData themeData = Styles.themeDark();
  Locale locale = Translations.current.locale;
}

class HomeBloc extends Bloc<HomeConfigEvent, Setting> {
  @override
  Setting get initialState => Setting();

  ThemeType themeType;
  Setting setting;

  HomeBloc() {
    themeType = Tools.onThemeType();
    setting = Setting();
    dispatch(InitSettings());
  }

  ThemeData _onTheme(ThemeType themeType) {
    return themeType == ThemeType.Light
        ? Styles.themeDark()
        : Styles.themeDark();
  }

  Future createdDir() async {
    var localPath = (await _findLocalPath()) + '/Download/TubeMaster';

    final savedDir = Directory(localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted || Tools.onDir() == null) {
      savedDir.create();
      Tools.updateDir(savedDir.path);
    }
  }

  Future<String> _findLocalPath() async {
    final directory = TubeMaster.platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path
        .replaceAll('/Android/data/com.tube_download_master/files', "");
  }

  Future<bool> checkPermission(BuildContext context) async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler()
                .requestPermissions([PermissionGroup.storage]);
        if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
          await createdDir();
          return true;
        }
      } else {
        if (Tools.onDir() == null) {
          await createdDir();
        }
        return true;
      }
    } else {
      return true;
    }

    return false;
  }

  @override
  Stream<Setting> mapEventToState(HomeConfigEvent event) async* {
    setting = Setting();
    if (event is InitSettings) {
//      configApp.locale = await Tools.onLanguage();

      setting.themeData = themeType == ThemeType.Light
          ? Styles.themeDark()
          : Styles.themeDark();
      yield setting;
    } else if (event is ChangeTheme) {
      var configTheme = (event as ChangeTheme);
      themeType = configTheme.themeType;
      setting.themeData = _onTheme(themeType);
      yield setting;
    } else if (event is ChangeLanguage) {
      var configLanguage = (event as ChangeLanguage);
      setting.locale = configLanguage.locale;
      setting.themeData = _onTheme(themeType);
      yield setting;
    }
  }
}
