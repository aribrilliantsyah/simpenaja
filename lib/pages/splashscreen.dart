import 'dart:async';
import 'package:eminovel/pages/app.dart';
import 'package:eminovel/pages/login.dart';
import 'package:eminovel/pages/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
 
class SplashScreen extends StatefulWidget{
  @override
  _SplashScreen createState() => _SplashScreen();
}
 
class _SplashScreen extends State<SplashScreen>{
  final LocalStorage storage = new LocalStorage('profile_data.json');
  String is_auth = 'false';

  void initState(){
    super.initState();
    startSplashScreen();
  }

  void check_auth() async {
    await storage.ready;
    setState(() {
      is_auth = storage.getItem('is_auth') != null ? storage.getItem('is_auth') : is_auth;
    });

    if(is_auth == '' || is_auth == 'false'){
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
        return SignInScreen();
      }));
    }
  }
 
  startSplashScreen() async {
    var duration = const Duration(seconds: 5);
    return Timer(duration, () {
      check_auth();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
        return App();
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: new Image.asset(
                "assets/images/sign_in_vector.png",
                width: 250.0,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 24),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "©KELOMPOK 1 - 2021",
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
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