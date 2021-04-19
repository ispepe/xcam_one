/*
 * Copyright (c) 2021. Jingpei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 *  https://jingpei.tech
 *  https://jin.dev
 *
 *  Created by Pepe
 */

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:xcam_one/notifiers/global_state.dart';
import 'package:xcam_one/notifiers/photo_state.dart';

import 'package:xcam_one/pages/photo_view/photo_view_router.dart';
import 'package:xcam_one/res/resources.dart';
import 'package:xcam_one/routers/fluro_navigator.dart';

class PhonePhotoPage extends StatefulWidget {
  @override
  _PhonePhotoPageState createState() => _PhonePhotoPageState();
}

class _PhonePhotoPageState extends State<PhonePhotoPage>
    with AutomaticKeepAliveClientMixin {
  bool _isShowLoading = true;

  late EasyRefreshController _refreshController;

  @override
  void initState() {
    super.initState();

    _refreshController = EasyRefreshController();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      /// 先获取相机权限
      _onRefresh();
    });
  }

  void _onRefresh() {
    /// 先获取相机权限
    PhotoManager.requestPermission().then((value) {
      if (value) {
        Provider.of<PhotoState>(context, listen: false)
            .refreshPhonePhoto()
            .then((value) {
          setState(() {
            _isShowLoading = false;
          });
        });
      } else {
        /// TODO: 4/14/21 待处理 如果相机没有权限，则先弹窗提醒再请求
        PhotoManager.openSetting();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final size = MediaQuery.of(context).size;
    if (_isShowLoading) {
      return Container(
        height: size.height,
        width: size.width,
        child: Center(
          child: SpinKitThreeBounce(
            color: Theme.of(context).primaryColor,
            size: 48,
          ),
        ),
      );
    }

    final photoState = context.read<PhotoState>();

    return Container(
        child: EasyRefresh(
      controller: _refreshController,
      // enableControlFinishRefresh: false,
      // enableControlFinishLoad: true,
      header: ClassicalHeader(
          refreshText: '下拉刷新',
          refreshReadyText: '松开刷新',
          refreshingText: '刷新中...',
          refreshedText: '刷新成功',
          refreshFailedText: '刷新失败',
          textColor: Theme.of(context).primaryColor,
          showInfo: false,
          infoText: '刷新时间 %T',
          infoColor: Theme.of(context).accentColor),
      footer: ClassicalFooter(
        noMoreText: '没有更多',
        loadFailedText: '加载失败',
        loadedText: '加载成功',
        loadingText: '加载中...',
        textColor: Theme.of(context).primaryColor,
        infoColor: Theme.of(context).accentColor,
        infoText: '加载时间 %T',
        showInfo: false,
      ),
      onRefresh: () async {
        _onRefresh();
        _refreshController.resetLoadState();
      },
      child: ListView.builder(
        itemCount: photoState.photoGroup.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final keys = photoState.photoGroup.keys.toList();
          return _buildPhotoGroup(context, photoState, keys[index], index);
        },
      ),
    ));
  }

  Widget _buildPhoto(BuildContext context, AssetEntity entity, int index) {
    return FutureBuilder<Uint8List?>(
      future: entity.thumbDataWithSize(256, 256),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return GestureDetector(
            onTap: () {
              NavigatorUtils.push(
                  context,
                  // ignore: lines_longer_than_80_chars
                  '${PhotoViewRouter.photoView}?currentIndex=$index&type=photo');
            },
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          );
        }

        return Center(
            child: SpinKitCircle(
          color: Theme.of(context).primaryColor,
          size: 24,
        ));
      },
    );
  }

  Widget _buildPhotoGroup(
      BuildContext context, PhotoState photoState, String key, int groupIndex) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text(
            key,
            style: TextStyles.textSize16.copyWith(color: Colors.black),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: photoState.photoGroup[key]?.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemBuilder: (BuildContext context, int index) {
                int currentIndex = 0;
                final List<String> keys = photoState.photoGroup.keys.toList();
                for (int i = 0; i < keys.length; i++) {
                  if (keys[i].contains(key)) {
                    currentIndex += index;
                    break;
                  }
                  currentIndex += photoState.photoGroup[keys[i]]!.length;
                }

                return _buildPhoto(
                  context,
                  photoState.photoGroup[key]![index],
                  currentIndex,
                );
              }),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
