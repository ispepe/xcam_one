/*
 * Copyright (c) 2021 Jing Pei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 * https://jingpei.tech
 * https://jin.dev
 *
 * Created by Angus
 */

import 'package:flutter/material.dart' hide Router;
import 'package:fluro/fluro.dart';
import 'package:xcam_one/routers/page_not_found.dart';
import 'package:xcam_one/routers/router_init.dart';
import 'package:xcam_one/widgets/webview_page.dart';

class Routes {
  static FluroRouter? router;

  static String webViewPage = '/webview';

  static final List<IRouterProvider> _listRouter = [];

  static void configureRoutes() {
    final FluroRouter router = FluroRouter();

    /// 指定路由跳转错误返回页
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      debugPrint('未找到目标页');
      return PageNotFound();
    });

    router.define(webViewPage, handler: Handler(handlerFunc: (_, params) {
      final String? title = params['title']?.first;
      final String? url = params['url']?.first;
      return WebViewPage(title: title, url: url, key: null,);
    }));

    _listRouter.clear();

    /// TODO: 各自路由由各自模块管理，统一在此添加初始化
    /// TODO: 看情况合并Page至对应页面
    // _listRouter.add(IndexRouter());
    // _listRouter.add(WelcomeRouter());

    /// 初始化路由
    _listRouter.forEach((routerProvider) {
      routerProvider.initRouter(router);
    });

    Routes.router = router;
  }
}
