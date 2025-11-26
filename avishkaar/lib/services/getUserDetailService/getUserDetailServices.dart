import 'dart:developer';

// import 'package:englishaitutor/constants/constant.dart';
// import 'package:englishaitutor/models/userRegistrationModel/userRegistrationModel.dart';
import 'package:avishkaar/constants/constant.dart';
import 'package:avishkaar/models/userRegistrationModel.dart';
// import 'package:technova_billboard/constants/constant.dart';
// import 'package:technova_billboard/models/userRegistrationModel.dart';

class Getuserdetailservices {
  static getUserDetail() async {
    Userregistrationmodel? data;
    await firestore.collection('User').doc(auth.currentUser!.uid).get().then((docSnapshot) {
        log("hello");
        data = Userregistrationmodel.fromMap(docSnapshot.data()!);
    });
    return data;
  }
}