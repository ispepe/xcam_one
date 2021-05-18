/*
 * Copyright (c) 2021. Jingpei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 *  https://jingpei.tech
 *  https://jin.dev
 *
 *  Created by Pepe
 */

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:panorama/panorama.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:intl/intl.dart';

import 'package:xcam_one/notifiers/global_state.dart';
import 'package:xcam_one/notifiers/photo_state.dart';
import 'package:xcam_one/res/resources.dart';
import 'package:xcam_one/routers/fluro_navigator.dart';

class PhotoViewPage extends StatefulWidget {
  const PhotoViewPage({Key? key, required this.currentIndex}) : super(key: key);

  final int currentIndex;

  @override
  _PhotoViewPageState createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  PageController? pageController;

  late int _photoIndex;

  late PhotoState photoState;

  int _dataLength = 0;

  bool _isShowBack = false;

  /// 是否显示全景图
  bool _isShowPanorama = false;

  @override
  void initState() {
    super.initState();
    _photoIndex = widget.currentIndex;
    pageController = PageController(initialPage: widget.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    photoState = context.read<PhotoState>();

    return Scaffold(
      appBar: _isShowBack
          ? null
          : AppBar(
              leading: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => NavigatorUtils.goBack(context),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
              ),
              elevation: 0.0,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: GestureDetector(
                    onTap: () {
                      _showModalBottomSheet(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Image.asset(
                        'assets/images/more_back.png',
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        _isShowPanorama = !_isShowPanorama;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _isShowPanorama
                          ? Icon(
                              Icons.image_outlined,
                              size: 24,
                            )
                          : Icon(
                              Icons.threed_rotation_outlined,
                              size: 24,
                            ),
                    ),
                  ),
                )
              ],
            ),
      body: _buildBody(context),
    );
  }

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      context: context,
      builder: (BuildContext context) {
        final format = DateFormat('yyyy/MM/dd hh:mm:ss');
        final entity = photoState.photos[_photoIndex];
        final line = Divider(color: Color(0xFFF5F5F5));
        final valueColor = Color(0xFFBFBFBF);
        final String imageSize = (_dataLength / 1024) > 1024
            ? '${(_dataLength / 1024 / 1024).toStringAsFixed(2)}M'
            : '${(_dataLength / 1024).toStringAsFixed(2)}KB';

        return Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '详细信息',
                      style:
                          TextStyles.textSize14.copyWith(color: Colors.black),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        NavigatorUtils.goBack(context);
                      },
                      child: Icon(
                        Icons.close_outlined,
                        color: Colors.black,
                        size: 24,
                      ),
                    )
                  ],
                ),
              ),
              line,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '文件名',
                      style:
                          TextStyles.textSize14.copyWith(color: Colors.black),
                    ),
                    Text(
                      entity.title!,
                      style: TextStyles.textSize14.copyWith(color: valueColor),
                    ),
                  ],
                ),
              ),
              line,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '拍摄时间',
                      style:
                          TextStyles.textSize14.copyWith(color: Colors.black),
                    ),
                    Text(
                      format.format(entity.createDateTime),
                      style: TextStyles.textSize14.copyWith(color: valueColor),
                    ),
                  ],
                ),
              ),
              line,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '分辨率',
                      style:
                          TextStyles.textSize14.copyWith(color: Colors.black),
                    ),
                    Text(
                      '${entity.width}x${entity.height}',
                      style: TextStyles.textSize14.copyWith(color: valueColor),
                    ),
                  ],
                ),
              ),
              line,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '图片大小',
                      style:
                          TextStyles.textSize14.copyWith(color: Colors.black),
                    ),
                    Text(
                      '$imageSize',
                      style: TextStyles.textSize14.copyWith(color: valueColor),
                    ),
                  ],
                ),
              ),
              line,
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bgColor = Color(0xFFF2F2F2);
    if (_isShowPanorama) {
      return FutureBuilder<Uint8List?>(
        future: photoState.photos[_photoIndex].originBytes,
        builder: (_, s) {
          if (!s.hasData) {
            return Center(
                child: SpinKitCircle(
              color: Theme.of(context).primaryColor,
              size: 32,
            ));
          }

          _dataLength = s.data!.length;
          return Panorama(
            animSpeed: 1.0,
            minZoom: .5,
            sensitivity: 2,
            sensorControl: SensorControl.Orientation,
            child: Image(
              width: double.infinity,
              height: double.infinity,
              image: MemoryImage(s.data!),
              gaplessPlayback: true,
              fit: BoxFit.contain,
            ),
          );
        },
      );
    } else {
      return Container(
        width: size.width,
        height: size.height,
        color: _isShowBack ? Colors.black : bgColor,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isShowBack = !_isShowBack;
            });
          },
          child: PhotoViewGallery.builder(
            pageController: pageController,
            itemCount: photoState.photos.length,
            scrollPhysics: const BouncingScrollPhysics(),
            onPageChanged: onPageChanged,
            backgroundDecoration: BoxDecoration(
              color: _isShowBack ? Colors.black : bgColor,
            ),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions.customChild(
                child: FutureBuilder<Uint8List?>(
                  future: photoState.photos[index].originBytes,
                  builder: (_, s) {
                    if (!s.hasData) {
                      return Center(
                          child: SpinKitCircle(
                        color: Theme.of(context).primaryColor,
                        size: 32,
                      ));
                    }

                    _dataLength = s.data!.length;

                    return Image(
                      width: double.infinity,
                      height: double.infinity,
                      image: MemoryImage(s.data!),
                      gaplessPlayback: true,
                      fit: BoxFit.contain,
                    );
                  },
                ),
              );
            },
          ),
        ),
      );
    }
  }

  void onPageChanged(int index) {
    debugPrint('index = $index');
    _photoIndex = index;
  }
}
