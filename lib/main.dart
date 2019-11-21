import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tubemaster/core/bloc/home_bloc.dart';
import 'package:tubemaster/core/bloc/simple_bloc_delegate.dart';
import 'package:tubemaster/router.dart';

import 'core/data/data_base.dart';
import 'core/data/preferences.dart';
import 'utils/Translations.dart';
import 'package:bloc/bloc.dart';

void main() async {
  await FlutterDownloader.initialize();
  BlocSupervisor.delegate = SimpleBlocDelegate();
  await Tools.init();
  await DataBaseUtils.initDB();
  await Translations.load(await Tools.onLanguage());
  runApp(new TubeMaster());
}

class TubeMaster extends StatelessWidget {
  static TargetPlatform platform;
  @override
  Widget build(BuildContext context) {
    platform = Theme.of(context).platform;
    return BlocProvider<HomeBloc>(
      builder: (context) => HomeBloc(),
      child: BlocBuilder<HomeBloc, Setting>(
        builder: (context, config) {
          return MaterialApp(
            supportedLocales: [
              const Locale('pt', 'PT'),
              const Locale('en', 'US'),
              config.locale
            ],
            localizationsDelegates: [
              const TranslationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate
            ],
            localeResolutionCallback:
                (Locale locale, Iterable<Locale> supportedLocales) {
              for (Locale supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode ||
                    supportedLocale.countryCode == locale.countryCode) {
                  return supportedLocale;
                }
              }

              return supportedLocales.first;
            },
            debugShowCheckedModeBanner: false,
            theme: config.themeData,
            initialRoute: '/',
            onGenerateRoute: Router.generateRoute,
          );
        },
      ),
    );
  }
}
