import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ducky/utils/utils.dart';
import 'package:flutter/material.dart';

class DuckServices {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  Future<void> getHardware() async {
    //var test = await deviceInfo.windowsInfo;
    //var data = test.data;
    //log(data.toString());
  }

  String _replace(String hash) {
    String newHash1 = hash.replaceAll('{', '');
    return newHash1.replaceAll('}', '');
  }

  Future<void> sendInfoFirebase(BuildContext context) async {
    WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;

    Map<String, dynamic> data = windowsInfo.data;

    String replaced = _replace(data['deviceId'].toString());

    var get = await firestore.collection('info').get();

    for (var element in get.docs) {
      String deviceId = element['deviceId'].toString();

      if (deviceId == replaced) break;

      await firestore.collection('info').doc('${Utils.randomNumber}').set({
        'time': Utils.getTime,
        'computerName': data['computerName'],
        'systemMemoryInMegabytes': data['systemMemoryInMegabytes'],
        'userName': data['userName'],
        'digitalProductId': data['digitalProductId'],
        'displayVersion': data['displayVersion'],
        'installDate': data['installDate'],
        'productId': data['productId'],
        'productName': data['productName'],
        'registeredOwner': data['registeredOwner'],
        'releaseId': data['releaseId'],
        'deviceId': replaced,
      });
    }
  }
}
