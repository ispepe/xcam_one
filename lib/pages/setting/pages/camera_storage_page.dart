/*
 * Copyright (c) 2021. Jingpei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 *  https://jingpei.tech
 *  https://jin.dev
 *
 *  Created by Pepe
 */

import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import 'package:provider/provider.dart';
import 'package:xcam_one/models/cmd_status_value_entity.dart';
import 'package:xcam_one/net/dio_utils.dart';
import 'package:xcam_one/net/net.dart';

import 'package:xcam_one/notifiers/camera_state.dart';
import 'package:xcam_one/res/resources.dart';
import 'package:xcam_one/routers/fluro_navigator.dart';

class CameraStoragePage extends StatefulWidget {
  @override
  _CameraStoragePageState createState() => _CameraStoragePageState();
}

class _CameraStoragePageState extends State<CameraStoragePage> {
  late CameraState _cameraState;

  int? freeCaptureNum;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _cameraState.diskSpaceCheck();
      DioUtils.instance.requestNetwork<CmdStatusValueEntity>(
          Method.get, HttpApi.freeCaptureNum,
          onSuccess: (cmdStatusValueEntity) {
        if (cmdStatusValueEntity?.function?.status == 0) {
          setState(() {
            freeCaptureNum = cmdStatusValueEntity?.function?.value;
          });
        }
      }, onError: (code, message) {
        showToast('获取可拍摄张数错误');
        debugPrint('code: $code, message: $message');
      });
    });

    /// 检测硬盘空间

    /// 检测可拍摄数量
  }

  @override
  Widget build(BuildContext context) {
    _cameraState = context.read<CameraState>();
    final width = MediaQuery.of(context).size.width - 16 * 2;
    final greyColor = Color(0xFFF2F2F2);
    return Scaffold(
      backgroundColor: greyColor,
      appBar: AppBar(
        title: Text('相机存储'),
        centerTitle: true,
        leading: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => NavigatorUtils.goBack(context),
          child: Icon(
            Icons.arrow_back_ios,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 12),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/camera_storage.png',
                      width: 64,
                      height: 64,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '存储空间',
                            style: TextStyles.textLight28
                                .copyWith(color: Color(0xFF2E2E2E)),
                          ),
                          Text(
                            '已使用${_cameraState.useSpace}/共${_cameraState.diskSpace}',
                            style: TextStyles.textSize12
                                .copyWith(color: Color(0xFFBFBFBF)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Container(
                  width: width,
                  height: 4,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                      color: greyColor,
                      borderRadius: BorderRadius.all(Radius.circular(3))),
                  child: Container(
                    width: width *
                        (_cameraState.freeSpaceData /
                            _cameraState.diskSpaceData),
                    decoration: BoxDecoration(
                        color: Theme.of(context).accentColor,
                        borderRadius: BorderRadius.all(Radius.circular(3))),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).accentColor,
                        borderRadius: BorderRadius.circular(2),
                        shape: BoxShape.rectangle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text('可用空间'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 26.0),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: greyColor,
                          borderRadius: BorderRadius.circular(2),
                          shape: BoxShape.rectangle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text('已用空间'),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: freeCaptureNum != null
                    ? Text(
                        '预计可拍$freeCaptureNum张全景图片',
                        style:
                            TextStyles.textBold12.copyWith(color: Colors.black),
                      )
                    : SizedBox(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
