import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter_svg/svg.dart';
import 'package:tubemaster/utils/Translations.dart';

import 'Utils.dart';

class Styles {
  static const textSizeTitle = 16.0;
  static const textSize16 = 16.0;
  static final textBigTitle = 40.0;
  static final textSize12 = 12.0;
  static final textSize13 = 13.0;
  static Color titleColor;

  static Color subtitleColor;

  static Color placeholderColor;

  static Color iconColor;

  static Color progressColor;

  static Color backgroundColor;

  static ThemeData themeData;

//  static const Color backgroundColor = Colors.white;

  static buildErrorImage() {
    return Container(
      decoration: BoxDecoration(
        color: placeholderColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Center(
        child: SvgPicture.asset('assets/icons/cloudoff.svg',
            height: 40, width: 40, color: iconColor),
      ),
    );
  }

  static ThemeData themeDark() {
    titleColor = Colors.white;
    subtitleColor = Colors.white;
    iconColor = Utils.parseColor('#F2C029');
    progressColor = Utils.parseColor('#F2C029');
    backgroundColor = Utils.parseColor('#1C2126');
    placeholderColor = Utils.parseColor('#272C35');
    return ThemeData(
      scaffoldBackgroundColor: backgroundColor,
      brightness: Brightness.dark,
      primaryColor: backgroundColor,
      accentColor: progressColor,
      dialogBackgroundColor: backgroundColor,
      backgroundColor: backgroundColor,
      indicatorColor: progressColor,
    );
  }

  static Text titleWidget(String value,
      {double textSize,
      Color color,
      fontWeight = FontWeight.normal,
      int maxLines,
      bool reference = false,
      bool overflow = true}) {
    return Text(
      reference ? Translations.current.text(value) : '${value}',
      overflow: overflow ? TextOverflow.ellipsis : null,
      maxLines: maxLines,
      style: TextStyle(
          color: color ?? titleColor,
          fontWeight: fontWeight,
          fontSize: textSize ?? textSizeTitle),
    );
  }

  static Future alertErrorLink(BuildContext context,String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext c) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            child: Container(
              padding: EdgeInsets.all(16.0),
              height: 420,
              decoration: BoxDecoration(
                  color: Styles.backgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(child: Column(
                    children: <Widget>[
                      Container(
                        height: 80,
                        width: 80,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: placeholderColor, shape: BoxShape.circle),
                        child: Center(
                          child: SvgPicture.asset('assets/icons/link.svg',
                              height: 40, width: 40, color: iconColor),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10.0),
                        alignment: Alignment.center,
                        child: Center(
                          child: titleWidget(message,
                              overflow: false, color: Colors.white),
                        ),
                      ),
                    ],
                  )),
                  Container(
                    decoration: BoxDecoration(
                      color: Styles.progressColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    margin: EdgeInsets.all(16.0),
                    child: FlatButton(
                        padding: EdgeInsets.all(0),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 50.0,
                          decoration: BoxDecoration(
                            color: Styles.progressColor,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Styles.titleWidget('ok',
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        )),
                  )
                ],
              ),
            ),
          );
        });
  }

  static line() {
    return SizedBox(
      height: 1.0,
      width: double.infinity,
      child: Container(
        color: Styles.placeholderColor,
      ),
    );
  }
}
