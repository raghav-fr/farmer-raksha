
import 'package:avishkaar/getUserProvider/getUserProvider.dart';
import 'package:avishkaar/services/authservices/authServices.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:sizer/sizer.dart';
// import 'package:technova_billboard/provider/getUserProvider/getUserProvider.dart';
// import 'package:technova_billboard/services/authservices/authServices.dart';

class Signinlogicscreen extends StatefulWidget {
  const Signinlogicscreen({super.key});

  @override
  State<Signinlogicscreen> createState() => _SigninlogicscreenState();
}

class _SigninlogicscreenState extends State<Signinlogicscreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async{ 
      Authservices.checkAuth(context);
      await context.read<Getuserprovider>().getUser();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
    );
  }
}
