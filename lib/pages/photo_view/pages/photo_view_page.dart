/*
 * Copyright (c) 2021. Jingpei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 *  https://jingpei.tech
 *  https://jin.dev
 *
 *  Created by Pepe
 */

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:xcam_one/notifiers/global_state.dart';
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

  String _currentImageSize = '0k';

  @override
  void initState() {
    super.initState();
    _photoIndex = widget.currentIndex;
    pageController = PageController(initialPage: widget.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final line = Divider(color: Color(0xFF545458).withOpacity(0.65));
    final globalState = context.read<GlobalState>();

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => NavigatorUtils.goBack(context),
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black45,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () {
              /// TODO: 4/4/21 待处理
              showModalBottomSheet(
                backgroundColor: Colors.black54,
                context: context,
                builder: (BuildContext context) {
                  final entity = globalState.photos[_photoIndex];
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
                                style: TextStyles.textSize14
                                    .copyWith(color: Colors.white),
                              ),
                              GestureDetector(
                                onTap: () {
                                  NavigatorUtils.goBack(context);
                                },
                                child: Icon(
                                  Icons.close_outlined,
                                  color: Colors.white,
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
                                style: TextStyles.textSize14
                                    .copyWith(color: Colors.white),
                              ),
                              Text(
                                entity.title!,
                                style: TextStyles.textSize14
                                    .copyWith(color: Color(0xFFBFBFBF)),
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
                                style: TextStyles.textSize14
                                    .copyWith(color: Colors.white),
                              ),
                              Text(
                                entity.createDateTime.toString(),
                                style: TextStyles.textSize14
                                    .copyWith(color: Color(0xFFBFBFBF)),
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
                                style: TextStyles.textSize14
                                    .copyWith(color: Colors.white),
                              ),
                              Text(
                                '${entity.width}x${entity.height}',
                                style: TextStyles.textSize14
                                    .copyWith(color: Color(0xFFBFBFBF)),
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
                                style: TextStyles.textSize14
                                    .copyWith(color: Colors.white),
                              ),
                              Text(
                                '$_currentImageSize',
                                style: TextStyles.textSize14
                                    .copyWith(color: Color(0xFFBFBFBF)),
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
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Image.asset(
                'assets/images/more.png',
                width: 32,
                height: 32,
              ),
            ),
          )
        ],
      ),
      body: PageView.builder(
        controller: pageController,
        itemCount: globalState.photos.length,
        physics: const BouncingScrollPhysics(),
        onPageChanged: onPageChanged,
        itemBuilder: (BuildContext context, int index) {
          final globalState = context.read<GlobalState>();
          return FutureBuilder<Uint8List?>(
            future: globalState.photos[index].originBytes,
            builder: (_, s) {
              if (!s.hasData) {
                return Container();
              }

              final int length = s.data!.length;

              _currentImageSize = (length / 1024) > 1024
                  ? '${(length / 1024 / 1024).toStringAsFixed(2)}M'
                  : '${(length / 1024).toStringAsFixed(2)}KB';

              return FadeInImage(
                placeholder: MemoryImage(kTransparentImage),
                image: MemoryImage(s.data!),
              );
            },
          );
        },
      ),
    );
  }

  void onPageChanged(int index) {
    debugPrint('index = $index');
    _photoIndex = index;
  }
}
