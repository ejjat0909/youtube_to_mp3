import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:youtube_to_mp3/constant.dart';

import 'package:youtube_to_mp3/public_component/method.dart';

class LoadingGifDialogue extends StatefulWidget {
  final String gifPath;
  final String loadingText;
  final ValueNotifier<double>? progressNotifier;
  final ValueNotifier<String>? speedNotifier;
  final ValueNotifier<String> errorNotifier;
  const LoadingGifDialogue(
      {super.key,
      required this.gifPath,
      required this.loadingText,
      this.progressNotifier,
      this.speedNotifier,
      required this.errorNotifier});

  @override
  State<LoadingGifDialogue> createState() => _LoadingGifDialogueState();
}

class _LoadingGifDialogueState extends State<LoadingGifDialogue> {
  @override
  Widget build(BuildContext context) {
    double availableHeight = MediaQuery.of(context).size.height;
    double availableWidth = MediaQuery.of(context).size.width;
    return Dialog(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: availableHeight / 2,
          maxWidth: availableWidth,
        ),
        child: ValueListenableBuilder<String>(
            valueListenable: widget.errorNotifier,
            builder: (context, error, child) {
              if (error == "") {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          widget.progressNotifier == null
                              ? Text(
                                  widget.loadingText,
                                  style: textStyleMedium(color: Colors.black),
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${widget.loadingText} ',
                                            style: textStyleMedium(
                                                color: Colors.black),
                                          ),
                                          ValueListenableBuilder<double>(
                                            valueListenable:
                                                widget.progressNotifier!,
                                            builder:
                                                (context, progress, child) {
                                              return Text(
                                                "${progress.toStringAsFixed(0)}%",
                                                style: textStyleMedium(
                                                    color: Colors.black),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    widget.speedNotifier == null
                                        ? Container()
                                        : Expanded(
                                            child:
                                                ValueListenableBuilder<String>(
                                              valueListenable:
                                                  widget.speedNotifier!,
                                              builder: (context, speed, child) {
                                                return Text(
                                                  " $speed",
                                                  style: textStyleMedium(
                                                      color: Colors.blueAccent),
                                                );
                                              },
                                            ),
                                          ),
                                  ],
                                ),
                          const SizedBox(
                            height: 10,
                          ),
                          ValueListenableBuilder<double>(
                              valueListenable: widget.progressNotifier!,
                              builder: (context, progress, child) {
                                return CircularProgressIndicator(
                                  value: progress == 0 ? null : progress / 100,
                                );
                              }),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SelectableText(
                        error,
                        style: textStyleMedium(color: kPrimaryColor),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ScaleTap(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                      child: Text(
                                    "Report to Master",
                                    style: TextStyle(color: Colors.white),
                                  )),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }
}
