import 'package:flutter/material.dart';

import 'package:youtube_to_mp3/constant.dart';
import 'package:youtube_to_mp3/ytmp3/body.dart';

class YtMp3Screen extends StatefulWidget {
  const YtMp3Screen({super.key});

  @override
  State<YtMp3Screen> createState() => _YtMp3ScreenState();
}

class _YtMp3ScreenState extends State<YtMp3Screen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Youtube Downloader",
            style: TextStyle(color: kPrimaryColor),
          ),
        ),
        body: Body(),
      ),
    );
  }
}
