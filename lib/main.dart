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
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:oktoast/oktoast.dart';
import 'package:xcam_one/generated/l10n.dart';
import 'package:xcam_one/notifiers/camera_state.dart';
import 'package:xcam_one/notifiers/locale_state.dart';
import 'package:xcam_one/notifiers/photo_state.dart';

import 'package:xcam_one/pages/splash.dart';
import 'package:xcam_one/routers/page_not_found.dart';
import 'package:xcam_one/routers/routers.dart';
import 'package:xcam_one/utils/log_utils.dart';

import 'notifiers/global_state.dart';
import 'notifiers/theme_state.dart';

void main() async {
  Provider.debugCheckInvalidValueType = null;

  /// Flutter 1.12
  WidgetsFlutterBinding.ensureInitialized();

  /// TODO：加载证书，用于aboutDialog license使用
  LicenseRegistry.reset();
  LicenseRegistry.addLicense(() async* {
//    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    final license = '我是一个免责声明';
    yield LicenseEntryWithLineBreaks(
      ['协议'],
      license,
    );
  });

  runApp(_MyApp());

  // Android状态栏透明 splash为白色,所以调整状态栏文字为黑色
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light));
}

class _MyApp extends StatefulWidget {
  @override
  __MyAppState createState() => __MyAppState();
}

class __MyAppState extends State<_MyApp> {
  final ThemeState _themeState = ThemeState();

  final LocaleState _localeState = LocaleState();

  final GlobalState _globalState = GlobalState();

  @override
  void initState() {
    super.initState();

    Log.init();
    Routes.configureRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      /// Toast 配置
      backgroundColor: Colors.black54,
      textPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      radius: 20.0,
      position: ToastPosition.center,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: _themeState),
          ChangeNotifierProvider.value(value: _localeState),
          ChangeNotifierProvider.value(value: _globalState),
          ChangeNotifierProvider(
            create: (_) => CameraState(),
          ),
          ChangeNotifierProvider(
            create: (_) => PhotoState(),
          ),
        ],
        child: Consumer2<ThemeState, LocaleState>(builder:
            (BuildContext context, ThemeState themeState,
                LocaleState localeState, Widget? child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'xCam One',
            theme: themeState.themeData(),
            darkTheme: themeState.themeData(isDarkMode: true),
            themeMode: ThemeMode.light,
            // themeState.getThemeMode(),
            localizationsDelegates: [
              GlobalCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate
            ],
            locale: localeState.locale,
            supportedLocales: S.delegate.supportedLocales,
            home: SplashPage(),
            onGenerateRoute: Routes.router?.generator,
            onUnknownRoute: (_) {
              /// 因为使用了fluro，这里设置主要针对Web
              return MaterialPageRoute(
                builder: (BuildContext context) => PageNotFound(),
              );
            },
          );
        }),
      ),
    );
  }
}
