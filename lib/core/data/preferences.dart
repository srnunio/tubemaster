import 'dart:io';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubemaster/utils/Translations.dart';

enum SortListing { CreatedAt, ModifiedAt }
enum ThemeType { Dark, Light }

class Tools {

  static SharedPreferences prefs;
  static final ThemeType_KEY = 'ThemeType';
  static final LANGUAGE = 'LANGUAGE';
  static final DIR_TUBEMASTER = 'DIR_TUBEMASTER';

  static final Languages = ['pt', 'en'];

  static init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static updateDir(String value) {
    prefs.setString(DIR_TUBEMASTER,value);
  }

  static updateLanguage(String code) async {
    prefs.setString(LANGUAGE, code.trim());
    await Translations.load(Locale(code));
  }

  static updateTheme(ThemeType type) {
    prefs.setString(ThemeType_KEY, '${type}');
  }

  static Future<Locale> onLanguage() async {
    String code = prefs.getString(LANGUAGE) ?? Platform.localeName;
    print('onLanguage : ${code}');
    return Translations.filterLocale(Locale(code));
  }

  static ThemeType onThemeType() {
    var type = prefs.getString(ThemeType_KEY) ?? null;
    return (type == null)
        ? ThemeType.Light
        : (type == '${ThemeType.Light}') ? ThemeType.Light : ThemeType.Dark;
  }

  static String onDir() {
    return prefs.getString(DIR_TUBEMASTER) ?? null;
  }

}
