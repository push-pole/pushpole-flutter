import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:convert';

///

/// Main plugin class handling most of SDK's works.
///
class PushPole {

  // Callback handlers
  static void Function(NotificationData) _receiveCallback;
  static void Function(NotificationData) _clickCallback;
  static void Function(NotificationData) _dismissCallback;
  static void Function(String) _customContentCallback;
  static void Function(NotificationData, NotificationButtonData) _buttonClickCallback;



  static const MethodChannel _channel = const MethodChannel('PushPole');

  /// To start registering PushPole, you will call this method.
  /// [showDialog]: If device had no GooglePlayServices or it was old, a dialog will appear to let user update it using any market.
  static Future<void> initialize({bool showDialog: true}) async => _channel.invokeMethod('PushPole#initialize', {"showDialog":showDialog});

  /// Get the unique id of the devices generated by android id or ad id
  static Future<String> getId() async => await _channel.invokeMethod("PushPole#getId");

  /// Subscribe to a topic.
  /// [topic] is the name of that topic. The naming rules must follow FCM topic naming standards.
  static Future<void> subscribe(String topic) async => _channel.invokeMethod("PushPole#subscribe", {"topic":topic});

  /// Unsubscribe from a topic already subscribed.
  static Future<void> unsubscribe(String topic) async => _channel.invokeMethod("PushPole#unsubscribe", {"topic":topic});

  /// If this function is called, notification will not be shown.
  static Future<void> setNotificationOff() async => _channel.invokeMethod("PushPole#setNotificationOff");

  /// Default of notification is set to On, if you have set it off, you can revert it using this function.
  static Future<void> setNotificationOn() async => _channel.invokeMethod("PushPole#setNotificationOn");

  static Future<bool> isNotificationOn() async => _channel.invokeMethod("PushPole#isNotificationOn");

  /// Check if PushPole is registered to server or not. This method is not completely reliable.
  static Future<bool> isPushPoleInitialized() async => await _channel.invokeMethod("PushPole#isPushPoleInitialized");

  /// To send a simple notification to another user using his/her PushPoleId
  static Future<void> sendSimpleNotifToUser(String pushpoleId, String title, String content) async => _channel.invokeMethod("PushPole#sendSimpleNotifToUser", {"pushpoleId":pushpoleId, "title":title, "content":content});

  /// To send a JSON formatted advanced notification to another device using it's PushPoleId
  static Future<void> sendAdvancedNotifToUser(String pushpoleId, String notificationJson) async => _channel.invokeMethod("PushPole#sendAdvancedNotifToUser", {"pushpoleId":pushpoleId, "json":notificationJson});

  /// Set callbacks for different types of events for notifications (in foreground or when app is open in the background)
  /// [onReceived] is called when notification was received.
  /// [onClicked] is called when notification was clicked.
  /// [onDismissed] is called when notification was swiped away.
  /// [onButtonClicked] is called when notification contains button and a button was clicked.
  /// [onCustomContentReceived] is called when notification includes custom json. It will a json in string format.
  /// [applicationOverridden] : If you have added [android:name="com.pushpole.sdk.flutter.PushPoleApplication"] to your AndroidManifest application attribute,
  /// the callbacks will be callable since user starts the app. But if not, callbacks will be available when you call [setNotificationListener] and before that callbacks won't work.
  /// This doesn't make so much difference. But in future case when Flutter added background fcm support, this can make difference.
  static setNotificationListener({
    Function(NotificationData) onReceived,
    Function(NotificationData) onClicked,
    Function(NotificationData) onDismissed,
    Function(NotificationData, NotificationButtonData) onButtonClicked,
    Function(String) onCustomContentReceived,
    bool applicationOverridden: false
  }) {
    _receiveCallback = onReceived;
    _clickCallback = onClicked;
    _dismissCallback = onDismissed;
    _buttonClickCallback = onButtonClicked;
    _customContentCallback = onCustomContentReceived;
    _channel.setMethodCallHandler(_handleMethod);
    if (!applicationOverridden) {
      _channel.invokeMethod("PushPole#initNotificationListenerManually");
    }
  }


  ///
  /// If a method was called from native code through channel this will handle it.
  ///
  static Future<Null> _handleMethod(MethodCall call) async {
    if (call.method == 'PushPole#onNotificationReceived') {
      _receiveCallback?.call(NotificationData.fromJson(call.arguments));
    } else if (call.method == 'PushPole#onNotificationClicked') {
    _clickCallback?.call(NotificationData.fromJson(call.arguments));
    } else if (call.method == 'PushPole#onNotificationButtonClicked') {
      try {
        var parts = call.arguments.toString().split("|||");
        _buttonClickCallback?.call(NotificationData.fromJson(parts[0]), NotificationButtonData.fromJsonString(parts[1]));
      } catch(e) {}
    } else if (call.method == 'PushPole#onNotificationCustomContentReceived') {
      try {
        var customContent = jsonDecode(call.arguments['json']);
        _customContentCallback?.call(customContent);
      } catch(e) {}
    } else if (call.method == 'PushPole#onNotificationDismissed') {
      _dismissCallback?.call(NotificationData.fromJson(call.arguments));
    }
    return null;
  }
}

///
/// Notification data class as an interface between native callback data classes and Flutter dart code.
/// When a notification event happens (like Receive), callbacks will hold instances of this class.
///
class NotificationData {
  String _title, _content, _bigTitle, _bigContent, _summary, _imageUrl, _iconUrl, _customContent;
  List<NotificationButtonData> _buttons;

  NotificationData._();

  NotificationData.create(this._title, this._content, this._bigTitle,
      this._bigContent, this._summary, this._imageUrl, this._iconUrl,
      this._customContent, this._buttons);

  static NotificationData fromJson(String json) {
    try {
      var data = jsonDecode(json);
      return NotificationData.create(
          data['title'], data['content'],
          data['bigTitle'], data['bigContent'],
          data['summary'], data['imageUrl'],
          data['iconUrl'], data['json'],
          NotificationButtonData.fromJsonList(data['buttons']));
    } catch(e) {
      print('Error getting notification data from json\nError:$e\nJson:$json');
      return null;
    }
  }

  @override
  String toString() => 'NotificationData{_title: $_title, _content: $_content, _bigTitle: $_bigTitle, _bigContent: $_bigContent, _summary: $_summary, _imageUrl: $_imageUrl, _iconUrl: $_iconUrl, _customContent: $_customContent, buttons: $_buttons}';

  get customContent => _customContent;
  get iconUrl => _iconUrl;
  get imageUrl => _imageUrl;
  get summary => _summary;
  get bigContent => _bigContent;
  get bigTitle => _bigTitle;
  get content => _content;
  get title => _title;
  get buttons => _buttons;

}

///
/// When there are buttons in the notification they are accessible through callbacks.
/// For every button there would be an object in the callback notification data object.
/// And also when a button is clicked, it's id and text will be passes separately in `onNotificationButtonClicked` callback.
class NotificationButtonData {
  String _text;
  int _id;

  NotificationButtonData._();
  NotificationButtonData.create(this._text, this._id);

  int get id => _id;
  String get text => _text;

  @override
  String toString() => 'NotificationButtonData{_text: $_text, _id: $_id}';

  static NotificationButtonData fromMap(dynamic data) {
    try {
      return NotificationButtonData.create(data['big_content'], data['btn_id']);
    } catch (e) {
      print('Error getting button from json\nError:$e\nJson:$json');
      return null;
    }
  }

  static NotificationButtonData fromJsonString(dynamic json) {
    return fromMap(jsonDecode(json));
  }

  static List<NotificationButtonData> fromJsonList(dynamic json) {
    try {
      var result = (json as List<dynamic>).map((item) {
        return fromMap(item);
      });
      return result.toList();
    } catch(e) {
      print('Error getting button list from notification\nError:$e\nJson:$json');
      return null;
    }
  }



}