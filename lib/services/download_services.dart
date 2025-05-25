import 'dart:io';
import 'package:background_downloader/background_downloader.dart';
import 'package:ducky/utils/value_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadServices {
  static Future<bool> download({required String file}) async {
    bool statusProgress = false;

    await Permission.manageExternalStorage.request();

    final Directory doc = await getApplicationDocumentsDirectory();

    String pathParent = doc.path;

    Directory directory = Directory('$pathParent\\office');

    if (!await directory.exists()) {
      await directory.create();
    }

    String urlDownload =
        'https://raw.githubusercontent.com/Vinnybrunn00/test/refs/heads/main';

    final task = DownloadTask(
      url: '$urlDownload/$file',
      filename: file,
      requiresWiFi: true,
      directory: directory.path,
    );
    await FileDownloader().download(
      task,
      onProgress: (progress) {
        prog.value = progress;
      },
      onStatus: (status) {
        statusProgress = status.isFinalState;
      },
    );
    return statusProgress;
  }
}
