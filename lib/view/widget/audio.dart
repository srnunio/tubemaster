import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tubemaster/core/model/data.dart';
import 'package:tubemaster/utils/Translations.dart';
import 'package:tubemaster/utils/Utils.dart';
import 'package:tubemaster/utils/styles.dart';

class AudioSection extends StatelessWidget {
  final Audio audio;
  final Function onActive;
    bool value = true;

  AudioSection(this.audio,
      {this.onActive, this.value});

  _buildAudio() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            padding: EdgeInsets.all(6.0),
            height: 38.0,
            width: 38.0,
            child: Center(
              child: SvgPicture.asset('assets/icons/music.svg',
                  height: 32, width: 32, color: Colors.white),
            ),
            decoration: BoxDecoration(
                color: Styles.placeholderColor,
                borderRadius: BorderRadius.all(Radius.circular(4.0)))),
        SizedBox(
          width: 16.0,
        ),
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                        child: Styles.titleWidget('audio',
                            reference: true, fontWeight: FontWeight.bold)),
                    Container(
                      height: 32,
                      padding: EdgeInsets.all(6.0),
                      child: Switch(
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          value: value,
                          activeColor: Styles.iconColor,
                          inactiveTrackColor: Styles.placeholderColor,
                          onChanged:(value) {
                            if(onActive == null) return;
                            onActive(value);
                          }),
                    )
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Styles.titleWidget('size',
                        reference: true,
                        fontWeight: FontWeight.bold,
                        color: Styles.iconColor),
                    SizedBox(
                      width: 4,
                    ),
                    Styles.titleWidget(' - ${Utils.formatBytes(audio.size, 2)}')
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Styles.titleWidget('format',
                        reference: true,
                        fontWeight: FontWeight.bold,
                        color: Styles.iconColor),
                    SizedBox(
                      width: 4,
                    ),
                    Styles.titleWidget(' - ${Utils.format(audio.format)}')
                  ],
                )
              ],
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => _buildAudio();
}
