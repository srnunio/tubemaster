import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:tubemaster/core/data/preferences.dart';
import 'package:tubemaster/core/model/data.dart';

import 'home_bloc.dart';

abstract class ObjectEvent extends Equatable {}


abstract class HomeEvent extends ObjectEvent{
}


class HomeNewsEvent extends HomeEvent{
  @override
  String toString() => 'HomeNewsEvent';
}

class HomeVideosEvent extends HomeEvent{
  @override
  String toString() => 'HomeVideosEvent';
}


class HomeNotificationsEvent extends HomeEvent{
  @override
  String toString() => 'HomeNotificationsEvent';
}


class InitEvent extends ObjectEvent {
  @override
  String toString() => 'InitEvent';
}

class FetchEvent extends ObjectEvent {
  final String link;

  FetchEvent(this.link);

  @override
  String toString() => 'FetchEvent';
}


class RefreshEvent extends ObjectEvent {
  @override
  String toString() => 'Refresh';
}

class InsertNewEvent extends ObjectEvent {
  final Object object;

  InsertNewEvent(this.object);

  @override
  String toString() => 'Refresh';
}


class RefreshVideo extends ObjectEvent {
  final Video video;

  RefreshVideo(this.video);
  @override
  String toString() => 'RefreshVideo';
}

class PushEvent extends ObjectEvent {
  @override
  String toString() => 'PushEvent';
}


class HomeConfigEvent extends ObjectEvent {
  @override
  String toString() => 'ConfigAppEvent';
}

class InitSettings extends HomeConfigEvent {
  @override
  String toString() => 'InitSettings';
}

class NetWork extends HomeConfigEvent {
 final bool value ;

 NetWork(this.value);

 @override
  String toString() => 'InitSettings';
}

class ChangeTheme extends HomeConfigEvent {
  final ThemeType themeType;
  ChangeTheme(this.themeType);
  @override
  String toString() => 'ConfigChangeTheme';
}

class ChangeLanguage extends HomeConfigEvent {
  final Locale locale;
  ChangeLanguage(this.locale);
  @override
  String toString() => 'ConfigChangeLanguage';
}
