import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:image_picker/image_picker.dart';

///sharing platform
enum Share {
  facebook,
  messenger,
  twitter,
  whatsapp,
  share_system,
  // share_instagram,
  share_telegram,
  email,
  sms,
  checkInstalled,
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File? file;
  ImagePicker picker = ImagePicker();
  bool videoEnable = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 30),
                // ElevatedButton(
                //   onPressed: pickImage,
                //   child: const Text('Pick Image'),
                // ),
                // ElevatedButton(
                //   onPressed: pickVideo,
                //   child: const Text('Pick Video'),
                // ),
                ElevatedButton(
                  onPressed: () => onButtonTap(Share.twitter),
                  child: const Text('share to twitter'),
                ),
                ElevatedButton(
                  onPressed: () => onButtonTap(Share.whatsapp),
                  child: const Text('share to WhatsApp'),
                ),
                ElevatedButton(
                  onPressed: () => onButtonTap(Share.facebook),
                  child: const Text('share to  FaceBook'),
                ),
                ElevatedButton(
                  onPressed: () => onButtonTap(Share.messenger),
                  child: const Text('share to  Messenger'),
                ),
                // ElevatedButton(
                //   onPressed: () => onButtonTap(Share.share_instagram),
                //   child: const Text('share to Instagram'),
                // ),
                ElevatedButton(
                  onPressed: () => onButtonTap(Share.share_telegram),
                  child: const Text('share to Telegram'),
                ),
                ElevatedButton(
                  onPressed: () => onButtonTap(Share.share_system),
                  child: const Text('share to System'),
                ),
                ElevatedButton(
                  onPressed: () => onButtonTap(Share.email),
                  child: const Text('share to email'),
                ),
                ElevatedButton(
                  onPressed: () => onButtonTap(Share.sms),
                  child: const Text('share to sms'),
                ),
                ElevatedButton(
                  onPressed: () => onButtonTap(Share.checkInstalled),
                  child: const Text('Check Installed'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    final XFile? xFile = await picker.pickImage(source: ImageSource.gallery);
    print(xFile);
    if (xFile != null) {
      file = File(xFile.path);
      setState(() {
        videoEnable = false;
      });
    }
  }

  Future<void> pickVideo() async {
    final XFile? xFile = await picker.pickVideo(source: ImageSource.gallery);
    print(xFile);
    if (xFile != null) {
      file = File(xFile.path);
      setState(() {
        videoEnable = true;
      });
    }
  }

  Future<void> onButtonTap(Share share) async {
    String msg =
        'Flutter share is great!!\n Check out full example at https://pub.dev/packages/flutter_share_me';
    String url = 'https://pub.dev/packages/flutter_share_me';

    String? response;
    final FlutterShareMe flutterShareMe = FlutterShareMe();
    switch (share) {
      case Share.facebook:
        response = await flutterShareMe.shareToFacebook(url: url, msg: msg);
        break;
      case Share.messenger:
        response = await flutterShareMe.shareToMessenger(url: url, msg: msg);
        break;
      case Share.twitter:
        response = await flutterShareMe.shareToTwitter(url: url, msg: msg);
        break;
      case Share.whatsapp:
        response = await flutterShareMe.shareToWhatsApp(msg: msg);
        break;
      case Share.share_system:
        response = await flutterShareMe.shareToSystem(msg: msg);
        break;
      case Share.share_telegram:
        response = await flutterShareMe.shareToTelegram(msg: msg);
        break;
      case Share.sms:
        response = await flutterShareMe.shareSms(msg);
        break;
      case Share.email:
        response = await flutterShareMe.shareToEmail(
          body: msg,
          subject: 'subject',
          isHTML: true,
        );
        break;
      case Share.checkInstalled:
        final Map<dynamic, dynamic>? checkInstallResults =
            await flutterShareMe.checkInstalledAppsForShare();
        if (kDebugMode) {
          print(checkInstallResults);
        }
        break;
    }
    debugPrint(response);
  }
}
