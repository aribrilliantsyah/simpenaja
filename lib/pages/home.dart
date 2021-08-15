import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eminovel/helpers/constants.dart';
import 'package:eminovel/helpers/custom_colors.dart';
import 'package:eminovel/models/item.dart';
import 'package:eminovel/widgets/card_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:localstorage/localstorage.dart';

class Home extends StatefulWidget {
  final LocalStorage storage;
  final TabController tabController;

  Home({Key? key, required this.storage, required this.tabController}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String username = 'Username';
  String name = 'Nama';
  String description = 'Description';
  String photo_url = 'https://www.showflipper.com/blog/images/default.jpg';
  int _current = 0;
  int item_total = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    get_profile();
    countDocuments();
  }
  
  void countDocuments() async {
    FirebaseFirestore.instance
    .collection('items')
    .where('email', isEqualTo: username)
    .get()
    .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          setState(() {
            item_total++;
          });
        });
    });

    print('Total ${item_total}');
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: CustomColors.primaryColor,      
    ));
 
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Column(
              children: <Widget>[
                Container(
                  color: CustomColors.primaryColor,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      children: [
                        _user_info(name, photo_url),
                      ],
                    ),
                  )
                ),
                Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          height: 60,
                          decoration: new BoxDecoration(
                            color: CustomColors.primaryColor,
                              borderRadius: new BorderRadius.only(
                              bottomLeft: const Radius.circular(0.0),
                              bottomRight: const Radius.circular(0.0),
                            )
                          ),
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * .0,
                        right: 20.0,
                        left: 20.0
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        height: 110.0,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15)
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 2), // changes position of shadow
                            ),
                          ],
                        ),
                        child: _app_header(item_total)
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    children: <Widget>[
                      _header_list(() => {
                        widget.tabController.animateTo(1)
                      }),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('items').where('email', isEqualTo: username).snapshots(),
                builder:
                  (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && !snapshot.hasData) {
                    return Center(
                      child: Text('No data found...'),
                    );
                  }else if(snapshot.hasData){
                    if(snapshot.data!.docs.length == 0){
                      return Container(
                        child: Center(
                          child: Text('Data is Empty'),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.only(top: 0, bottom: 0, left: 20, right: 20),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        Item item = Item(
                          id: snapshot.data!.docs.elementAt(index)['id'],
                          image: snapshot.data!.docs.elementAt(index)['image'],
                          name: snapshot.data!.docs.elementAt(index)['name'],
                          stock: snapshot.data!.docs.elementAt(index)['stock'],
                          barcode: snapshot.data!.docs.elementAt(index)['barcode'],
                        );
                        return InkWell(
                          child: _card_item(item),
                        );
                      }
                    );
                  }
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ),
          ]
        )
      ),
    );
  }
}

Widget _user_info(name, photo_url){
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome', 
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          Text(
            '${name}', 
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ]
      ),
      ClipOval(
        child: Image.network(
          '${photo_url}',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      ),
    ],
  );
}

Widget _slide_banner(List list_image, dynamic onPageChanged){
  return  CarouselSlider(
    options: CarouselOptions(
      // height: 180,
      scrollDirection: Axis.horizontal,
      autoPlay: true,
      enableInfiniteScroll: true,
      autoPlayCurve: Curves.fastOutSlowIn,
      autoPlayInterval: Duration(seconds: 6),
      autoPlayAnimationDuration: Duration(milliseconds: 800),
      onPageChanged: onPageChanged,
      viewportFraction: 1,
      enlargeCenterPage: true,
    ),
    items: list_image.map((image) {
      return Builder(
        builder: (BuildContext context) {
          return Container(
            width: MediaQuery.of(context).size.width,
            child: Image.asset('${image}'),
          );
        },
      );
    }).toList(),
  );
}

Widget _header_list(onPressed){
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        'Current items', 
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(
        height: 29,
        // width: 150,
        child: TextButton(
          onPressed: onPressed,
          child: Text(
            'Show All', 
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: CustomColors.primaryColor,
            ),
          ),
        ),
      )
    ],
  );
}

Widget _card_item(Item item){
  String image = item.image.toString() != null ? item.image.toString() : 'https://i.postimg.cc/90Kwhrdq/Group-7-1.png';
  return Padding(
    padding: EdgeInsets.only(top: 8, bottom: 8),
    child: Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10)
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
                image,
                width: 110,
                height: 120,
                fit: BoxFit.cover,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 18, left: 11, right: 10),
                child: Text(
                  '${item.name}', 
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 3, left: 11),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Icon(
                        Ionicons.qr_code,
                        size: 13,
                      )
                    ),
                    Text(
                      '${item.barcode}', 
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                )
              ),
              Spacer(flex: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 11, bottom: 11),
                    child: Icon(
                      Ionicons.archive_outline,
                      size: 13,
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 5, bottom: 11),
                    child: Text(
                      '${item.stock}', 
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]
              )
            ]
          )
        ],
      )
    )
  );
}


Widget _app_header(total){
  return Row(
    children: [
      Image.asset(
        'assets/images/bag.png',
        height: 250,
      ),
      Padding(padding: EdgeInsets.only(left: 5)),
      VerticalDivider(
        color: Colors.grey[300],
        thickness: 2,
        width: 20,
      ),
      Padding(padding: EdgeInsets.only(left: 5)),
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Item Recorded',
            style: TextStyle(
              fontSize: 17
            ),
          ),
          Text(
            '${total}',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      )
    ],
  );
}

