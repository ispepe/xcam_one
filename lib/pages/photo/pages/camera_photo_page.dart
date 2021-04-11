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

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:xcam_one/notifiers/global_state.dart';
import 'package:xcam_one/pages/photo_view/pages/photo_view_page.dart';
import 'package:xcam_one/pages/photo_view/photo_view_router.dart';

import 'package:xcam_one/res/styles.dart';
import 'package:xcam_one/routers/fluro_navigator.dart';
import 'package:xcam_one/widgets/my_button.dart';

class CameraPhotoPage extends StatefulWidget {
  @override
  _CameraPhotoPageState createState() => _CameraPhotoPageState();
}

class _CameraPhotoPageState extends State<CameraPhotoPage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final globalState = context.read<GlobalState>();
    if (globalState.isConnect) {
      return _buildCameraPhoto(context);
    } else {
      return _buildConnectCamera(context);
    }
  }

  Container _buildConnectCamera(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/images/camera_01.png',
                            width: 32,
                            height: 48,
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SpinKitThreeBounce(
                              color: Color(0xFFB3B3B3),
                              size: 24,
                            )),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/images/camera_02.png',
                            width: 48,
                            height: 38,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '未读取到任何数据 \n请连接相机',
                      textAlign: TextAlign.center,
                      style: TextStyles.textSize14
                          .copyWith(color: Color(0xFFBFBFBF)),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 140.0),
                child: MyButton(
                    minWidth: 248,
                    onPressed: () {
                      AppSettings.openWIFISettings();
                    },
                    buttonText: '去连接'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildCameraPhoto(BuildContext context) {
    super.build(context);
    final size = MediaQuery.of(context).size;

    final image = "assets/images/IMG_4440.JPG";

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('3月15日', style: TextStyles.textSize16),
                ),
                Container(
                  width: size.width,
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    runSpacing: 4,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // NavigatorUtils.push(
                          //   context,
                          //   '${PhotoViewRouter.photoView}?galleryItems=${Uri.encodeComponent(convert.jsonEncode(
                          //     PhotoViewGalleryOptions(image, 'tag1').toJson(),
                          //   ))}&galleryItems=${Uri.encodeComponent(convert.jsonEncode(
                          //     PhotoViewGalleryOptions(image, 'tag2').toJson(),
                          //   ))}&galleryItems=${Uri.encodeComponent(convert.jsonEncode(
                          //     PhotoViewGalleryOptions(image, 'tag3').toJson(),
                          //   ))}',
                          // );
                        },
                        child: _buildPhoto(image, size.width * 0.32),
                      ),
                      _buildPhoto(image, size.width * 0.32),
                      _buildPhoto(image, size.width * 0.32),
                      _buildPhoto(image, size.width * 0.32),
                      SizedBox(
                          width: size.width * 0.32, height: size.width * 0.32),
                      SizedBox(
                          width: size.width * 0.32, height: size.width * 0.32),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('3月14日', style: TextStyles.textSize16),
                ),
                Container(
                  width: size.width,
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    runSpacing: 4,
                    children: [
                      _buildPhoto(image, size.width * 0.32),
                      _buildPhoto(image, size.width * 0.32),
                      _buildPhoto(image, size.width * 0.32),
                      _buildPhoto(image, size.width * 0.32),
                      _buildPhoto(image, size.width * 0.32),
                      SizedBox(
                          width: size.width * 0.32, height: size.width * 0.32),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('3月13日', style: TextStyles.textSize16),
                ),
                Container(
                  width: size.width,
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    runSpacing: 4,
                    children: [
                      _buildPhoto(image, size.width * 0.32),
                      _buildPhoto(image, size.width * 0.32),
                      _buildPhoto(image, size.width * 0.32),
                      _buildPhoto(image, size.width * 0.32),
                      _buildPhoto(image, size.width * 0.32),
                      SizedBox(
                          width: size.width * 0.32, height: size.width * 0.32),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  FadeInImage _buildPhoto(String image, double size) {
    return FadeInImage(
      placeholder: MemoryImage(kTransparentImage),
      image: AssetImage(image),
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
  }
}
