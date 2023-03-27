// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// import '../main.dart';

// class LocationProvider extends ChangeNotifier {
//   double? _lat;
//   double? _long;
//   Timer? _timer;

//   double get lat => _lat!;
//   double get long => _long!;

//   void startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       getCurrentLocation().then((value) {
//         _lat = double.parse('${value.latitude}');
//         _long = double.parse('${value.longitude}');
//         Map<String, String> data = {'lat': '$_lat ', 'long': '$_long'};
//         FirebaseFirestore.instance
//             .collection('childLocation')
//             .doc('location')
//             .set(data)
//             .then((value) {
//           print('added in bg');
//         });
//       });
//       notifyListeners();
//     });
//   }

//   void stopTimer() {
//     _timer?.cancel();
//   }
// }