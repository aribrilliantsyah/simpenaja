import 'package:eminovel/models/item.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class CardItem extends StatefulWidget {
  final Item item;

  const CardItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  _CardItemState createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image(
                  image: widget.item.image!.isNotEmpty
                      ? NetworkImage(widget.item.image.toString())
                      : AssetImage('assets/images/no_image.png') as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.25),
                border: Border.all(
                  color: Colors.grey,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 5)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              widget.item.name.toString(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(
                  Ionicons.qr_code,
                  size: 12,
                ),
                Padding(padding: EdgeInsets.only(left: 5)),
                Text(
                  widget.item.barcode != null ? widget.item.barcode.toString() : '-',
                  style: TextStyle(
                    fontSize: 13
                  ),
                ),   
              ],
            )
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Icon(
                  Ionicons.archive_outline,
                  size: 12,
                ),
                Padding(padding: EdgeInsets.only(left: 5)),
                Text(
                  widget.item.stock != null ? widget.item.stock.toString() : '0',
                  style: TextStyle(
                    fontSize: 13
                  ),
                ),   
              ],
            )
          ),
          Padding(padding: EdgeInsets.only(bottom: 10)),
        ],
      ),
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
    );
  }
}
