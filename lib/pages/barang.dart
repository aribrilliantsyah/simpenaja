import 'package:eminovel/helpers/custom_colors.dart';
import 'package:eminovel/models/item.dart';
import 'package:eminovel/pages/form_barang.dart';
import 'package:eminovel/widgets/card_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ionicons/ionicons.dart';
import 'package:localstorage/localstorage.dart';


class Barang extends StatefulWidget {
  final LocalStorage storage;

  Barang({Key? key, required this.storage}) : super(key: key);

  @override
  _BarangState createState() => _BarangState();
}

class _BarangState extends State<Barang> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.primaryColor,
        centerTitle: true,
        title: Text(
          "Items",
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          // color: Colors.red,
          // padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
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
                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height / 1.5),
                  ),
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
                      child: CardItem(item: item),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FormBarang(
                              item: item,
                              id: item.id,
                              email: username
                            ),
                          ),
                        );
                      },
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
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Ionicons.add,
          color: Colors.white,
        ),
        backgroundColor: CustomColors.primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormBarang(item: null, id: null, email: username),
            ),
          );
        },
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


Widget _card_item(Item item){
  String image;
  if(item.image == null){
    image = 'https://i.postimg.cc/90Kwhrdq/Group-7-1.png';
  }else{
    image = item.image!;
  }

  return Padding(
    padding: EdgeInsets.only(top: 8, bottom: 8),
    child: Container(
      height: 140,
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
                height: 140,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 21, left: 11, right: 10),
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
                child: Text(
                  '${item.barcode}', 
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
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

