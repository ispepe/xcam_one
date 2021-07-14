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

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:xcam_one/global/constants.dart';
import 'package:xcam_one/global/global_store.dart';
import 'package:xcam_one/net/intercept.dart';
import 'package:xcam_one/net/net.dart';
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
      _initDio();

      /// 保存当前临时目录和文档目录
      final Directory tempDir = await getTemporaryDirectory();
      GlobalStore.tempPath = tempDir.path;

      final Directory applicationDir = await getApplicationDocumentsDirectory();
      GlobalStore.applicationPath = applicationDir.path;

      if (GlobalStore.first) {
        /// 进入欢迎页面
        NavigatorUtils.push(context, WelcomeRouter.welcomePage,
            clearStack: true);
      } else {
        NavigatorUtils.push(context, IndexRouter.indexPage, clearStack: true);
      }
    });
  }

  void _initDio() {
    final List<Interceptor> interceptors = [];

    /// 统一添加身份验证请求头
    // interceptors.add(AuthInterceptor());

    /// 刷新Token
    // interceptors.add(TokenInterceptor());

    /// 打印Log(生产模式去除)
    if (!Constant.inProduction) {
      interceptors.add(LoggingInterceptor());
    }

    /// 适配数据(根据自己的数据结构，可自行选择添加)
    interceptors.add(AdapterInterceptor());

    setInitDio(
      baseUrl: GlobalStore.config[EConfig.baseUrl],
      interceptors: interceptors,
    );
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
