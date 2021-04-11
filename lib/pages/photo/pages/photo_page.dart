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
import 'package:xcam_one/pages/photo/pages/camera_photo_page.dart';
import 'package:xcam_one/pages/photo/pages/phone_photo_page.dart';
import 'package:xcam_one/res/resources.dart';

// Photo album
class PhotoPage extends StatefulWidget {
  @override
  _PhotoPageState createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage>
    with AutomaticKeepAliveClientMixin {
  final _phonePhotoPage = PhonePhotoPage();
  final _cameraPhotoPage = CameraPhotoPage();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: TabBar(
            indicatorColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Color(0xFF999999),
            labelColor: Theme.of(context).primaryColor,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle:
                TextStyles.textSize16.copyWith(fontWeight: FontWeight.w500),
            indicatorWeight: 4,
            tabs: [
              Tab(
                text: '手机',
              ),
              Tab(
                text: '相机',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [_phonePhotoPage, _cameraPhotoPage],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
