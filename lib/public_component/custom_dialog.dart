import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_to_mp3/constant.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';

class CustomDialog extends StatefulBuilder {
  CustomDialog({required super.builder});

  static Future<void> show(BuildContext context,
      {StateSetter? stateSetter,
      bool dismissOnTouchOutside = true,
      bool isTitleBold = false,
      Widget? center,
      Widget? top,
      @required title,
      btnOkText,
      btnCancelText,
      bool isDissmissable = true,
      Function()? btnCancelOnPress,
      Function()? btnOkOnPress}) async {
    return await showDialog(
        barrierDismissible: isDissmissable,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setter) {
            stateSetter = setter;
            return WillPopScope(
              onWillPop: () async => isDissmissable,
              child: Dialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      top ?? SizedBox(height: 0),
                      top == null ? SizedBox(height: 0) : SizedBox(height: 10),
                      Text(
                        title ?? "",
                        textAlign: TextAlign.center,
                        style: isTitleBold
                            ? const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)
                            : TextStyle(color: kPrimaryColor),
                      ),
                      SizedBox(height: 10),
                      center == null ? SizedBox(height: 0) : center,
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          btnCancelText != null
                              ? Expanded(
                                  child: ScaleTap(
                                  onPressed: btnCancelOnPress,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: kPrimaryLightColor,
                                      border: Border.all(
                                          color: kTextGray, width: 0.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Center(
                                        child: Text(
                                          btnCancelText,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                ))
                              : Container(),
                          btnCancelText != null && btnOkText != null
                              ? SizedBox(width: 10)
                              : SizedBox(width: 0),
                          btnOkText != null
                              ? Expanded(
                                  child: ScaleTap(
                                  onPressed: btnOkOnPress,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: kPrimaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Center(
                                          child: Text(
                                        btnOkText,
                                        style: TextStyle(color: Colors.white),
                                      )),
                                    ),
                                  ),
                                ))
                              : Container(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }
}
