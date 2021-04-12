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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:xcam_one/models/camera_file_entity.dart';
import 'package:xcam_one/net/net.dart';
import 'package:xcam_one/notifiers/global_state.dart';
import 'package:xcam_one/res/resources.dart';
import 'package:xcam_one/routers/fluro_navigator.dart';

class CameraViewPage extends StatefulWidget {
  const CameraViewPage({Key? key, required this.currentIndex})
      : super(key: key);

  final int currentIndex;

  @override
  _CameraViewPageState createState() => _CameraViewPageState();
}

class _CameraViewPageState extends State<CameraViewPage> {
  PageController? pageController;

  late int _photoIndex;

  late GlobalState globalState;

  @override
  void initState() {
    super.initState();
    _photoIndex = widget.currentIndex;
    pageController = PageController(initialPage: widget.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final line = Divider(color: Color(0xFF545458).withOpacity(0.65));
    globalState = context.read<GlobalState>();

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
              showModalBottomSheet(
                backgroundColor: Colors.black54,
                context: context,
                builder: (BuildContext context) {
                  final CameraFileInfo entity =
                      globalState.allFile![_photoIndex].file!;
                  final int length = int.parse(entity.size!);

                  final String _currentImageSize = (length / 1024) > 1024
                      ? '${(length / 1024 / 1024).toStringAsFixed(2)}M'
                      : '${(length / 1024).toStringAsFixed(2)}KB';

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
                                entity.name!,
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
                                entity.time.toString(),
                                style: TextStyles.textSize14
                                    .copyWith(color: Color(0xFFBFBFBF)),
                              ),
                            ],
                          ),
                        ),
                        line,

                        /// NOTE: 4/12/21 待注意 FW说固定即可
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
                                '4608x3456',
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
      body: _buildBody(),
    );
  }

  PageView _buildBody() {
    return PageView.builder(
      controller: pageController,
      itemCount: globalState.allFile?.length,
      physics: const BouncingScrollPhysics(),
      onPageChanged: onPageChanged,
      itemBuilder: (BuildContext context, int index) {
        String filePath = globalState.allFile![index].file!.filePath!;
        filePath = filePath.substring(3, filePath.length);
        filePath = filePath.replaceAll('\\', '/');
        final url = 'http://192.168.1.254/$filePath${HttpApi.getScreennail}';

        return CachedNetworkImage(
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
          placeholder: (BuildContext context, url) {
            return Center(
                child: SpinKitCircle(
              color: Theme.of(context).accentColor,
              size: 24,
            ));
          },
          errorWidget: (context, url, error) => Icon(Icons.photo_outlined),
          imageUrl: Uri.encodeFull(url),
        );
      },
    );
  }

  void onPageChanged(int index) {
    debugPrint('index = $index');
    _photoIndex = index;
  }
}