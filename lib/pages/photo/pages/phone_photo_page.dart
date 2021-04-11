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
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:xcam_one/notifiers/global_state.dart';

import 'package:xcam_one/pages/photo_view/pages/photo_view_page.dart';
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
      Provider.of<GlobalState>(context, listen: false)
          .refreshGalleryList()
          .then((value) {
        setState(() {
          _isShowLoading = false;
        });
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
    final size = MediaQuery.of(context).size;
    if (_isShowLoading) {
      return Container(
        height: size.height,
        width: size.width,
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
          return InkWell(
            onTap: () {
              NavigatorUtils.push(
                  context, '${PhotoViewRouter.photoView}?currentIndex=$index');
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
          child: Text('加载中...'),
        );
      },
    );
  }

  Future<void> showInfo(AssetEntity entity) async {
    if (entity.type == AssetType.video) {
      var file = await entity.file;
      if (file == null) {
        return;
      }
      var length = file.lengthSync();
      var size = entity.size;
      print(
        "${entity.id} length = $length, "
        "size = $size, "
        "dateTime = ${entity.createDateTime}",
      );
    } else {
      final Size size = entity.size;
      print("${entity.id} size = $size, dateTime = ${entity.createDateTime}");
    }
  }

  Widget _buildPhotoGroup(BuildContext context, GlobalState globalState,
      String key, int groupIndex) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(12.0),
          alignment: Alignment.centerLeft,
          child: Text(
            key,
            style: TextStyles.textBold16.copyWith(color: Colors.black),
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
