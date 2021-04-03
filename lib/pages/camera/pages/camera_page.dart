/*
 * Copyright (c) 2021. Jingpei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 *  https://jingpei.tech
 *  https://jin.dev
 *
 *  Created by Pepe
 */
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:xcam_one/pages/photo_view/pages/photo_view_page.dart';
import 'package:xcam_one/pages/photo_view/photo_view_router.dart';
import 'package:xcam_one/res/resources.dart';
import 'package:xcam_one/routers/fluro_navigator.dart';
import 'package:xcam_one/widgets/my_button.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({
    Key? key,
  }) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final size = MediaQuery.of(context).size;
    final imageHeight = 283 * size.width / 375;
    return Scaffold(
      appBar: AppBar(
        title: Text('连接相机'),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size.width,
              height: imageHeight,
              child: FadeInImage(
                image: AssetImage('assets/images/main_wifi.png'),
                placeholder: MemoryImage(kTransparentImage),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 31),
              child: Text(
                'Wi-Fi密码：12345678',
                style: TextStyles.textBold18.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                '相机开机后，在手机Wi-Fi列表中点击“HTF”开头的相机WiFi进行连接，默认密码：12345678',
                style: TextStyles.textSize12,
                textAlign: TextAlign.center,
              ),
            ),
            MyButton(
                minWidth: 248,
                onPressed: () {
                  final image = "assets/images/IMG_4440.JPG";
                  NavigatorUtils.push(
                    context,
                    '${PhotoViewRouter.photoView}?galleryItems=${Uri.encodeComponent(convert.jsonEncode(
                      PhotoViewGalleryOptions(image, 'tag1').toJson(),
                    ))}&galleryItems=${Uri.encodeComponent(convert.jsonEncode(
                      PhotoViewGalleryOptions(image, 'tag2').toJson(),
                    ))}&galleryItems=${Uri.encodeComponent(convert.jsonEncode(
                      PhotoViewGalleryOptions(image, 'tag3').toJson(),
                    ))}',
                  );
                },
                buttonText: '去连接'),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
