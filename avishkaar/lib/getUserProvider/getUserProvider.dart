import 'dart:developer';

// import 'package:englishaitutor/controllers/services/getUserDetailService/getUserDetailServices.dart';
// import 'package:englishaitutor/models/userRegistrationModel/userRegistrationModel.dart';
import 'package:avishkaar/models/userRegistrationModel.dart';
import 'package:avishkaar/services/getUserDetailService/getUserDetailServices.dart';
import 'package:flutter/material.dart';
// import 'package:technova_billboard/models/userRegistrationModel.dart';
// import 'package:technova_billboard/services/getUserDetailService/getUserDetailServices.dart';

class Getuserprovider extends ChangeNotifier{
  Userregistrationmodel? user;

  getUser() async{
    log('getuser');
    user = await Getuserdetailservices.getUserDetail();
    notifyListeners();
    log(user!.toJson().toString());
  }
}