import 'dart:ui'; // ✅ Needed for blur effect
import 'package:avishkaar/authScreens/SignupPage.dart';
import 'package:avishkaar/services/authservices/authServices.dart';
import 'package:avishkaar/widgets/iconCustomTextbox.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart'; // ✅ Import toast
// import 'package:technova_billboard/screens/authScreens/SignupPage.dart';
// import 'package:technova_billboard/services/authservices/authServices.dart';
// import 'package:technova_billboard/widgets/iconCustomTextbox.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  TextEditingController? emailController = TextEditingController();
  TextEditingController? passwordController = TextEditingController();
  bool _isLoggingIn = false; // ✅ track login button state

  // ✅ Show blurred loader for social logins
  Future<void> _showSocialLoadingDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Dialog(
              backgroundColor: Colors.black.withOpacity(0.3),
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Color.fromRGBO(83, 40, 225, 1), // 🔵 blue
                    ),
                    SizedBox(width: 20),
                    Text(
                      "Signing in...",
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
  Future<void> _handleSocialLogin(
    Future<void> Function(BuildContext) loginFn,
  ) async {
    _showSocialLoadingDialog();
    try {
      await loginFn(context);
    } finally {
      if (Navigator.canPop(context)) Navigator.pop(context);
    }
  }

  // ✅ Login user (shows loader inside button)
  void _loginUser() async {
    if (emailController!.text.isEmpty || passwordController!.text.isEmpty) {
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
        _isLoggingIn = true; // show button loader
      });
      try {
        await Authservices.loginUser(
          context: context,
          emailAddress: emailController!.text,
          password: passwordController!.text,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoggingIn = false; // reset loader
          });
        }
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
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Login",
                    style: GoogleFonts.poppins(
                      fontSize: 4.h,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: GoogleFonts.poppins(),
                      ),
                      SizedBox(width: 2.w),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              child: Signuppage(),
                            ),
                          );
                        },
                        child: Text(
                          "Sign Up",
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
                  SizedBox(height: 3.h),
                  Text(
                    "Forget Password ?",
                    style: GoogleFonts.poppins(
                      color: Color.fromRGBO(83, 40, 225, 1),
                      fontWeight: FontWeight.bold,
                    ),
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
                        onPressed: _isLoggingIn ? null : _loginUser,
                        child:
                            _isLoggingIn
                                ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white, // ✅ white spinner
                                  ),
                                )
                                : Text(
                                  "Login",
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        _handleSocialLogin(
                          (ctx) => Authservices.signInAsGuest(ctx),
                        );
                      },
                      child: Text(
                        "Skip now",
                        style: GoogleFonts.poppins(
                          color: Color.fromRGBO(83, 40, 225, 1),
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
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
                      _handleSocialLogin(
                        (ctx) => Authservices.signInWithGoogle(ctx),
                      );
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
                      _handleSocialLogin(
                        (ctx) => Authservices.signInWithGitHub(ctx),
                      );
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
        ],
      ),
    );
  }
}
