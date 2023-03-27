import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'package:child_safety/parent_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class ChildLocation extends StatefulWidget {
  const ChildLocation({super.key});

  @override
  State<ChildLocation> createState() => _ChildLocationState();
}

class _ChildLocationState extends State<ChildLocation> {
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

  Position? position;
  var lat;
  var long;
  var total;
  var kctlat = 11.0810367;
  var kctlong = 76.9891331;

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

  locationAccuracy() {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((kctlat - lat) * p) / 2 +
        c(lat * p) * c(kctlat * p) * (1 - c((kctlong - long) * p)) / 2;
    total = 12742 * asin(sqrt(a));
    total = (total * 1000);
    print(total);
    if (total <= 10) {
      return null;
    } else {
      sendPushMsg();
    }
    locationAccuracy(Double total) {
      this.total = total;
    }
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permission Denied');
      }
    }
    return await Geolocator.getCurrentPosition();
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

  static const fetchBackground = "fetchBackground";
//   void callbackDispatcher() async {
//     await service.configure(
// androidConfiguration: AndroidConfiguration(
//   onStart: onStart,
//   isForegroundMode: true,
//   notificationChannelId: 'my_foreground',
//   initialNotificationTitle: 'AWESOME SERVICE',
//   initialNotificationContent: 'Initializing',
//   foregroundServiceNotificationId: 888,
// ),);

// }

  @override
  void initState() {
    getCurrentLocation();
    Timer mytimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      getCurrentLocation().then((value) {
        setState(() {
          lat = double.parse('${value.latitude}');
          long = double.parse('${value.longitude}');
          Map<String, String> data = {'lat': '$lat ', 'long': '$long'};
          FirebaseFirestore.instance
              .collection('childLocation')
              .doc('location')
              .set(data)
              .then((value) {
            locationAccuracy();
            print('added');
          });
        });
      });
    });
    messagePermission();
    initInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onBack(context),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Child Location',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
        ),
        body: Center(
          child: Text(
            'lat : $lat \nlong : $long',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
