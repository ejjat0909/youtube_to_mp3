import 'package:http/http.dart' as http;
import 'dart:convert';

class Result {
  late String? title;
  late String? thumb;
  late String? filesize_audio;
  late String? filesize_video;
  late String? audio;
  late String? audio_ori;
  late String? video;
  late String? video_ori;

  Result({this.title, this.thumb, this.filesize_audio, this.filesize_video,
    this.audio, this.audio_ori, this.video, this.video_ori});

  factory Result.createPostResult(Map<String, dynamic> object){
    return Result(
      title: object['title'],
      thumb: object['thumb'],
      filesize_audio: object['filesize_audio'],
      filesize_video: object['filesize_video'],
      audio: object['audio'],
      audio_ori: object['audio_ori'],
      video: object['video'],
      video_ori: object['video_ori'],
    );
  }
  static Future connectToApi(String url) async{
    String apiUrl = 'https://api.akuari.my.id/downloader/youtube?link=' + url;
    final response = await http.get(Uri.parse(apiUrl));
    if(response.statusCode == 200) {
      return Result.createPostResult(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load url');
    }
  }
}