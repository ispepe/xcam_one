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

import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:xcam_one/res/styles.dart';
import 'package:xcam_one/widgets/my_button.dart';

class CameraPhotoPage extends StatefulWidget {
  @override
  _CameraPhotoPageState createState() => _CameraPhotoPageState();
}

class _CameraPhotoPageState extends State<CameraPhotoPage> {
  @override
  Widget build(BuildContext context) {
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
                    minWidth: 248, onPressed: () {}, buttonText: '去连接'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
