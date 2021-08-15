import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:eminovel/helpers/custom_colors.dart';
import 'package:eminovel/pages/login.dart';
import 'package:eminovel/pages/sign_in_screen.dart';
import 'package:eminovel/utils/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
import 'package:localstorage/localstorage.dart';

class Profile extends StatefulWidget {
  final LocalStorage storage;

  Profile({Key? key, required this.storage}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String username = 'Username';
  String name = 'Nama';
  String description = 'Description';
  String photo_url = 'https://www.showflipper.com/blog/images/default.jpg';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    get_profile();
  }
  
  void get_profile() async{
    LocalStorage storage = widget.storage;
    setState(() {
      username = storage.getItem('username') != null ? storage.getItem('username') : username;
      name = storage.getItem('name') != null ? storage.getItem('name') : name;
      description = storage.getItem('description') != null ? storage.getItem('description') : description;
      photo_url = storage.getItem('photo_url') != null ? storage.getItem('photo_url') : photo_url;
    });
  }

  void onLogout() async {
    bool signout = await Authentication.signOut(context: context);
    if(signout){
      await widget.storage.setItem('username', '');
      await widget.storage.setItem('name', '');
      await widget.storage.setItem('description', '');
      await widget.storage.setItem('photo_url', '');
      await widget.storage.setItem('is_auth', '');

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
        return SignInScreen();
      }));
    }else{
      Navigator.push(
        context,
        AwesomeMessageRoute(
          awesomeMessage: AwesomeHelper.createAwesome(
            title: "Oops", 
            message: "Please try again!",
            tipType: TipType.INFO,
          ),
          settings: RouteSettings(name: "/info"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.primaryColor,
        centerTitle: true,
        title: Text(
          "Setting",
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Column(
                  children: <Widget>[
                    _user_info(name, username, description, photo_url),
                    _button_menu(Ionicons.log_out, 'Logout', onLogout),
                  ],
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}

Widget _user_info(String name, String username, String description, String photo_url){
  return Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(width: 1.0, color: Colors.grey.withOpacity(0.2)),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 20),
          child: ClipOval(
            child: Image.network(
              '${photo_url}',
              width: 65,
              height: 65,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${name}', 
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Text(
              '${username}', 
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          ]
        ),
      ],
    ),
  );
}

Widget _button_menu(icon, String title, onPressed){
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 23),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(icon),
          ),
          Text(
            "${title}",
            style: TextStyle(
              fontSize: 18,
            ),
          )
        ],
      ),
    )
  );
}
