import 'package:flutter/services.dart';
import 'file_type.dart';

//export file type enum
export 'package:flutter_share_me/file_type.dart';

class FlutterShareMe {
  final MethodChannel _channel = const MethodChannel('flutter_share_me');

  static const String _methodWhatsApp = 'whatsapp_share';
  static const String _methodFaceBook = 'facebook_share';
  static const String _methodMessenger = 'messenger_share';
  static const String _methodTwitter = 'twitter_share';
  static const String _methodInstagramShare = 'instagram_share';
  static const String _methodSystemShare = 'system_share';
  static const String _methodTelegramShare = 'telegram_share';
  static const String _methodEmailShare = 'email_share';
  static const String _methodSMSShare = 'sms_share';
  static const String _methodCheckInstalledApps = 'checkInstalledApps';

  ///share to WhatsApp
  /// [msg] message text you want on whatsapp
  Future<String?> shareToWhatsApp({String msg = ''}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent('msg', () => msg);
    String? result;
    try {
      result = await _channel.invokeMethod<String>(_methodWhatsApp, arguments);
    } catch (e) {
      return e.toString();
    }

    return result;
  }

  ///share to Telegram
  /// [msg] message text you want on telegram
  Future<String?> shareToTelegram({required String msg}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent('msg', () => msg);
    String? result;
    try {
      result =
          await _channel.invokeMethod<String>(_methodTelegramShare, arguments);
    } catch (e) {
      return e.toString();
    }
    return result;
  }

  ///share to facebook
  Future<String?> shareToFacebook(
      {required String msg, String url = ''}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent('msg', () => msg);
    arguments.putIfAbsent('url', () => url);
    String? result;
    try {
      result = await _channel.invokeMethod<String?>(_methodFaceBook, arguments);
    } catch (e) {
      return e.toString();
    }
    return result;
  }

  ///share to messenger
  Future<String?> shareToMessenger(
      {required String msg, String url = ''}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent('msg', () => msg);
    arguments.putIfAbsent('url', () => url);
    String? result;
    try {
      result =
          await _channel.invokeMethod<String?>(_methodMessenger, arguments);
    } catch (e) {
      return e.toString();
    }
    return result;
  }

  ///share to twitter
  ///[msg] string that you want share.
  Future<String?> shareToTwitter({required String msg, String url = ''}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent('msg', () => msg);
    arguments.putIfAbsent('url', () => url);
    String? result;
    try {
      result = await _channel.invokeMethod(_methodTwitter, arguments);
    } catch (e) {
      return e.toString();
    }
    return result;
  }

  ///use system share ui
  Future<String?> shareToSystem({required String msg}) async {
    String? result;
    try {
      result =
          await _channel.invokeMethod<String>(_methodSystemShare, {'msg': msg});
    } catch (e) {
      return 'false';
    }
    return result;
  }

  ///share file to instagram
  Future<String?> shareToInstagram(
      {required String filePath, FileType fileType = FileType.image}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent('url', () => filePath);
    if (fileType == FileType.image) {
      arguments.putIfAbsent('fileType', () => 'image');
    } else {
      arguments.putIfAbsent('fileType', () => 'video');
    }
    String? result;

    try {
      result =
          await _channel.invokeMethod<String>(_methodInstagramShare, arguments);
    } catch (e) {
      return e.toString();
    }
    return result;
  }

  Future<String?> shareToEmail(
      {List<String>? recipients,
      List<String>? ccrecipients,
      List<String>? bccrecipients,
      String? subject,
      String? body,
      bool? isHTML}) async {
    String? result;
    final Map<String, dynamic> arguments = <String, dynamic>{
      'recipients': recipients,
      'subject': subject,
      'ccrecipients': ccrecipients,
      'bccrecipients': bccrecipients,
      'body': body,
      'isHTML': isHTML,
    };
    try {
      result =
          await _channel.invokeMethod<String>(_methodEmailShare, arguments);
    } catch (e) {
      return e.toString();
    }
    return result;
  }

  Future<String?> shareSms(String msg) async {
    Map<String, dynamic>? args;
    args = <String, dynamic>{'msg': msg};
    final String? version = await _channel.invokeMethod(_methodSMSShare, args);
    return version;
  }

  Future<Map?> checkInstalledAppsForShare() async {
    final Map? apps = await _channel.invokeMethod(_methodCheckInstalledApps);
    return apps;
  }
}
