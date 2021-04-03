/*
 * Copyright (c) 2021. Jingpei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 *  https://jingpei.tech
 *  https://jin.dev
 *
 *  Created by Pepe
 */

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:xcam_one/res/resources.dart';

class PhonePhotoPage extends StatefulWidget {
  @override
  _PhonePhotoPageState createState() => _PhonePhotoPageState();
}

class _PhonePhotoPageState extends State<PhonePhotoPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final image = "assets/images/IMG_4440.JPG";

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('3月15日', style: TextStyles.textSize16),
                ),
                Container(
                  width: size.width,
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    runSpacing: 4,
                    children: [
                      _buildPhoto(image, size.width * 0.32),
                      _buildPhoto(image, size.width * 0.32),
                      _buildPhoto(image, size.width * 0.32),
                      _buildPhoto(image, size.width * 0.32),
                      SizedBox(
                          width: size.width * 0.32, height: size.width * 0.32),
                      SizedBox(
                          width: size.width * 0.32, height: size.width * 0.32),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('3月14日', style: TextStyles.textSize16),
                ),
                Container(
                  width: size.width,
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    runSpacing: 4,
                    children: [
                      _buildPhoto(image, size.width * 0.32),
                      _buildPhoto(image, size.width * 0.32),
                      _buildPhoto(image, size.width * 0.32),
                      _buildPhoto(image, size.width * 0.32),
                      _buildPhoto(image, size.width * 0.32),
                      SizedBox(
                          width: size.width * 0.32, height: size.width * 0.32),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('3月13日', style: TextStyles.textSize16),
                ),
                Container(
                  width: size.width,
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    runSpacing: 4,
                    children: [
                      _buildPhoto(image, size.width * 0.32),
                      _buildPhoto(image, size.width * 0.32),
                      _buildPhoto(image, size.width * 0.32),
                      _buildPhoto(image, size.width * 0.32),
                      _buildPhoto(image, size.width * 0.32),
                      SizedBox(
                          width: size.width * 0.32, height: size.width * 0.32),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  FadeInImage _buildPhoto(String image, double size) {
    return FadeInImage(
      placeholder: MemoryImage(kTransparentImage),
      image: AssetImage(image),
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
  }
}