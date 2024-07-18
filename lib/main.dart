import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_to_mp3/constant.dart';
import 'package:youtube_to_mp3/public_component/method.dart';

import 'package:youtube_to_mp3/ytmp3/ytmp3_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await requestPermissions();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YouMp3',
      theme: ThemeData(
        primarySwatch: kPrimaryColor,
      ),
      home: const YtMp3Screen(),
    );
  }
}
