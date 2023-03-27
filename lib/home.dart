import 'package:child_safety/map.dart';
import 'package:child_safety/parent_view.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  void navigateBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const MapPage(),
    const ParentView(),
  ];

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

  Color hex = const Color(0xff4592AF);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onBack(context),
      child: Scaffold(
        bottomNavigationBar: Container(
          // color: Colors.grey.shade800,
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              border: Border.all(width: 5, color: Colors.grey.shade300),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50), topRight: Radius.circular(50))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 55.0, vertical: 5),
            child: GNav(
              selectedIndex: _selectedIndex,
              onTabChange: navigateBar,
              textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 15),
              gap: 8,
              // backgroundColor: Colors.grey.shade800,
              color: hex,
              activeColor: Colors.white,
              tabBackgroundColor: hex,
              padding: EdgeInsets.all(16),
              iconSize: 30,
              tabs: const [
                GButton(icon: Icons.map_rounded, text: 'Location'),
                GButton(icon: Icons.directions, text: 'Direction'),
              ],
            ),
          ),
        ),
        body: _pages.elementAt(_selectedIndex),
      ),
    );
    ;
  }
}
