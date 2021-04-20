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
import 'package:xcam_one/res/styles.dart';

Widget buildEmptyPhoto(BuildContext context, {required String text}) {
  return Container(
    padding: const EdgeInsets.only(top: 120),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/empty_photo.png',
            width: 108,
            height: 108,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 108),
              child: Text(text,
                  textAlign: TextAlign.center,
                  style:
                      TextStyles.textSize14.copyWith(color: Color(0xFFBFBFBF))),
            ),
          )
        ],
      ),
    ),
  );
}
