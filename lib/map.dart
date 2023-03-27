import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  double? latitute;
  double? longitude;
  dataNeed() async {
    CollectionReference users =
        FirebaseFirestore.instance.collection('childLocation');
    final snapshot = await users.doc('location').get();
    final data = snapshot.data() as Map<String, dynamic>;

    print('The Latitude Is $latitute');
    setState(() {
      latitute = double.parse(data['lat']);
      longitude = double.parse(data['long']);
      _latLngList = [
        if (latitute != null && longitude != null)
          LatLng(latitute!, longitude!),
      ];
    });
  }

  List<LatLng>? _latLngList;
  @override
  void initState() {
    super.initState();
    Timer mytimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      dataNeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: latitute != null && longitude != null
            ? LatLng(latitute!, longitude!)
            : LatLng(0, 0),
        zoom: 18,
      ),
      nonRotatedChildren: [
        AttributionWidget.defaultWidget(
          source: 'OpenStreetMap contributors',
          onSourceTapped: null,
        ),
      ],
      children: [
        TileLayer(
          minZoom: 1,
          maxZoom: 25,
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: _latLngList!.isNotEmpty
              ? _latLngList!
                  .map((point) => Marker(
                        point: point,
                        width: 60,
                        height: 60,
                        builder: (context) => const Icon(
                          Icons.pin_drop,
                          size: 60,
                          color: Colors.red,
                        ),
                      ))
                  .toList()
              : [],
        )
      ],
    );
  }
}
