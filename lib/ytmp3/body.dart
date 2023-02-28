import 'dart:io';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_to_mp3/constant.dart';
import 'package:youtube_to_mp3/public_component/custom_dialog.dart';
import 'package:youtube_to_mp3/public_component/theme_snack_bar.dart';
import 'package:youtube_to_mp3/theme.dart';


class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _urlController = TextEditingController();
  bool disabled = true;
  bool clicked = false;
  bool valid = true;
  String _title = "";
  String _author = "";
  String _upload_date = "";
  String _thumbnail =
      "https://www.talkhelper.com/wp-content/uploads/2020/01/youtube-to-mp3.png";

  void search(e) async {
    var yt = YoutubeExplode();
    try {
      var video = await yt.videos.get(e);
      print(video);
      setState(() {
        valid = true;
        _title = video.title;
        _author = video.author;
        _upload_date =
            "${video.uploadDate!.day}/${video.uploadDate!.month}/${video.uploadDate!.year}";
        _thumbnail = video.thumbnails.standardResUrl;
        disabled = false;
      });
    } on ArgumentError {
      setState(() {
        valid = false;
        disabled = true;
        _title = "Invalid URL";
        _author = "Invalid URL";
        _upload_date = "Invalid URL";
        _thumbnail =
            "https://www.talkhelper.com/wp-content/uploads/2020/01/youtube-to-mp3.png";
      });
    } on VideoUnavailableException {
      setState(() {
        valid = false;
        disabled = true;
        _title = "Invalid URL";
        _author = "Invalid URL";
        _upload_date = "Invalid URL";
        _thumbnail =
            "https://www.talkhelper.com/wp-content/uploads/2020/01/youtube-to-mp3.png";
      });
    }
    yt.close();
  }



  void downloadVideo({String? link, bool? isVideo}) async {
    var validURL = Uri.tryParse(link!)?.hasAbsolutePath ?? false;
    print(validURL);
    setState(() {
      clicked = true;
    });

    if (link == "") {
      CustomDialog.show(
        context,
        title: "Link is empty",
        btnOkText: "Ohh",
        btnOkOnPress: () {
          Navigator.pop(context);
        },
      );
      setState(() {
        clicked = false;
      });
    } else {
      late BuildContext dialogContext;

      CustomDialog.show(
        context,
        title: "Downloading . . .",
        isDissmissable: false,
        center: Builder(builder: (BuildContext context) {
          dialogContext = context;
          return const Center(
            child: CircularProgressIndicator(),
          );
        }),
      );

      YoutubeExplode yt = YoutubeExplode();

      String charReplace(String str) {
        str = str.replaceAll(r'\', " ");
        str = str.replaceAll("/", " ");
        str = str.replaceAll(">", " ");
        str = str.replaceAll("<", " ");
        str = str.replaceAll("*", " ");
        str = str.replaceAll("?", " ");
        str = str.replaceAll(r'"', " ");
        str = str.replaceAll(":", " ");
        str = str.replaceAll("|", "-");

        return str;
      }

      try {
        var video = await yt.videos.get(link);
        print(video);
        var thumbnailUrl = video.thumbnails.standardResUrl;
        // print(r'"');
        try {
          var manifest = await yt.videos.streamsClient.getManifest(link);
          var vid = await yt.videos.get(link);
          print(vid.thumbnails.standardResUrl);

          if (isVideo!) {
            var directory = await AndroidPathProvider.downloadsPath;
            var info = manifest.muxed.sortByVideoQuality().first;
            var stream = yt.videos.streams.get(info);
            var newDr = "$directory/YouMp3 Video";
            var replaceTitle = charReplace(vid.title);
            var file =
                await File("$newDr/$replaceTitle.mp4").create(recursive: true);
            var fileStream = file.openWrite();
            await stream.pipe(fileStream);
            await fileStream.flush();
            await fileStream.close();
            // Download the thumbnail image file
            // var thumbnailResponse = await http.get(Uri.parse(thumbnailUrl));
            // var thumbnailBytes = thumbnailResponse.bodyBytes;
            // var thumbnailFile =
            //     await File("$newDr/$replaceTitle.jpg").create(recursive: true);
            // await thumbnailFile.writeAsBytes(thumbnailBytes);

            // Set the video thumbnail as the metadata of the downloaded video file
            // await _setMetadata(file.path, thumbnailFile.path);
            Navigator.pop(dialogContext);

            // ignore: use_build_context_synchronously
            await CustomDialog.show(
              context,
              title: "Download Video Complete",
              top: const Center(
                child: Icon(
                  Icons.check_circle,
                  size: 70,
                  color: kPrimaryColor,
                ),
              ),
              center: Center(
                child: Text(
                  "Downloaded in ${file.path}",
                ),
              ),
              btnOkText: "OK",
              btnOkOnPress: (() {
                Navigator.pop(context);
              }),
            );
            setState(() {
              clicked = false;
            });
          } else {
            var directory = await AndroidPathProvider.downloadsPath;
            var musicDirectory = await AndroidPathProvider.musicPath;
            print("directoy music");
            print(directory.toString());
            var info = manifest.audioOnly.sortByBitrate().first;
            var stream = yt.videos.streams.get(info);
            var replaceTitle = charReplace(vid.title);
            print(stream);

            var newDr = "$directory/YouMp3 Music";

            var file = await File("$musicDirectory/$replaceTitle.mp3")
                .create(recursive: true);
            var fileStream = file.openWrite();
            print(fileStream);
            await stream.pipe(fileStream);

            await fileStream.flush();
            await fileStream.close();
            // // Download the thumbnail image file
            // var thumbnailResponse = await http.get(Uri.parse(thumbnailUrl));
            // var thumbnailBytes = thumbnailResponse.bodyBytes;
            // var thumbnailFile = await File("$musicDirectory/$replaceTitle.jpg")
            //     .create(recursive: true);
            // await thumbnailFile.writeAsBytes(thumbnailBytes);

            // Set the music thumbnail as the metadata of the downloaded music file
            // await _setMetadata(file.path, thumbnailFile.path);
            Navigator.pop(context);
            // ignore: use_build_context_synchronously
            await CustomDialog.show(
              context,
              title: "Download Music Complete",
              top: const Center(
                child: Icon(
                  Icons.check_circle,
                  size: 70,
                  color: kPrimaryColor,
                ),
              ),
              center: Center(
                child: Text(
                  "Downloaded in ${file.path}",
                ),
              ),
              btnOkText: "OK",
              btnOkOnPress: (() {
                Navigator.pop(context);
              }),
            );

            setState(() {
              clicked = false;
            });
          }
        } on ArgumentError {
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
          // ignore: use_build_context_synchronously
          CustomDialog.show(
            context,
            title: "Something Went Wrong",
            btnOkText: "I see",
            btnOkOnPress: () {
              Navigator.pop(context);
            },
          );
          setState(() {
            clicked = false;
          });
        } on VideoUnavailableException {
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
          // ignore: use_build_context_synchronously
          CustomDialog.show(
            context,
            title: "This is video is not available",
            btnOkText: "I see",
            btnOkOnPress: () {
              Navigator.pop(context);
            },
          );
          setState(() {
            clicked = false;
          });
        }
      } on ArgumentError {
        Navigator.pop(context);
        CustomDialog.show(
          context,
          title: "Link is invalid",
          btnOkText: "I see",
          btnOkOnPress: () {
            Navigator.pop(context);
          },
        );
        setState(() {
          clicked = false;
        });
      } on VideoUnavailableException {
        Navigator.pop(context);
        CustomDialog.show(
          context,
          title: "Link is invalid",
          btnOkText: "I see",
          btnOkOnPress: () {
            Navigator.pop(context);
          },
        );
        setState(() {
          clicked = false;
        });
      }
    }
  }

  void showDialog() {
    CustomDialog.show(
      context,
      title: "Please paste the youtube link",
      isDissmissable: false,
      btnOkText: "I Understand",
      btnOkOnPress: () {
        Navigator.pop(context);
      },
    );
  }

  Future<void> askPermission() async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted == true) {
      ThemeSnackBar.showSnackBar(context, "Extracting...");
      search(_urlController.value.text.trim());
    } else {
      status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              TextFormField(
                style: const TextStyle(color: kPrimaryColor),
                cursorColor: kPrimaryColor,
                onFieldSubmitted: (value) => search(value),
                controller: _urlController,
                decoration: textFieldInputDecoration(
                    "Youtube Link", "Paste your link here"),
              ),
              const SizedBox(height: 10),
              ScaleTap(
                onPressed: () {
                  if (_urlController.text == "") {
                    showDialog();
                  } else {
                    askPermission();

                    print(_urlController.text.trim());
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Extract Link',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              disabled
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScaleTap(
                          onPressed: clicked
                              ? null
                              : () {
                                  downloadVideo(
                                    link: _urlController.value.text.trim(),
                                    isVideo: false,
                                  );
                                },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 12,
                                  color: inputBoxShadowColor.withOpacity(0.12),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: const Text(
                              'Download Mp3',
                              style: TextStyle(color: kPrimaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        ScaleTap(
                          onPressed: clicked
                              ? null
                              : () {
                                  downloadVideo(
                                    link: _urlController.value.text.trim(),
                                    isVideo: true,
                                  );
                                },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 12,
                                  color: inputBoxShadowColor.withOpacity(0.12),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: const Text(
                              'Download Mp4',
                              style: TextStyle(color: kPrimaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 1),
                      blurRadius: 12,
                      color: inputBoxShadowColor.withOpacity(0.12),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: valid
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                              const Text(
                                "Video Details",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 23,
                                    fontFamily: "Youtube",
                                    color: kPrimaryColor),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              RichText(
                                  text: TextSpan(
                                      text: "Title: ",
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontFamily: "Youtube",
                                          color: kPrimaryColor),
                                      children: [
                                    TextSpan(
                                        text: _title.characters.take(80).string,
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontFamily:
                                                DefaultTextStyle.of(context)
                                                    .style
                                                    .fontFamily,
                                            color: kPrimaryColor))
                                  ])),
                              const SizedBox(
                                height: 10,
                              ),
                              RichText(
                                  text: TextSpan(
                                      text: "Author: ",
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontFamily: "Youtube",
                                          color: kPrimaryColor),
                                      children: [
                                    TextSpan(
                                        text:
                                            _author.characters.take(50).string,
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontFamily:
                                                DefaultTextStyle.of(context)
                                                    .style
                                                    .fontFamily,
                                            color: kPrimaryColor))
                                  ])),
                              const SizedBox(
                                height: 10,
                              ),
                              RichText(
                                  text: TextSpan(
                                      text: "Upload Date: ",
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontFamily: "Youtube",
                                          color: kPrimaryColor),
                                      children: [
                                    TextSpan(
                                        text: _upload_date,
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontFamily:
                                                DefaultTextStyle.of(context)
                                                    .style
                                                    .fontFamily,
                                            color: kPrimaryColor))
                                  ])),
                              const SizedBox(
                                height: 50,
                              ),
                              ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(50)),
                                child: FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: _thumbnail,
                                  height:
                                      MediaQuery.of(context).size.height * 0.35,
                                ),
                              ),
                            ])
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Invalid URL",
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50)),
                              child: FadeInImage.memoryNetwork(
                                fadeInDuration:
                                    const Duration(milliseconds: 100),
                                placeholder: kTransparentImage,
                                image: _thumbnail,
                                height:
                                    MediaQuery.of(context).size.height * 0.35,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "2022 \u00a9 Muhammad Izzat Mohamad Rizal",
                style: TextStyle(color: kPrimaryColor),
              )
            ],
          ),
        ),
      ),
    );
  }
}
