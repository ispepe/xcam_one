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
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'package:xcam_one/notifiers/photo_state.dart';
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
  late PhotoState _photoState;
  late PhotoState _watchPhotoState;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _photoState = context.read<PhotoState>();
    _watchPhotoState = context.watch<PhotoState>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: context.watch<PhotoState>().isMultipleSelect
              ? Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          if (_photoState.isAllSelect) {
                            _photoState.listSelect = [];
                          } else {
                            if (_photoState.allFile != null) {
                              _photoState.listSelect = List.generate(
                                  _photoState.allFile!.length,
                                  (index) => index);
                            }
                          }
                          _photoState.isAllSelect = !_photoState.isAllSelect;
                          await HapticFeedback.mediumImpact();
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          width: 70,
                          child: Text(
                            _watchPhotoState.isAllSelect ? '取消全选' : '全选',
                            style: TextStyles.textSize16,
                          ),
                        ),
                      ),
                      Expanded(
                          child: Center(
                              child:
                                  Text('选择照片', style: TextStyles.textSize16))),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          _photoState.isMultipleSelect = false;
                          _photoState.listSelect.clear();
                        },
                        child: Container(
                          alignment: Alignment.centerRight,
                          width: 70,
                          child: Text(
                            '完成',
                            style: TextStyles.textSize16.copyWith(
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : TabBar(
                  indicatorColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Color(0xFF999999),
                  labelColor: Theme.of(context).primaryColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: TextStyles.textSize16
                      .copyWith(fontWeight: FontWeight.w500),
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
