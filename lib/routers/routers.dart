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
import 'package:xcam_one/pages/index/index_router.dart';
import 'package:xcam_one/pages/photo_view/photo_view_router.dart';
import 'package:xcam_one/pages/setting/setting_router.dart';
import 'package:xcam_one/pages/welcome/welcome_router.dart';
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
      return WebViewPage(
        title: title,
        url: url,
        key: null,
      );
    }));

    _listRouter.clear();

    _listRouter.add(IndexRouter());
    _listRouter.add(WelcomeRouter());
    _listRouter.add(PhotoViewRouter());
    _listRouter.add(SettingRouter());

    /// NOTE: 3/29/21 异步是否有影响？
    _listRouter.forEach((routerProvider) {
      routerProvider.initRouter(router);
    });

    Routes.router = router;
  }
}
