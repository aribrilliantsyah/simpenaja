import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eminovel/helpers/custom_colors.dart';
import 'package:eminovel/models/item.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:ionicons/ionicons.dart';

class FormBarang extends StatefulWidget {
  final Item? item;
  final String? id;
  final String? email;

  FormBarang(
      {Key? key, required this.item, required this.id, required this.email})
      : super(key: key);

  @override
  _FormBarangState createState() => _FormBarangState();
}

class _FormBarangState extends State<FormBarang> {
  String _scanBarcode = 'Unknown';
  TextEditingController barcodeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  File? imageFile;
  ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    barcodeController.text = '';
    nameController.text = '';
    stockController.text = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item != null && widget.id != null) {
      barcodeController.text = widget.item!.barcode!;
      nameController.text = widget.item!.name!;
      stockController.text = widget.item!.stock.toString();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.primaryColor,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        centerTitle: true,
        title: Text(
          "Form Item",
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Container(
              //   height: 50,
              //   color: CustomColors.primaryColor,
              //   child: Center(
              //     child: Text(
              //       'Data Item',
              //       style: TextStyle(
              //         color: Colors.black,
              //         fontSize: 20,
              //       ),
              //     ),
              //   ),
              // ),
              Divider(
                height: 0,
                color: Colors.black,
              ),
              Container(
                height: 150,
                child: Center(
                  child: GestureDetector(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey,
                      child: CircleAvatar(
                        radius: 59,
                        backgroundColor: Colors.white,
                        backgroundImage: imageFile != null
                            ? FileImage(imageFile!)
                            : widget.item != null && widget.id != null
                                ? widget.item!.image!.isNotEmpty
                                    ? NetworkImage(
                                        widget.item!.image.toString())
                                    : AssetImage('assets/images/no_image.png')
                                        as ImageProvider
                                : AssetImage('assets/images/no_image.png'),
                      ),
                    ),
                    onTap: () {
                      getImage(context);
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: barcodeController,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Barcode',
                    suffixIcon: IconButton(
                      icon: Icon(Ionicons.barcode),
                      onPressed: () => {
                        scanBarcodeNormal()
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: nameController,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Stock',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  height: 50,
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        widget.item == null && widget.id == null
                            ? Colors.blue
                            : Colors.green,
                      ),
                    ),
                    child: Text(
                      widget.item == null && widget.id == null
                          ? 'Create'
                          : 'Update',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () async {
                      String currentMillis = 'T' +
                          DateTime.now().millisecondsSinceEpoch.toString();
                      Item item = Item(
                        id: widget.item == null && widget.id == null
                            ? currentMillis
                            : widget.id,
                        image: widget.item == null && widget.id == null
                            ? await uploadFile(imageFile!, currentMillis)
                            : imageFile != null
                                ? await uploadFile(imageFile!, widget.id)
                                : widget.item!.image,
                        name: nameController.text,
                        barcode: barcodeController.text,
                        stock: int.parse(stockController.text),
                        email: widget.email,
                      );
                      if (widget.item == null && widget.id == null) {
                        FirebaseFirestore.instance
                            .collection('items')
                            .doc(currentMillis)
                            .set(item.toJson());
                      } else {
                        FirebaseFirestore.instance
                            .collection('items')
                            .doc(widget.id)
                            .update(item.toJson());
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              widget.item == null && widget.id == null
                  ? SizedBox()
                  : Padding(
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        height: 50,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red),
                          ),
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          onPressed: () {
                            FirebaseStorage.instance
                                .refFromURL(widget.item!.image.toString())
                                .delete()
                                .then((result) {
                              FirebaseFirestore.instance
                                  .collection('items')
                                  .doc(widget.id)
                                  .delete();
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> uploadFile(File? file, String? fileName) async {
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    Reference reference = firebaseStorage.ref().child('items/' + fileName!);
    UploadTask uploadTask = reference.putFile(file!);
    return await uploadTask.then((result) async {
      return await result.ref.getDownloadURL();
    });
  }

  Future<void> imgFromGallery() async {
    XFile? imgGallery = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if(imgGallery!.path.toString() != null){
      setState(() {
        imageFile = File(imgGallery!.path);
      });
    }
  }

  Future<void> imgFromCamera() async {
    XFile? imgCamera = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if(imgCamera!.path.toString() != null){
      setState(() {
        imageFile = File(imgCamera!.path);
      });
    }
  }

  void getImage(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library_outlined),
                title: Text('Gallery'),
                onTap: () {
                  imgFromGallery();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera_outlined),
                title: Text('Camera'),
                onTap: () {
                  imgFromCamera();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
      barcodeController.text = barcodeScanRes;
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }
}
