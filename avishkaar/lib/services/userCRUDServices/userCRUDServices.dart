import 'dart:developer';

// import 'package:englishaitutor/constants/constant.dart';
// import 'package:englishaitutor/models/userRegistrationModel/userRegistrationModel.dart';
// import 'package:englishaitutor/view/signinLogicScreen/signinLogicScreen.dart';
import 'package:avishkaar/authScreens/signinLogicScreen.dart';
import 'package:avishkaar/constants/constant.dart';
import 'package:avishkaar/models/userRegistrationModel.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
// import 'package:technova_billboard/constants/constant.dart';
// import 'package:technova_billboard/models/userRegistrationModel.dart';
// import 'package:technova_billboard/screens/authScreens/signinLogicScreen.dart';

class Usercrudservices {
  static userRegistrer(BuildContext context, Userregistrationmodel data) async {
    try {
      await firestore
          .collection('User')
          .doc(auth.currentUser!.uid)
          .set(data.toMap());
      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: const Signinlogicscreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      log(e.toString());
    }
  }
}
