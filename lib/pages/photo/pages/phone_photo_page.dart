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
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:xcam_one/notifiers/global_state.dart';

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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      /// 先获取相机权限
      PhotoManager.requestPermission().then((value) {
        if (value) {
          Provider.of<GlobalState>(context, listen: false)
              .refreshGalleryList()
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
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    /// TODO: 4/14/21 待处理 增加下拉刷新
    final size = MediaQuery.of(context).size;
    if (_isShowLoading) {
      return Container(
        height: size.height,
        width: size.width,
        child: Center(
          child: SpinKitThreeBounce(
            color: Theme.of(context).accentColor,
            size: 48,
          ),
        ),
      );
    }

    final globalState = context.read<GlobalState>();

    return Container(
      child: ListView.builder(
        itemCount: globalState.photoGroup.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final keys = globalState.photoGroup.keys.toList();
          return _buildPhotoGroup(context, globalState, keys[index], index);
        },
      ),
    );
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
          color: Theme.of(context).accentColor,
          size: 24,
        ));
      },
    );
  }

  Widget _buildPhotoGroup(BuildContext context, GlobalState globalState,
      String key, int groupIndex) {
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
              itemCount: globalState.photoGroup[key]?.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemBuilder: (BuildContext context, int index) {
                int currentIndex = 0;
                final List<String> keys = globalState.photoGroup.keys.toList();
                for (int i = 0; i < keys.length; i++) {
                  if (keys[i].contains(key)) {
                    currentIndex += index;
                    break;
                  }
                  currentIndex += globalState.photoGroup[keys[i]]!.length;
                }

                return _buildPhoto(
                  context,
                  globalState.photoGroup[key]![index],
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
