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
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:intl/intl.dart';

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

  late GlobalState globalState;

  @override
  void initState() {
    super.initState();
    _photoIndex = widget.currentIndex;
    pageController = PageController(initialPage: widget.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    globalState = context.read<GlobalState>();
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => NavigatorUtils.goBack(context),
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                context: context,
                builder: (BuildContext context) {
                  final format = DateFormat('yyyy/MM/dd hh:mm:ss');
                  final entity = globalState.photos[_photoIndex];
                  final line = Divider(color: Color(0xFFF5F5F5));
                  final valueColor = Color(0xFFBFBFBF);
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
                                    .copyWith(color: Colors.black),
                              ),
                              GestureDetector(
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
                                style: TextStyles.textSize14
                                    .copyWith(color: Colors.black),
                              ),
                              Text(
                                entity.title!,
                                style: TextStyles.textSize14
                                    .copyWith(color: valueColor),
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
                                    .copyWith(color: Colors.black),
                              ),
                              Text(
                                format.format(entity.createDateTime),
                                style: TextStyles.textSize14
                                    .copyWith(color: valueColor),
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
                                    .copyWith(color: Colors.black),
                              ),
                              Text(
                                '${entity.width}x${entity.height}',
                                style: TextStyles.textSize14
                                    .copyWith(color: valueColor),
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
                                    .copyWith(color: Colors.black),
                              ),
                              Text(
                                '$_currentImageSize',
                                style: TextStyles.textSize14
                                    .copyWith(color: valueColor),
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
                'assets/images/more_back.png',
                width: 32,
                height: 32,
              ),
            ),
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  PageView _buildBody() {
    return PageView.builder(
      controller: pageController,
      itemCount: globalState.photos.length,
      physics: const BouncingScrollPhysics(),
      onPageChanged: onPageChanged,
      itemBuilder: (BuildContext context, int index) {
        /// TODO: 4/12/21 待处理 图片需要做缓存
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
              fit: BoxFit.contain,
            );
          },
        );
      },
    );
  }

  void onPageChanged(int index) {
    debugPrint('index = $index');
    _photoIndex = index;
  }
}
