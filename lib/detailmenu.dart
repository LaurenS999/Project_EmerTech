import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'main.dart';

class DetailMenu extends StatefulWidget {
  final int menu_id;
  DetailMenu({Key key, @required this.menu_id}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _DetailMenuState();
  }
}

Menu detilmenu;
String _comment;

class _DetailMenuState extends State<DetailMenu> {
  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "http://ubaya.prototipe.net/emertech160418034/emerTech_uas/detilmenu.php"),
        body: {'id': widget.menu_id.toString()});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  bacaData() {
    fetchData().then((value) {
      Map json = jsonDecode(value);
      detilmenu = Menu.fromJson(json['data']);

      setState(() {});
    });
  }

  void Like() async {
    int like = detilmenu.jumlah_like + 1;

    final response = await http.post(
        Uri.parse(
            "http://ubaya.prototipe.net/emertech160418034/emerTech_uas/tambah_like.php"),
        body: {
          'user_id': user_id.toString(),
          'menu_id': widget.menu_id.toString(),
          'menu_like': like.toString()
        });
    if (response.statusCode == 200) {
      print(response.body);
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses menambah Like')));
        setState(() {
          bacaData();
        });
      }
      if (json['result'] == 'fail') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Menu Sudah di Like')));
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  void Unlike() async {
    int unlike = detilmenu.jumlah_like - 1;

    final response = await http.post(
        Uri.parse(
            "http://ubaya.prototipe.net/emertech160418034/emerTech_uas/delete_like.php"),
        body: {
          'user_id': user_id.toString(),
          'menu_id': widget.menu_id.toString(),
          'menu_like': unlike.toString()
        });
    if (response.statusCode == 200) {
      print(response.body);
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses UnLike')));
        setState(() {
          bacaData();
        });
      }
      if (json['result'] == 'fail') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Menu Belum Like')));
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  void TambahComment() async {
    final response = await http.post(
        Uri.parse(
            "http://ubaya.prototipe.net/emertech160418034/emerTech_uas/tambah_comment.php"),
        body: {
          'user_id': user_id.toString(),
          'menu_id': widget.menu_id.toString(),
          'comment': _comment
        });
    if (response.statusCode == 200) {
      print(response.body);
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses menambah Like')));
        setState(() {
          bacaData();
        });
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  Widget tampilData() {
    if (detilmenu != null) {
      return Card(
          elevation: 10,
          margin: EdgeInsets.all(10),
          child: Column(children: <Widget>[
            Image.network(
                'http://ubaya.prototipe.net/emertech160418034/emerTech_uas/images/' +
                    detilmenu.id.toString() +
                    '.jpg'),
            Text(detilmenu.nama, style: TextStyle(fontSize: 25)),
            Padding(padding: EdgeInsets.all(10), child: Text("Bahan:")),
            Padding(
                padding: EdgeInsets.all(10),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: detilmenu.bahans.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return new Text(detilmenu.bahans[index]['bahan_name'] +
                          " Quantity : " +
                          detilmenu.bahans[index]['quantity']);
                    })),
            Padding(
                padding: EdgeInsets.all(10), child: Text("Cara Pembuatan:")),
            Padding(
                padding: EdgeInsets.all(10),
                child: Text(detilmenu.cara_pembuatan,
                    style: TextStyle(fontSize: 15))),
            Padding(
                padding: EdgeInsets.all(10),
                child: Text("Like :" + detilmenu.jumlah_like.toString(),
                    style: TextStyle(fontSize: 15))),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 16.0),
            //   child: ElevatedButton(
            //     onPressed: () {
            //       Like();
            //     },
            //     child: Text("Like"),
            //   ),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  onPressed: () {
                    Like();
                  },
                  child: Text('Like'),
                ),
                FlatButton(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  onPressed: () {
                    Unlike();
                  },
                  child: Text('Unlike'),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.all(10), child: Text("Comment:")),
            Padding(
                padding: EdgeInsets.all(10),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: detilmenu.comments.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return new Text(detilmenu.comments[index]['user_name'] +
                          ": " +
                          detilmenu.comments[index]['comment']);
                    })),
          ]));
    } else {
      return CircularProgressIndicator();
    }
  }

  Future onGoBack(dynamic value) {
    print("masuk goback");
    setState(() {
      bacaData();
    });
  }

  @override
  void initState() {
    super.initState();
    bacaData();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Detail of Makanan'),
        ),
        body: ListView(children: <Widget>[
          tampilData(),
          Padding(
              padding: EdgeInsets.all(10),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Comment',
                ),
                onChanged: (value) {
                  _comment = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Comment harus diisi';
                  }
                  return null;
                },
              )),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                TambahComment();
              },
              child: Text('Tambah Comment'),
            ),
          ),
        ]));
  }
}
