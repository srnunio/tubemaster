import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tubemaster/core/model/data.dart';
import 'package:tubemaster/utils/Translations.dart';
import 'package:tubemaster/utils/Utils.dart';
import 'package:tubemaster/utils/styles.dart';

class VideoSection extends StatelessWidget {
  final Video currentVideo;
  final List<Video> videos;
  final Function onActive;
  final Function onSelectQuality;
  final Function onSelectFormat;
  final bool value;
    bool isValidDownload = true;

  VideoSection(this.currentVideo, this.videos,
      {this.onActive, this.value, this.onSelectQuality, this.onSelectFormat,this.isValidDownload});

  _buildQuality() {
    if (!value) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 16,
        ),
        Styles.line(),
        SizedBox(
          height: 8,
        ),
        Styles.titleWidget('quality_size',
            overflow: false,
            reference: true,
            color: Styles.iconColor,
            fontWeight: FontWeight.bold),
        SizedBox(
          height: 4.0,
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          direction: Axis.horizontal,
          children: List.generate(videos.length, (index) {
            var aux = videos[index];
            return GestureDetector(
              onTap: onSelectQuality == null
                  ? null
                  : () {
                      onSelectQuality(aux);
                    },
              child: Chip(
                  clipBehavior: Clip.hardEdge,
                  backgroundColor: (aux.url == currentVideo.url)
                      ? Styles.placeholderColor
                      : Styles.iconColor,
                  label: Styles.titleWidget(Utils.quality(aux.quality),
                      overflow: false,
                      textSize: Styles.textSize12,
                      fontWeight: FontWeight.bold,
                      color: (aux.url == currentVideo.url)
                          ? Styles.titleColor
                          : Colors.black)),
            );
          }),
        )
      ],
    );
  }

  _buildFormat() {
    if (!value) return Container();

    var formats = Utils.formatFile(EFile.video);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 16,
        ),
        Styles.line(),
        SizedBox(
          height: 8,
        ),
        Styles.titleWidget('format_size',
            overflow: false,
            reference: true,
            color: Styles.iconColor,
            fontWeight: FontWeight.bold),
        SizedBox(
          height: 4.0,
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          direction: Axis.horizontal,
          children: List.generate(formats.length, (index) {
            var aux = formats[index];
            return GestureDetector(
              onTap: onSelectFormat == null
                  ? null
                  : () {
                      onSelectFormat(aux);
                    },
              child: Chip(
                  clipBehavior: Clip.hardEdge,
                  backgroundColor: (aux == currentVideo.format)
                      ? Styles.placeholderColor
                      : Styles.iconColor,
                  label: Styles.titleWidget(Utils.format(aux),
                      overflow: false,
                      textSize: Styles.textSize12,
                      fontWeight: FontWeight.bold,
                      color: (aux == currentVideo.format)
                          ? Styles.titleColor
                          : Colors.black)),
            );
          }),
        )
      ],
    );
  }

  _buildVideo() {
    Utils.logs('VideoSection , Size ${currentVideo.size}');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            padding: EdgeInsets.all(6.0),
            height: 38.0,
            width: 38.0,
            child: Center(
              child: SvgPicture.asset('assets/icons/youtube.svg',
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
                    child: Styles.titleWidget('video',
                        reference: true, fontWeight: FontWeight.bold)),
                Container(
                  height: 32,
                  padding: EdgeInsets.all(6.0),
                  child: Switch(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: value,
                    activeColor: Styles.iconColor,
                    inactiveTrackColor: Styles.placeholderColor,
                    onChanged: onActive == null
                        ? null
                        : (value) {
                            onActive(value);
                          },
                  ),
                )
              ],
            ),
            SizedBox(
              height: 4,
            ),
            (!isValidDownload && value)? Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      color: Styles.iconColor,
                      borderRadius: BorderRadius.circular(4.0)
                  ),
                  child: Center(
                    child: Styles.titleWidget(
                        Translations.current
                            .text('waring_download_video')
                            .replaceAll('#', Utils.formatBytes(currentVideo.size, 2)),color: Colors.black,fontWeight: FontWeight.bold,overflow: false),
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
              ],
            ) : Container()
            ,

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
                Styles.titleWidget(
                    ' - ${Utils.formatBytes(currentVideo.size, 2)}')
              ],
            ),
            SizedBox(
              height: 4,
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
                Styles.titleWidget(
                  ' - ${Utils.format(currentVideo.format)}',
                ),
              ],
            ),
            SizedBox(
              height: 4,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Styles.titleWidget('quality',
                    reference: true,
                    fontWeight: FontWeight.bold,
                    color: Styles.iconColor),
                SizedBox(
                  width: 4,
                ),
                Styles.titleWidget(
                  ' - ${Utils.quality(currentVideo.quality)}',
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            _buildQuality(),
            _buildFormat()
          ],
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => _buildVideo();
}
