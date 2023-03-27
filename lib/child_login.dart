import 'package:child_safety/child_location.dart';
import 'package:child_safety/home.dart';
import 'package:child_safety/parent_view.dart';
import 'package:child_safety/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/models/quickalert_animtype.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class ChildLogin extends StatefulWidget {
  const ChildLogin({super.key});

  @override
  State<ChildLogin> createState() => _ChildLoginState();
}

class _ChildLoginState extends State<ChildLogin> {
  Color hexBlue = const Color(0xff4592AF);
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  var email = '123@gmail.com';
  void showSucessAlert() {
    QuickAlert.show(
      context: context,
      text: "Login Sucessfull",
      confirmBtnColor: hexBlue,
      type: QuickAlertType.success,
      animType: QuickAlertAnimType.slideInDown,
      borderRadius: 20,
      confirmBtnTextStyle: const TextStyle(
          fontFamily: 'Geometria',
          color: Colors.white,
          fontWeight: FontWeight.bold),
      confirmBtnText: 'OKAY',
      onConfirmBtnTap: () {},
    );
  }

  void showFaildAlert() {
    QuickAlert.show(
      context: context,
      text: "Check Username And Password",
      confirmBtnColor: hexBlue,
      type: QuickAlertType.error,
      animType: QuickAlertAnimType.slideInDown,
      borderRadius: 20,
      confirmBtnTextStyle: const TextStyle(
          fontFamily: 'Geometria',
          color: Colors.white,
          fontWeight: FontWeight.bold),
      confirmBtnText: 'OKAY',
    );
  }

  late Permission permission;
  PermissionStatus permissionStatusStorage = PermissionStatus.denied;
  PermissionStatus permissionStatusLocation = PermissionStatus.denied;

  void _listenForPermission() async {
    final statusStorage = await Permission.storage.status;
    final statusLocation = await Permission.location.status;
    setState(() {
      permissionStatusStorage = statusStorage;
      permissionStatusLocation = statusLocation;
    });
    switch (statusStorage) {
      case PermissionStatus.denied:
        requestForPermission();
        break;
      case PermissionStatus.granted:
        // nothing
        break;
      case PermissionStatus.limited:
        Navigator.pop(context);
        break;
      case PermissionStatus.restricted:
        Navigator.pop(context);
        break;
      case PermissionStatus.permanentlyDenied:
        Navigator.pop(context);
        break;
    }
    switch (statusLocation) {
      case PermissionStatus.denied:
        requestForPermission();
        break;
      case PermissionStatus.granted:
        // nothing
        break;
      case PermissionStatus.limited:
        Navigator.pop(context);
        break;
      case PermissionStatus.restricted:
        Navigator.pop(context);
        break;
      case PermissionStatus.permanentlyDenied:
        Navigator.pop(context);
        break;
    }
  }

  @override
  void initState() {
    _listenForPermission();
    super.initState();
  }

  Future<void> requestForPermission() async {
    final statusStorage = await Permission.storage.request();
    final statusLocation = await Permission.location.request();

    setState(() {
      permissionStatusStorage = statusStorage;
      permissionStatusLocation = statusLocation;
    });
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
                    await FirebaseAuth.instance
                        .signOut()
                        .then((value) => {print('Signed Out')});
                  },
                  child: Text('Yes',
                      style: TextStyle(fontFamily: 'Poppins', color: hex)))
            ],
          );
        });
    return exitApp ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onBack(context),
      child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
              child: SingleChildScrollView(
            child: Center(
              child: Form(
                key: formkey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.phone_android,
                      size: 150,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 50),
                    Text('Hello Again!',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 52,
                          color: Colors.white,
                        )),
                    const SizedBox(height: 10),
                    Text("Welcome Back! You've Been Missed",
                        style: GoogleFonts.bebasNeue(
                          fontSize: 25,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        )),
                    const SizedBox(height: 50),
                    //Email Field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Email',
                              hintStyle: TextStyle(fontFamily: 'Poppins'),
                            ),
                            controller: _emailController,
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return "Please Enter Your Email";
                              }
                              if (!RegExp(
                                      r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-z]+")
                                  .hasMatch(value)) {
                                return "Please Enter Your Correct Email";
                              }
                            },
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    //Password Field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextFormField(
                              obscureText: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Password',
                                hintStyle: TextStyle(fontFamily: 'Poppins'),
                              ),
                              controller: _passwordController,
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return "Please Enter Your Email";
                                }
                                if (!RegExp("[0-9a-zA-Z]{6,}")
                                    .hasMatch(value)) {
                                  return "Enter More Than 5 Characters";
                                }
                                onSaved:
                                (String password) {
                                  password = password;
                                };
                              }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    //sign in Button

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: GestureDetector(
                        onTap: () async {
                          if (_emailController.text == "123@gmail.com") {
                            final credential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: _emailController.text,
                                    password: _passwordController.text)
                                .then((value) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const ChildLocation()));
                            });
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const HomePage()));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: hexBlue,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Center(
                              child: Text('Sign In',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // not a member

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const Register()));
                          },
                          child: Text('Register Now',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  color: hexBlue)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ))),
    );
  }
}
