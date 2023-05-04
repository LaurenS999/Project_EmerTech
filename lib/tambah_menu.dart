import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'main.dart';

List<Bahan> ListBahan_terpilih = [];

List<Bahan> bahans;
File _image = null;

class Bahan {
  int id;
  String nama;
  String quantity;
  Bahan({this.id, this.nama, this.quantity});
  factory Bahan.fromJson(Map<String, dynamic> json) {
    return Bahan(
        id: json['bahan_id'],
        nama: json['bahan_name'],
        quantity: json['bahan_quantity']);
  }
}

Future<List> daftarBahan() async {
  Map json;
  final response = await http.post(
    Uri.parse(
        "http://ubaya.prototipe.net/emertech160418034/emerTech_uas/bahanlist.php"),
  );
  if (response.statusCode == 200) {
    json = jsonDecode(response.body);
    return json['data'];
  } else {
    throw Exception('Failed to read API');
  }
}

void generateBahan() {
  //widget function for city list

  var data = daftarBahan();
  data.then((value) {
    bahans = List<Bahan>.from(value.map((i) {
      return Bahan.fromJson(i);
    }));
  });
}

Widget comboBahan = Text('tambah Bahan');

class TambahMenu extends StatefulWidget {
  @override
  TambahMenuState createState() {
    return TambahMenuState();
  }
}

class TambahMenuState extends State<TambahMenu> {
  final _formKey = GlobalKey<FormState>();
  String _menu_nama = "";
  String _menu_cara_pembuatan = "";

  void genereteComboBox() {
    comboBahan = DropdownButton(
        dropdownColor: Colors.grey[100],
        hint: Text("tambah Bahan"),
        isDense: false,
        items: bahans.map((gen) {
          return DropdownMenuItem(
              child: Column(children: <Widget>[
                Text(gen.nama, overflow: TextOverflow.visible),
              ]),
              value: Bahan(id: gen.id, nama: gen.nama, quantity: '0'));
        }).toList(),
        onChanged: (value) {
          if (ListBahan_terpilih.contains(value)) {
            print("Sudah Ada");
          } else {
            ListBahan_terpilih.add(value);
          }

          setState(() {});
          print(ListBahan_terpilih);
          print(ListBahan_terpilih[0].nama);
        });
  }

  void submit() async {
    final response = await http.post(
        Uri.parse(
            "http://ubaya.prototipe.net/emertech160418034/emerTech_uas/tambah_menu.php"),
        body: {
          'menu_nama': _menu_nama,
          'menu_cara_pembuatan': _menu_cara_pembuatan,
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        String id = json['id'].toString();
        List<int> imageBytes = _image.readAsBytesSync();
        print(imageBytes);
        String base64Image = base64Encode(imageBytes);
        final response2 = await http.post(
            Uri.parse(
              'http://ubaya.prototipe.net/emertech160418034/emerTech_uas/uploadmenugambar.php',
            ),
            body: {
              'menu_id': id,
              'image': base64Image,
            });
        if (response.statusCode == 200) {
          Map json = jsonDecode(response.body);
          if (json['result'] == 'success') {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(response2.body)));
            for (int i = 0; i < ListBahan_terpilih.length; i++) {
              final response = await http.post(
                  Uri.parse(
                      "http://ubaya.prototipe.net/emertech160418034/emerTech_uas/tambah_bahan_menu.php"),
                  body: {
                    'menu_id': id,
                    'bahan_id': ListBahan_terpilih[i].id.toString(),
                    'quantity': ListBahan_terpilih[i].quantity,
                  });
              if (response.statusCode == 200) {
                Map json = jsonDecode(response.body);
                if (json['result'] == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Success Input Bahan")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Gagal Input Bahan")));
                }
              }
            }
          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(response2.body)));
          }
        }
      }
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              color: Colors.white,
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      tileColor: Colors.white,
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Galeri'),
                      onTap: () {
                        _imgGaleri();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Kamera'),
                    onTap: () {
                      _imgKamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _imgGaleri() async {
    final picker = ImagePicker();
    final image = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxHeight: 600,
        maxWidth: 600);
    setState(() {
      _image = File(image.path);
    });
  }

  _imgKamera() async {
    final picker = ImagePicker();
    final image =
        await picker.getImage(source: ImageSource.camera, imageQuality: 20);
    setState(() {
      _image = File(image.path);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      generateBahan();
      genereteComboBox();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Tambah Makanan"),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nama Menu',
                    ),
                    onChanged: (value) {
                      _menu_nama = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama Menu harus diisi';
                      }
                      return null;
                    },
                  )),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Cara Pembuatan',
                    ),
                    onChanged: (value) {
                      _menu_cara_pembuatan = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Cara Pembuatan harus diisi';
                      }
                      return null;
                    },
                  )),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: ListBahan_terpilih.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return new Container(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                              Text(ListBahan_terpilih[index].nama),
                              Text(" Quantity : " +
                                  ListBahan_terpilih[index].quantity),
                              Text("        "),
                              Container(
                                width: 40,
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: '1',
                                  ),
                                  onChanged: (value) {
                                    ListBahan_terpilih[index].quantity =
                                        value.toString();
                                    setState(() {});
                                  },
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  ListBahan_terpilih.removeAt(index);
                                  setState(() {});
                                },
                                child: Text('hapus'),
                              ),
                            ]));
                      })),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: comboBahan),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: () {
                      _showPicker(context);
                    },
                    child: _image != null
                        ? Image.file(_image)
                        : Image.network(
                            "http://ubaya.prototipe.net/daniel/blank.png"),
                  )),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Harap Isian diperbaiki')));
                    } else {
                      submit();
                    }
                  },
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ));
  }
}
