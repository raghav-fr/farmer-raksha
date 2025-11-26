import 'dart:ui'; // ✅ Needed for blur effect
import 'package:avishkaar/authScreens/LoginPage.dart';
import 'package:avishkaar/services/authservices/authServices.dart';
import 'package:avishkaar/widgets/iconCustomTextbox.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart'; // ✅ Import toast
// import 'package:technova_billboard/screens/authScreens/LoginPage.dart';
// import 'package:technova_billboard/services/authservices/authServices.dart';
// import 'package:technova_billboard/widgets/iconCustomTextbox.dart';

class Signuppage extends StatefulWidget {
  const Signuppage({super.key});

  @override
  State<Signuppage> createState() => _SignuppageState();
}

class _SignuppageState extends State<Signuppage> {
  TextEditingController? nameController = TextEditingController();
  TextEditingController? emailController = TextEditingController();
  TextEditingController? passwordController = TextEditingController();

  bool _isLoading = false; // ✅ Track loading state for button

  // ✅ Loader dialog with blur (for social login)
  Future<void> _showLoadingDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false, // cannot close by tapping outside
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), // blur effect
        child: Dialog(
          backgroundColor: Colors.black.withOpacity(0.3),
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Colors.blue, // 🔵 Blue loader
                ),
                SizedBox(width: 20),
                Text(
                  "Please wait...",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Wrapper for social logins
  Future<void> _handleSocialLogin(Future<void> Function(BuildContext) loginFn) async {
    _showLoadingDialog();
    try {
      await loginFn(context);
    } finally {
      Navigator.pop(context); // close loading dialog
    }
  }

  Future<void> _signUpUser() async {
    if (nameController!.text.isEmpty ||
        emailController!.text.isEmpty ||
        passwordController!.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill in all fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 14.sp,
      );
    } else {
      setState(() {
        _isLoading = true;
      });

      try {
        await Authservices.createUser(
          context: context,
          emailAddress: emailController!.text.trim(),
          password: passwordController!.text.trim(),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Image(image: AssetImage("assets/images/circle1.png")),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Create Account",
                    style: GoogleFonts.poppins(
                      fontSize: 3.8.h,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Already have an account?",
                        style: GoogleFonts.poppins(),
                      ),
                      SizedBox(width: 2.w),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              child: Loginpage(),
                            ),
                          );
                        },
                        child: Text(
                          "Sign In",
                          style: GoogleFonts.poppins(
                            color: Color.fromRGBO(83, 40, 225, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Iconcustomtextbox(
                    textEditingController: nameController,
                    height: 5.h,
                    icon: Icon(Icons.person, color: Colors.grey),
                    hint: "Name",
                  ),
                  SizedBox(height: 1.5.h),
                  Iconcustomtextbox(
                    textEditingController: emailController,
                    height: 5.h,
                    icon: Icon(Icons.email, color: Colors.grey),
                    hint: "Email",
                  ),
                  SizedBox(height: 1.5.h),
                  Iconcustomtextbox(
                    textEditingController: passwordController,
                    height: 5.h,
                    icon: Icon(Icons.lock, color: Colors.grey),
                    hint: "Password",
                  ),
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 40.w,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Color.fromRGBO(83, 40, 225, 1),
                          ),
                        ),
                        onPressed: _isLoading ? null : _signUpUser,
                        child: _isLoading
                            ? SizedBox(
                                height: 2.5.h,
                                width: 2.5.h,
                                child: CircularProgressIndicator(
                                  color: Colors.white, // Loader inside button
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                "Sign Up",
                                style: GoogleFonts.poppins(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.only(bottom: 13.h),
              width: 100.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      _handleSocialLogin((ctx) => Authservices.signInWithGoogle(ctx));
                    },
                    child: FaIcon(
                      FontAwesomeIcons.google,
                      size: 3.5.h,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(width: 6.w),
                  InkWell(
                    onTap: () {
                      _handleSocialLogin((ctx) => Authservices.signInWithGitHub(ctx));
                    },
                    child: FaIcon(
                      FontAwesomeIcons.github,
                      size: 3.5.h,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 5.h,
            left: 8.w,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
