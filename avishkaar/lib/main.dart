import 'package:avishkaar/authScreens/signinLogicScreen.dart';
import 'package:avishkaar/firebase_options.dart';
import 'package:avishkaar/getUserProvider/getUserProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context,_,_){
      return MultiProvider(providers: [
        ChangeNotifierProvider<Getuserprovider>(
              create: (_) => Getuserprovider(),
            )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Avishkaar',
        theme: ThemeData(
        ),
        home: Signinlogicscreen(),
      ),
      );
    });
  }
}
