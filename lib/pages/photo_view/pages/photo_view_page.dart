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
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:xcam_one/res/resources.dart';
import 'package:xcam_one/routers/fluro_navigator.dart';

class PhotoViewGalleryOptions {
  PhotoViewGalleryOptions(this.image, this.tag);

  PhotoViewGalleryOptions.fromJson(Map<dynamic, dynamic> json)
      : image = json['image'],
        tag = json['tag'];

  String? image;
  String? tag;

  Map toJson() {
    return {'image': image, 'tag': tag};
  }
}

class PhotoViewPage extends StatefulWidget {
  const PhotoViewPage({Key? key, required this.galleryItems}) : super(key: key);

  final List<PhotoViewGalleryOptions> galleryItems;

  @override
  _PhotoViewPageState createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  PageController? pageController;

  @override
  void initState() {
    super.initState();
    // initialIndex
    pageController = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    final line = Divider(color: Color(0xFF545458).withOpacity(0.65));
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => NavigatorUtils.goBack(context),
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black45,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () {
              /// TODO: 4/4/21 待处理
              showModalBottomSheet(
                backgroundColor: Colors.black54,
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '详细信息',
                                style: TextStyles.textSize14
                                    .copyWith(color: Colors.white),
                              ),
                              GestureDetector(
                                onTap: () {
                                  NavigatorUtils.goBack(context);
                                },
                                child: Icon(
                                  Icons.close_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              )
                            ],
                          ),
                        ),
                        line,
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '文件名',
                                style: TextStyles.textSize14
                                    .copyWith(color: Colors.white),
                              ),
                              Text(
                                '8f4741b4eae85ee4871d034a1e51a44',
                                style: TextStyles.textSize14
                                    .copyWith(color: Color(0xFFBFBFBF)),
                              ),
                            ],
                          ),
                        ),
                        line,
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '拍摄时间',
                                style: TextStyles.textSize14
                                    .copyWith(color: Colors.white),
                              ),
                              Text(
                                '2021.03.20',
                                style: TextStyles.textSize14
                                    .copyWith(color: Color(0xFFBFBFBF)),
                              ),
                            ],
                          ),
                        ),
                        line,
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '分辨率',
                                style: TextStyles.textSize14
                                    .copyWith(color: Colors.white),
                              ),
                              Text(
                                '375x812',
                                style: TextStyles.textSize14
                                    .copyWith(color: Color(0xFFBFBFBF)),
                              ),
                            ],
                          ),
                        ),
                        line,
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '图片大小',
                                style: TextStyles.textSize14
                                    .copyWith(color: Colors.white),
                              ),
                              Text(
                                '12.96MB',
                                style: TextStyles.textSize14
                                    .copyWith(color: Color(0xFFBFBFBF)),
                              ),
                            ],
                          ),
                        ),
                        line,
                      ],
                    ),
                  );
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Image.asset(
                'assets/images/more.png',
                width: 32,
                height: 32,
              ),
            ),
          )
        ],
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.galleryItems.length,
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: AssetImage(widget.galleryItems[index].image!),
            initialScale: PhotoViewComputedScale.contained * 1,
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 1.2,
            heroAttributes:
                PhotoViewHeroAttributes(tag: widget.galleryItems[index].tag!),
          );
        },
        loadingBuilder: (context, progress) => Center(
          child: Container(
            width: 20.0,
            height: 20.0,
            // child: CircularProgressIndicator(
            //   value: _progress == null
            //       ? null
            //       : _progress.cumulativeBytesLoaded /
            //           _progress.expectedTotalBytes,
            // ),
          ),
        ),
        backgroundDecoration: const BoxDecoration(
          color: Colors.white,
        ),
        pageController: pageController,
        onPageChanged: onPageChanged,
      ),
    );
  }

  void onPageChanged(int index) {
    debugPrint('index = $index');
  }
}
