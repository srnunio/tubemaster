
import 'package:flutter/material.dart';
import 'package:tubemaster/view/pages/download_list_page.dart';
import 'package:tubemaster/view/pages/link_page.dart';
import 'package:tubemaster/view/pages/splash_page.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
//        return MaterialPageRoute(builder: (_) => ProcessLinkPage('https://youtu.be/TfINqrwPn7w'));
//        return MaterialPageRoute(builder: (_) => SplashScreen());
        return MaterialPageRoute(builder: (_) => DownlaodListPage());
      case '/list':
        return MaterialPageRoute(builder: (_) => DownlaodListPage());
      case '/processLink':
        var link = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => ProcessLinkPage(link));
      default:
        return MaterialPageRoute(builder: (_) => SplashScreen());
    }
  }
}
