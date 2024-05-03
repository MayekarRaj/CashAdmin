import 'package:flutter/material.dart';

class BasePage extends StatelessWidget {
  final Widget child;
  final String? appBarTitle;
  final bool FABBool;
  final Function()? FABPressed;
  
  const BasePage({
    Key? key,
    required this.child,
    this.appBarTitle,
    required this.FABBool,
    this.FABPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF24274A),
        leadingWidth: 45,
        leading: IconButton(
          onPressed: () {
            Navigator.maybePop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
          ),
          color: Colors.white,
        ),
        title: Text(
          appBarTitle ?? "Baadshah",
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FABBool
          ? FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: const Color(0xFF24274A),
              onPressed: FABPressed,
              child: const Center(
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFD8DCF7).withOpacity(0.25),
              const Color(0xFFC5CEF9),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 2),
          child: child,
        ),
      ),
    );
  }
}
