/*
 * Copyright (c) 2021 Jing Pei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 * https://jingpei.tech
 * https://jin.dev
 *
 * Created by Angus
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:xcam_one/pages/index/index_router.dart';
import 'package:xcam_one/res/resources.dart';
import 'package:xcam_one/routers/fluro_navigator.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

enum EGuide { app_start_1, app_start_2, app_start_3 }

extension EGuideExtension on EGuide {
  String get image => [
        'assets/images/app_start_1.png',
        'assets/images/app_start_2.png',
        'assets/images/app_start_3.png'
      ][index];

  String get title => ['打开相机', '连接相机', '选择网络'][index];

  String get subTitle => [
        '短按相机电源键开启相机',
        '点击‘去连接’按钮，连接全景相机',
        '在WiFi设置中选择并连接以‘HTF’开头的WiFi默认密码为12345678'
      ][index];

  String get buttonText => ['下一步', '下一步', '去连接'][index];

  String get nextText => ['跳过', '上一步', '上一步'][index];
}

class _WelcomePageState extends State<WelcomePage> {
  EGuide currentEGuide = EGuide.app_start_1;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Container(
              height: size.height,
              width: size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      currentEGuide.title,
                      style: TextStyles.textBold28
                          .copyWith(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 25),
                    child: Text(currentEGuide.subTitle,
                        textAlign: TextAlign.center,
                        style: TextStyles.textMedium18
                            .copyWith(color: Color(0xFF888888))),
                  ),
                  Container(
                    height: size.height * 0.8,
                    child: FadeInImage(
                      image: AssetImage(currentEGuide.image),
                      placeholder: MemoryImage(kTransparentImage),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Container(
                  color: Colors.white,
                  width: size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: MaterialButton(
                          minWidth: 248,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            if (currentEGuide.index ==
                                EGuide.values.length - 1) {
                              NavigatorUtils.push(
                                  context, IndexRouter.indexPage,
                                  clearStack: true);
                            } else {
                              currentEGuide =
                                  EGuide.values[currentEGuide.index + 1];

                              setState(() {});
                            }
                          },
                          child: Text(
                            currentEGuide.buttonText,
                            style: TextStyles.textBold16
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: TextButton(
                            onPressed: () {
                              if (currentEGuide.index == 0) {
                                NavigatorUtils.push(
                                    context, IndexRouter.indexPage,
                                    clearStack: true);
                              } else {
                                setState(() {
                                  currentEGuide =
                                      EGuide.values[currentEGuide.index - 1];
                                });
                              }
                            },
                            child: Text(
                              currentEGuide.nextText,
                              style: TextStyles.textBold14
                                  .copyWith(color: Color(0xFFAFAFAF)),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildProgressClipOval(
                                  EGuide.app_start_1.index),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildProgressClipOval(
                                  EGuide.app_start_2.index),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildProgressClipOval(
                                  EGuide.app_start_3.index),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  ClipOval _buildProgressClipOval(int value) {
    return ClipOval(
      child: Container(
        height: 7,
        width: 7,
        color: currentEGuide.index == value
            ? Theme.of(context).primaryColor
            : Colors.black26,
      ),
    );
  }
}
