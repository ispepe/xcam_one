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
import 'package:package_info/package_info.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:xcam_one/res/resources.dart';
import 'package:xcam_one/routers/fluro_navigator.dart';

class AppVersionPage extends StatefulWidget {
  @override
  _AppVersionPageState createState() => _AppVersionPageState();
}

class _AppVersionPageState extends State<AppVersionPage> {
  String version = '';
  String buildNumber = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      PackageInfo.fromPlatform().then((packageInfo) {
        setState(() {
          version = packageInfo.version;
          buildNumber = packageInfo.buildNumber;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final greyColor = Color(0xFFF2F2F2);
    return Scaffold(
      backgroundColor: greyColor,
      appBar: AppBar(
        title: Text('APP版本'),
        centerTitle: true,
        leading: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => NavigatorUtils.goBack(context),
          child: Container(
            // color: Colors.pink,
            child: Icon(
              Icons.arrow_back_ios,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 72),
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FadeInImage(
              image: AssetImage('assets/images/app_logo.png'),
              width: 64,
              height: 64,
              placeholder: MemoryImage(kTransparentImage),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                '当前版本 V$version.$buildNumber',
                style: TextStyles.textSize16.copyWith(color: Color(0xFFBFBFBF)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 46.0),
              child: TextButton(
                  onPressed: () {
                    /// TODO: 4/21/21 待处理 添加上架后的app store地址
                    /// TODO: 安卓弹窗在线升级对话框
                    showToast('暂时没有检测到新版本');
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    minimumSize: Size(width * 0.8, 46),
                    // padding: EdgeInsets.symmetric(vertical: 11),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  child: Text(
                    '版本更新',
                    style: TextStyles.textBold16.copyWith(color: Colors.black),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
