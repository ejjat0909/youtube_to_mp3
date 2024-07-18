import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_to_mp3/constant.dart';

TextStyle textStyleNormal(
    {Color color = Colors.black, double? fontSize, FontWeight? fontWeight}) {
  return TextStyle(
      color: color,
      fontSize: fontSize ?? 14,
      fontFamily: "Poppins",
      fontWeight: fontWeight ?? FontWeight.normal,
      decoration: TextDecoration.none);
}

TextStyle textStyleMedium({Color color = kTextGray}) {
  return TextStyle(
    color: color,
    fontSize: 14,
    fontFamily: "Poppins",
    fontWeight: FontWeight.w500,
  );
}

String formatSpeed(double speedInBytesPerSecond) {
  if (!speedInBytesPerSecond.isFinite) {
    return '0 B/s';
  }
  if (speedInBytesPerSecond >= 1e9) {
    return '${(speedInBytesPerSecond / 1e9).toStringAsFixed(2)} GB/s';
  } else if (speedInBytesPerSecond >= 1e6) {
    return '${(speedInBytesPerSecond / 1e6).toStringAsFixed(2)} MB/s';
  } else if (speedInBytesPerSecond >= 1e3) {
    return '${(speedInBytesPerSecond / 1e3).toStringAsFixed(2)} KB/s';
  } else {
    return '${speedInBytesPerSecond.toStringAsFixed(2)} B/s';
  }
}

Future<bool> requestPermissions() async {
// You can request multiple permissions at once.
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
  ].request();

  if (Platform.isAndroid) {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    var release = androidInfo.version.release;
    print("release $release");

    if (int.parse(release) >= 13) {
      Map<Permission, PermissionStatus> newerAndroidPerms = await [
        Permission.storage,
        Permission.manageExternalStorage,
      ].request();

      if (newerAndroidPerms.containsValue(PermissionStatus.denied)) {
        return false;
      } else {
        return true;
      }
    }
  }

  if (statuses.containsValue(PermissionStatus.denied)) {
    return false;
  } else {
    return true;
  }
}
