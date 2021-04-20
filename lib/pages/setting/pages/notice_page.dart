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
import 'package:xcam_one/res/resources.dart';
import 'package:xcam_one/routers/fluro_navigator.dart';

class NoticePage extends StatefulWidget {
  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  @override
  void initState() {
    super.initState();

    /// TODO: 4/20/21 待处理 通知页面
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final greyColor = Color(0xFFF2F2F2);
    return Scaffold(
      backgroundColor: greyColor,
      appBar: AppBar(
        title: Text('通知'),
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
          padding: const EdgeInsets.only(left: 16, right: 16),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                height: 60,
                color: Colors.white,
                width: width,
                child: Text(
                  '没有更多通知',
                  style:
                      TextStyles.textSize16.copyWith(color: Color(0xFFBFBFBF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
