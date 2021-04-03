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

class MyButton extends StatelessWidget {
  const MyButton({
    Key? key,
    required this.minWidth,
    required this.onPressed,
    required this.buttonText,
    this.vertical = 11.0,
  }) : super(key: key);

  final double minWidth;
  final Null Function() onPressed;
  final String buttonText;
  final double vertical;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: minWidth,
      padding: EdgeInsets.symmetric(vertical: vertical),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      color: Theme.of(context).buttonColor,
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: TextStyles.textBold16.copyWith(color: Colors.white),
      ),
    );
  }
}
