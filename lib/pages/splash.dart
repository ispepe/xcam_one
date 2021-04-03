/*
 * Copyright (c) 2021. Jingpei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 *  https://jingpei.tech
 *  https://jin.dev
 *
 *  Created by Pepe
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:xcam_one/global/global_store.dart';
import 'package:xcam_one/pages/index/index_router.dart';
import 'package:xcam_one/pages/welcome/welcome_router.dart';

import 'package:xcam_one/res/resources.dart';
import 'package:xcam_one/routers/fluro_navigator.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    /// 预加载图片
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      /// 进行初始化操作
      await GlobalStore.init(!kReleaseMode);

      if (GlobalStore.first) {
        /// 进入欢迎页面
        NavigatorUtils.push(context, WelcomeRouter.welcomePage,
            clearStack: true);
      } else {
        NavigatorUtils.push(context, IndexRouter.indexPage, clearStack: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/splash_bg.png'),
                fit: BoxFit.cover)),
        alignment: Alignment.center,
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeInImage(
                image: AssetImage('assets/images/splash_logo.png'),
                placeholder: MemoryImage(kTransparentImage),
              ),
              Text(
                'xCam One',
                style: TextStyles.textBold26.copyWith(color: Colours.appMain),
              )
            ],
          ),
        ),
      ),
    );
  }
}
