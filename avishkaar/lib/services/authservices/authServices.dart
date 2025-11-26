// ignore_for_file: unused_local_variable

import 'dart:developer';

// import 'package:englishaitutor/constants/constant.dart';
// import 'package:englishaitutor/view/authScreens/getStarted.dart';
// import 'package:englishaitutor/view/authScreens/loginScreen.dart';
// import 'package:englishaitutor/view/bottomNavigationBarTutoAI/bottomNavigationBarTutoAI.dart';
// import 'package:englishaitutor/view/signinLogicScreen/signinLogicScreen.dart';
// import 'package:englishaitutor/view/userregistrationScreen/userRegistrationScreen.dart';
import 'package:avishkaar/authScreens/LoginPage.dart';
import 'package:avishkaar/bottomNavigation.dart';
// import 'package:avishkaar/constants/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';
// import 'package:technova_billboard/constants/constant.dart';
// import 'package:technova_billboard/screens/accountScreens/AccountPage.dart';
// import 'package:technova_billboard/screens/authScreens/LoginPage.dart';
// import 'package:technova_billboard/screens/homeScreen/GetStartedPage.dart';
// import 'package:technova_billboard/screens/userRegistrationScreens/UserRegistrationPage.dart';

class Authservices {
  

  static bool checkAuth(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    print(user);
    if (user == null) {
      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(type: PageTransitionType.fade, child: Loginpage()),
        (route) => false,
      );
      return false;
    }
    Navigator.pushAndRemoveUntil(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: Bottomnavigation(),
                ),
                (route) => false,
              );
    return true;
  }

  static createUser({
    required BuildContext context,
    required String emailAddress,
    required String password,
  }) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailAddress,
            password: password,
          );
      Authservices.checkAuth(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        log('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        log('The account already exists for that email.');
      }
    } catch (e) {
      log(e.toString());
    }
  }

  static loginUser({
    required BuildContext context,
    required String emailAddress,
    required String password,
  }) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      Authservices.checkAuth(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        log('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        log('Wrong password provided for that user.');
      }
    }
  }

  static signInAsGuest(BuildContext context) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      print("Signed in with temporary account.");
      Authservices.checkAuth(context);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          print("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          print("Unknown error.");
      }
    }
  }

  static signInWithGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(serverClientId: "574790276604-83rq2epktt7hl25an3gpcvco15vqsi21.apps.googleusercontent.com");
    // Trigger the authentication flow
    GoogleSignInAccount? googleUser =
        await googleSignIn.authenticate();

    // Obtain the auth details from the request
    GoogleSignInAuthentication? googleAuth = googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    Authservices.checkAuth(context);
  }

  static signInWithFacebook(BuildContext context) async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    Authservices.checkAuth(context);
  }

  static signInWithGitHub(BuildContext context) async {
    // Create a new provider
    GithubAuthProvider githubProvider = GithubAuthProvider();

    await FirebaseAuth.instance.signInWithProvider(githubProvider);
    Authservices.checkAuth(context);
  }

  static signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn.instance.signOut();
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return Loginpage();
          },
        ),
        (_) => false,
      );
    } catch (e) {
      log(e.toString());
    }
  }

  static passwordresetLink({
    required BuildContext context,
    required String emailaddress,
  }) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: emailaddress);
    Navigator.pushAndRemoveUntil(
      context,
      PageTransition(type: PageTransitionType.fade, child: Loginpage()),
      (route) => false,
    );
  }
}
