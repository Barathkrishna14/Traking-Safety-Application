import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ParentView extends StatefulWidget {
  const ParentView({super.key});

  @override
  State<ParentView> createState() => _ParentViewState();
}

class _ParentViewState extends State<ParentView> {
  Color hexBlue = const Color(0xff4592AF);
  var kctlat = 11.0810367;
  var kctlong = 76.9891331;
  var latitute;
  var longitude;
  var total;

  collection() async {
    CollectionReference users =
        FirebaseFirestore.instance.collection('childLocation');
    final snapshot = await users.doc('location').get();
    final data = snapshot.data() as Map<String, dynamic>;
    var latitute = double.parse(data['lat']);
    var longitude = double.parse(data['long']);
    collection(latitute, longitude) {
      this.latitute = latitute;
      this.longitude = longitude;
    }
  }

  Future<Map<String, dynamic>> details() async {
    CollectionReference users =
        FirebaseFirestore.instance.collection('childLocation');
    final snapshot = await users.doc('location').get();
    final data = snapshot.data() as Map<String, dynamic>;
    var latitute = double.parse(data['lat']);
    var longitude = double.parse(data['long']);
    print('The Latitude Is $latitute');
    String url = 'https://maps.google.com/?q=$latitute,$longitude';
    await canLaunchUrlString(url)
        ? await launchUrlString(url)
        : throw 'Could not Launch';

    return data;
  }

  Future<bool> onBack(BuildContext context) async {
    Color hex = const Color.fromRGBO(143, 148, 251, 1);

    bool? exitApp = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Alert',
                style: TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
            content: const Text('Are You Sure To Logout',
                style: TextStyle(fontFamily: 'Poppins')),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('No',
                      style: TextStyle(fontFamily: 'Poppins', color: hex))),
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Yes',
                      style: TextStyle(fontFamily: 'Poppins', color: hex)))
            ],
          );
        });
    return exitApp ?? false;
  }

  FlutterLocalNotificationsPlugin flnp = FlutterLocalNotificationsPlugin();
  void messagePermission() async {
    FirebaseMessaging message = FirebaseMessaging.instance;
    NotificationSettings settings = await message.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User Granted Permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User Granted Provisional Permission');
    } else {
      print('Permission Denied');
    }
  }

  initInfo() async {
    var andInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInitialize = const DarwinInitializationSettings();
    var initSettings =
        InitializationSettings(android: andInitialize, iOS: iOSInitialize);
    flnp.initialize(initSettings, onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
      try {
        if (notificationResponse.payload != null &&
            notificationResponse.payload!.isNotEmpty) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const ParentView()));
        }
      } catch (e) {
        print(e);
      }
      return;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Got a message whilst in the foreground!');
      if (message.notification != null) {
        print('Notification Title: ${message.notification!.title}');
        print('Notification Body: ${message.notification!.body}');
      }

      BigTextStyleInformation btsi = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContentTitle: true,
      );

      AndroidNotificationDetails apcs = AndroidNotificationDetails(
        'default_notification_channel_id',
        'default_notification_channel_id',
        importance: Importance.high,
        styleInformation: btsi,
        priority: Priority.high,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('i'),
      );

      NotificationDetails pcs = NotificationDetails(android: apcs);

      await flnp.show(
          0, message.notification!.title, message.notification!.body, pcs,
          payload: message.data['body']);
    });
  }

  locationAccuracy() {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((kctlat - latitute) * p) / 2 +
        c(latitute * p) *
            c(kctlat * p) *
            (1 - c((kctlong - longitude) * p)) /
            2;
    total = 12742 * asin(sqrt(a));
    total = (total * 1000);
    print(total);
    if (total <= 50) {
      return null;
    } else {
      sendPushMsg();
    }
  }

  @override
  void initState() {
    Timer mytimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      print('Cheking');
      CollectionReference users =
          FirebaseFirestore.instance.collection('childLocation');
      final snapshot = await users.doc('location').get();
      final data = snapshot.data() as Map<String, dynamic>;
      var latitute = double.parse(data['lat']);
      var longitude = double.parse(data['long']);
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 -
          c((kctlat - latitute) * p) / 2 +
          c(latitute * p) *
              c(kctlat * p) *
              (1 - c((kctlong - longitude) * p)) /
              2;
      total = 12742 * asin(sqrt(a));
      total = (total * 1000);
      print(total);
      if (total <= 10) {
        return;
      } else {
        sendPushMsg();
      }
    });
    messagePermission();
    initInfo();
    super.initState();
  }

  sendPushMsg() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    try {
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAAZanOkKA:APA91bFL3jVEaa2l7dumwykRRw5DOC4QvvW0onqBGsr6rUeloAB2mt7JFqHLMJehWepTihTAwHUAda3vfIX8IJztras8Rz9bfT7f3NZZ0pEUFs-QLQu1JJGFfrnLCgPuUg_g6enbfj9R'
          },
          body: jsonEncode(<String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': 'Child Crossed The Safe Zone',
              'title': 'Child Alert'
            },
            'notification': <String, dynamic>{
              'title': 'Child Crossed The Safe Zone',
              'body': 'Child Alert',
              'andriod_channel_id': 'default_notification_channel_id'
            },
            'to': fcmToken
          }));
      print('Sent Successfully');
    } catch (e) {
      print(e);
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    void dataSuccessAlert() {
      QuickAlert.show(
          context: context,
          text: "Data Inserted SuccessFully",
          type: QuickAlertType.success);
    }

    return WillPopScope(
      onWillPop: () => onBack(context),
      child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text('Get Direction'),
          ),
          body: Center(
              child: ElevatedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)))),
                  onPressed: details,
                  child: const Text(
                    'Get Direction',
                    style: TextStyle(fontFamily: 'Poppins'),
                  )))),
    );
  }
}
