// import 'package:flutter/material.dart';
// import 'package:youtube_downloader/youtube_downloader.dart';

// class DownloadVideo extends StatefulWidget {
//   const DownloadVideo({super.key});

//   @override
//   State<DownloadVideo> createState() => _DownloadVideoState();
// }

// class _DownloadVideoState extends State<DownloadVideo> {
//   YoutubeDownloader youtubeDownloader = YoutubeDownloader();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//                 onPressed: () async {
//                   final result = await youtubeDownloader.downloadYoutubeVideo(
//                       "https://www.youtube.com/watch?v=yX0LzL9SHig", "mp3");
//                   print(result?.downloadUrl);
//                 },
//                 child: Text("downlaod"))
//           ],
//         ),
//       ),
//     );
//     // return Scaffold(
//     //   appBar: AppBar(),
//     //   body: FutureBuilder<VideoInfo?>(
//     //     future: youtubeDownloader.downloadYoutubeVideo(
//     //         "https://www.youtube.com/watch?v=yX0LzL9SHig", "mp3"),
//     //     builder: (context, snapshot) {
//     //       if (snapshot.hasData) {
//     //         print("download url ${snapshot.data?.downloadUrl}");
//     //         return Center(
//     //           child: Column(
//     //               crossAxisAlignment: CrossAxisAlignment.center,
//     //               mainAxisAlignment: MainAxisAlignment.center,
//     //               children: [
//     //                 Text("${snapshot.data?.authorName}"),
//     //                 Text("${snapshot.data?.authorUrl}"),
//     //                 Text("${snapshot.data?.downloadUrl}"),
//     //                 Text("${snapshot.data?.height}"),
//     //                 Text("${snapshot.data?.providerUrl}"),
//     //                 Text("${snapshot.data?.thumbnailHeight}"),
//     //                 Text("${snapshot.data?.thumbnailWidth}"),
//     //                 Text("${snapshot.data?.thumbnailUrl}"),
//     //                 Text("${snapshot.data?.title}"),
//     //                 Text("${snapshot.data?.type}"),
//     //                 Text("${snapshot.data?.width}"),
//     //               ]),
//     //         );
//     //       } else {
//     //         print("download url ${snapshot.data?.downloadUrl}");
//     //         return const CircularProgressIndicator();
//     //       }
//     //     },
//     //   ),
//     // );
//   }
// }
