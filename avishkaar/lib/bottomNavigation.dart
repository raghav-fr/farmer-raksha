import 'package:avishkaar/HomePage.dart';
import 'package:avishkaar/askLLM.dart';
import 'package:avishkaar/constants/constant.dart';
import 'package:avishkaar/diseaseDetection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
class Bottomnavigation extends StatefulWidget {
  const Bottomnavigation({super.key});

  @override
  State<Bottomnavigation> createState() => _BottomnavigationState();
}

class _BottomnavigationState extends State<Bottomnavigation> {
  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
        tabs: [
          PersistentTabConfig(
            screen: FarmerDashboard(uid: auth.currentUser!.uid),
            item: ItemConfig(
              activeForegroundColor: Colors.black54,
              inactiveForegroundColor: Colors.black54,
              activeColorSecondary: Colors.black54,
              icon: Icon(Icons.home),
              title: "Home",
            ),
          ),
          PersistentTabConfig(
            screen: ChatPage(uid: auth.currentUser!.uid),
            item: ItemConfig(
              activeForegroundColor: Colors.black54,
              inactiveForegroundColor: Colors.black54,
              activeColorSecondary: Colors.black54,
              icon: Icon(FontAwesomeIcons.robot),
              title: "ask_llm",
            ),
          ),
          PersistentTabConfig(
            screen: Diseasedetection(),
            item: ItemConfig(
              activeForegroundColor: Colors.black54,
              inactiveForegroundColor: Colors.black54,
              activeColorSecondary: Colors.black54,
              icon: Icon(FontAwesomeIcons.disease),
              title: "disease_detection",
            ),
          ),
          
        ],
        navBarBuilder:
            (navBarConfig) => Style5BottomNavBar(
              navBarConfig: navBarConfig,
              navBarDecoration: NavBarDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
      );
  }
}