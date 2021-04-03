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
import 'package:transparent_image/transparent_image.dart';
import 'package:xcam_one/pages/camera/pages/camera_page.dart';
import 'package:xcam_one/pages/photo/pages/photo_page.dart';
import 'package:xcam_one/pages/setting/pages/setting_page.dart';
import 'package:xcam_one/res/resources.dart';
import 'package:xcam_one/widgets/my_button.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final List<BottomNavigationBarItem> bottomNavItems = [
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/photo.png',
        width: 32,
        height: 32,
      ),
      activeIcon: Image.asset(
        'assets/images/select_photo.png',
        width: 32,
        height: 32,
      ),
      label: "相册",
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/camera.png',
        width: 40,
        height: 40,
      ),
      label: '拍照',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/setting.png',
        width: 32,
        height: 32,
      ),
      activeIcon: Image.asset(
        'assets/images/select_setting.png',
        width: 32,
        height: 32,
      ),
      label: "设置",
    ),
  ];

  int _currentIndex = 0;

  final _pages = [PhotoPage(), CameraPage(), SettingPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: bottomNavItems,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          _changePage(index);
        },
      ),
    );
  }

  void _changePage(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }
}
