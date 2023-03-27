import 'package:child_safety/child_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/models/quickalert_animtype.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  Color hexBlue = const Color(0xff4592AF);
  TextEditingController password = TextEditingController();
  TextEditingController email = TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  //text Controllers

  bool isValid = false;

  void showFaildAlert() {
    QuickAlert.show(
      context: context,
      text: "Sign Up Failed",
      type: QuickAlertType.error,
      confirmBtnColor: hexBlue,
      animType: QuickAlertAnimType.slideInDown,
      borderRadius: 20,
      confirmBtnTextStyle: const TextStyle(
          fontFamily: 'Geometria',
          color: Colors.white,
          fontWeight: FontWeight.bold),
      confirmBtnText: 'OKAY',
    );
  }

  void showSucessAlert() {
    QuickAlert.show(
      context: context,
      text: "Sign Up Success",
      type: QuickAlertType.success,
      confirmBtnColor: hexBlue,
      animType: QuickAlertAnimType.slideInDown,
      borderRadius: 20,
      confirmBtnTextStyle: const TextStyle(
          fontFamily: 'Geometria',
          color: Colors.white,
          fontWeight: FontWeight.bold),
      confirmBtnText: 'OKAY',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  SizedBox(height: 50),
                  Text('Hello There!',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 52,
                        color: Colors.white,
                      )),
                  SizedBox(height: 10),
                  Text("Register Below With Your Details",
                      style: GoogleFonts.bebasNeue(
                        fontSize: 25,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      )),
                  SizedBox(height: 50),
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
                          controller: email,
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
                  SizedBox(height: 20),

                  //New Password Field
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
                            hintText: 'New Password',
                            hintStyle: TextStyle(fontFamily: 'Poppins'),
                          ),
                          obscureText: true,
                          controller: password,
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return "Please Enter Your New Password";
                            }
                            if (!RegExp("[0-9a-zA-Z]{6,}").hasMatch(value)) {
                              return "MoreThan 6 Characters";
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  //Confirm Password Field

                  SizedBox(height: 20),
                  //sign up Button

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                      onTap: () {
                        FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                                email: email.text, password: password.text)
                            .then((value) => {
                                  print("Created"),
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              const ChildLogin()))
                                })
                            .onError((error, stackTrace) {
                          throw ("Error ${error.toString()}");
                        });
                        showSucessAlert();
                      },
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: hexBlue,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Center(
                            child: Text('Sign Up',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white))),
                      ),
                    ),
                  ),

                  SizedBox(height: 25),

                  // not a member

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("I'm a Member! ",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text('Login Now',
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
        )));
  }
}
