import 'dart:async';
import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_to_mp3/constant.dart';
import 'package:youtube_to_mp3/public_component/custom_dialog.dart';
import 'package:youtube_to_mp3/public_component/loading_gif_dialogue.dart';
import 'package:youtube_to_mp3/public_component/method.dart';
import 'package:youtube_to_mp3/public_component/show_dialogue.dart';
import 'package:youtube_to_mp3/public_component/theme_snack_bar.dart';
import 'package:youtube_to_mp3/theme.dart';

import 'package:path_provider/path_provider.dart' as path_provider;

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final String _extractedLink = 'Loading...';
  final _urlController = TextEditingController();
  bool disabled = true;
  bool clicked = false;
  bool valid = true;
  String _title = "";
  String _author = "";
  String _upload_date = "";
  String _thumbnail =
      "https://www.talkhelper.com/wp-content/uploads/2020/01/youtube-to-mp3.png";

  Future<void> search(e) async {
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

  Future<void> downloadVideo(BuildContext context,
      {String? link, bool? isVideo}) async {
    ValueNotifier<double> progressNotifier = ValueNotifier<double>(0);
    ValueNotifier<String> speedNotifier = ValueNotifier<String>('0 B/s');
    ValueNotifier<String> errorNotifier = ValueNotifier<String>('');
    var validURL = Uri.tryParse(link!)?.hasAbsolutePath ?? false;
    print("validURL: $validURL");
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
      showDialogue(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return LoadingGifDialogue(
              gifPath: "assets/images/play-download.gif",
              loadingText: "Downloading . . .",
              progressNotifier: progressNotifier,
              speedNotifier: speedNotifier,
              errorNotifier: errorNotifier,
            );
          });

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

        var thumbnailUrl = video.thumbnails.standardResUrl;
        // print(r'"');
        try {
          var manifest = await yt.videos.streamsClient.getManifest(link);
          var vid = await yt.videos.get(link);

          if (isVideo!) {
            var directory = await AndroidPathProvider
                .downloadsPath; // changed from AndroidPathProvider
            var info = manifest.muxed.sortByVideoQuality().first;
            var stream = yt.videos.streams.get(info);
            var newDr = "$directory/YouMp3 Video";
            var replaceTitle = charReplace(vid.title);
            var filePath = "$newDr/$replaceTitle.mp4";
            var file = File(filePath);
            if (await file.exists()) {
              file.delete();
            }

            var dio = Dio();
            int lastReceived = 0;
            int totalReceived = 0;
            Stopwatch stopwatch = Stopwatch()..start();
            Timer? timer;

// Start the timer to update speed every second
            try {
              timer = Timer.periodic(Duration(milliseconds: 500), (Timer t) {
                // Calculate bytes per second
                int bytesPerSecond = totalReceived - lastReceived;
                lastReceived = totalReceived;

                // Calculate speed
                double speed =
                    bytesPerSecond / 1; // Since the timer ticks every 1 second
                speedNotifier.value = formatSpeed(speed);
                print("speed: ${speedNotifier.value}");

                stopwatch.reset();
              });

              await dio.download(
                info.url.toString(),
                filePath,
                onReceiveProgress: (received, total) {
                  if (total != -1) {
                    // Calculate the progress
                    double singleFileProgress = (received / total);
                    progressNotifier.value = singleFileProgress * 100;

                    // Update total received
                    totalReceived = received;

                    print('progress: ${progressNotifier.value}');
                  }
                },
              );

              // Clean up the timer after the download is complete
              print("download url ${info.url}");
              Navigator.pop(context);
              timer.cancel();
            } on DioException catch (e) {
              errorNotifier.value = e.toString();
              print("error: ${errorNotifier.value}");
              timer?.cancel();
            }

            if (errorNotifier.value == "") {
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
                    "Downloaded in $filePath",
                  ),
                ),
                btnOkText: "OK",
                btnOkOnPress: (() {
                  Navigator.pop(context);
                }),
              );
            }
            setState(() {
              clicked = false;
            });
          } else {
            // for music
            // to get the path
            Directory? getDownloadPath =
                await path_provider.getApplicationDocumentsDirectory();
            String externalStorageDir = await AndroidPathProvider.musicPath;

            //to check the path exist or not
            // if (!await externalStorageDir.exists()) {
            //   await externalStorageDir.create(recursive: true);
            // }

            print("directoy music");

            var info = manifest.audio.withHighestBitrate();
            var stream = yt.videos.streams.get(info);

            var replaceTitle = charReplace(vid.title);

            var filePath = "$externalStorageDir/$replaceTitle.mp3";

            var file = File(filePath);
            if (await file.exists()) {
              file.delete();
            }

            var dio = Dio();
            int lastReceived = 0;
            int totalReceived = 0;
            Stopwatch stopwatch = Stopwatch()..start();
            Timer? timer;

// Start the timer to update speed every second
            try {
              timer = Timer.periodic(Duration(milliseconds: 500), (Timer t) {
                // Calculate bytes per second
                int bytesPerSecond = totalReceived - lastReceived;
                lastReceived = totalReceived;

                // Calculate speed
                double speed =
                    bytesPerSecond / 1; // Since the timer ticks every 1 second
                speedNotifier.value = formatSpeed(speed);
                print("speed: ${speedNotifier.value}");

                stopwatch.reset();
              });

              await dio.download(
                info.url.toString(),
                filePath,
                onReceiveProgress: (received, total) {
                  if (total != -1) {
                    // Calculate the progress
                    double singleFileProgress = (received / total);
                    progressNotifier.value = singleFileProgress * 100;

                    // Update total received
                    totalReceived = received;

                    print('progress: ${progressNotifier.value}');
                  }
                },
              );

              // Clean up the timer after the download is complete
              print("download url ${info.url}");
              Navigator.pop(context);
              timer.cancel();
            } on DioException catch (e) {
              errorNotifier.value = e.toString();
              print("error: ${errorNotifier.value}");
              timer?.cancel();
            }

            if (errorNotifier.value == "") {
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
                    "Downloaded in $filePath",
                  ),
                ),
                btnOkText: "OK",
                btnOkOnPress: (() {
                  Navigator.pop(context);
                }),
              );
            }

            setState(() {
              clicked = false;
            });
          }
        } on ArgumentError {
          Navigator.pop(context);
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
          Navigator.pop(context);
          CustomDialog.show(
            context,
            title: "This video is not available",
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
    // ValueNotifier<double> progressNotifier = ValueNotifier<double>(0);
    // ValueNotifier<String> speedNotifier = ValueNotifier<String>('0 B/s');

    // showDialogue(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (context) {
    //       return LoadingGifDialogue(
    //         gifPath: "assets/images/play-download.gif",
    //         loadingText: "Downloading . . .",
    //         progressNotifier: progressNotifier,
    //         speedNotifier: speedNotifier,
    //       );
    //     });
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

  Future<void> askPermission(BuildContext context) async {
    PermissionStatus status = await Permission.storage.request();
    print("status: $status");
    ThemeSnackBar.showSnackBar(context, "Extracting...");
    await search(_urlController.value.text.trim());
    // if (status.isGranted) {
    //   ThemeSnackBar.showSnackBar(context, "Extracting...");
    //   await search(_urlController.value.text.trim());
    // } else {
    //   status;
    // }
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
                onFieldSubmitted: (value) async {
                  await search(value);
                },
                controller: _urlController,
                decoration: textFieldInputDecoration(
                    "Youtube Link", "Paste your link here"),
              ),
              const SizedBox(height: 10),
              ScaleTap(
                onPressed: () async {
                  if (_urlController.text == "") {
                    showDialog();
                  } else {
                    await askPermission(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
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
                              : () async {
                                  await downloadVideo(
                                    context,
                                    link: _urlController.value.text.trim(),
                                    isVideo: false,
                                  );
                                },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0, 1),
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
                              : () async {
                                  await downloadVideo(
                                    context,
                                    link: _urlController.value.text.trim(),
                                    isVideo: true,
                                  );
                                },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0, 1),
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
                      offset: const Offset(0, 1),
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
              Text("© JAT",
                  style: TextStyle(
                      fontSize: 15,
                      fontFamily: DefaultTextStyle.of(context).style.fontFamily,
                      color: kPrimaryColor)),
            ],
          ),
        ),
      ),
    );
  }
}
