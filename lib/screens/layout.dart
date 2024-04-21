import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:cash_admin/screens/home_screen.dart';
import 'package:flutter/material.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  final notchBottomBarController = NotchBottomBarController(index: 1);
  int _currentIndex = 1;

  final List<Widget> _pages = [
    Container(),
    HomePage(),
    Container(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: _pages[_currentIndex],
      ),
      // bottomNavigationBar: AnimatedNotchBottomBar(
      //   // showBlurBottomBar: true,
      //   // notchShader: ,
      //   shadowElevation: 20.0,
      //   showLabel: MediaQuery.of(context).size.height >= 800 ? true : false,
      //   // itemLabelStyle: TextStyle(color: Colors.white, fontSize: 12),
      //   kIconSize: MediaQuery.of(context).size.height >= 800 ? 24 : 20,
      //   notchBottomBarController: notchBottomBarController,
      //   bottomBarWidth: MediaQuery.of(context).size.width * 0.5,
      //   kBottomRadius: 0,
      //   removeMargins: true,
      //   color: Color(0xff2D3660),
      //   notchColor: Color(0xff2D3660),
      //   // Color(0xFFD6DBEE)
      //   onTap: (index) {
      //     setState(() {
      //       _currentIndex = index;
      //     });
      //   },
      //   bottomBarItems: [
      //     BottomBarItem(
      //       inActiveItem: Icon(
      //         Icons.person,
      //         color: Colors.white.withOpacity(0.5),
      //       ),
      //       activeItem: const Icon(
      //         Icons.person,
      //         color: Color(0xFFD6DBEE),
      //       ),
      //       // itemLabel: 'Home',
      //       // icon: Icons.home,
      //       // text: 'Home',
      //     ),
      //     BottomBarItem(
      //       inActiveItem: Icon(
      //         Icons.notifications_none,
      //         color: Colors.white.withOpacity(0.5),
      //       ),
      //       activeItem: const Icon(
      //         Icons.notifications_none,
      //         color: Color(0xFFD6DBEE),
      //       ),
      //       // itemLabel: 'Saved',
      //     ),
      //     BottomBarItem(
      //       inActiveItem: Icon(
      //         Icons.description,
      //         color: Colors.white.withOpacity(0.5),
      //       ),
      //       activeItem: const Icon(
      //         Icons.description,
      //         color: Color(0xFFD6DBEE),
      //       ),
      //       // itemLabel: 'Settings',
      //     ),
      //   ],
      // ),
    );
  }
}
