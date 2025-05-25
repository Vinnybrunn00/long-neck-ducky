import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class AssetsUtils {
  static List<Map<String, dynamic>> iconsOffice = [
    {
      'title': 'Word',
      'file': 'assets/icons/word.png',
      'color': Color(0xFF3E43AD),
    },
    {
      'title': 'Excel',
      'file': 'assets/icons/excel.png',
      'color': Color(0xFF58AE57),
    },
    {
      'title': 'Power Point',
      'file': 'assets/icons/power_point.png',
      'color': Color(0xFFAE7E57),
    },
    {
      'title': 'Outlook',
      'file': 'assets/icons/outlook.png',
      'color': Color(0xFF577EAE),
    },
  ];
}

class Utils {
  static int get randomNumber {
    int max = 999999999;
    int min = 100000000;
    Random random = Random();
    var randomNumber = random.nextInt(max - min);
    return randomNumber;
  }

  static String get getTime {
    DateTime dateTime = DateTime.now();
    intl.DateFormat formatter = intl.DateFormat('yyyy-MM-dd HH:MM:ss');
    return formatter.format(dateTime);
  }

  static ScaffoldFeatureController showErrorMessageFloating({
    required BuildContext context,
    required String message,
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        width: MediaQuery.of(context).size.width * .6,
        content: Container(
          // height: 55,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF34384F),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.clip,
                ),
              ),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
    );
  }
}
