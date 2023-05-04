import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';
import 'tambah_menu.dart';
import 'detailmenu.dart';

String _temp = 'menunggu API';

class Bahan {
  int id;
  String nama;

  Bahan({this.id, this.nama});
  factory Bahan.fromJson(Map<String, dynamic> json) {
    return Bahan(id: json['bahan_id'], nama: json['bahan_name']);
  }
}

class Menu {
  int id;
  String nama;
  String cara_pembuatan;
  int jumlah_like;
  List bahans;
  List comments;
  List likes;

  Menu(
      {this.id,
      this.nama,
      this.cara_pembuatan,
      this.jumlah_like,
      this.bahans,
      this.comments,
      this.likes});
  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
        id: json['menu_id'],
        nama: json['menu_nama'],
        cara_pembuatan: json['menu_cara_pembuatan'],
        jumlah_like: json['menu_like'],
        bahans: json['bahans'],
        comments: json['comments'],
        likes: json['likes']);
  }
}

List<Menu> MenuList = [];
String _txtcari = "";

//Login
String user_aktif = "";
int user_id = 0;
Future<String> cekLogin() async {
  final prefs = await SharedPreferences.getInstance();
  String user_name = prefs.getString("user_name") ?? '';
  user_id = prefs.getInt("user_id") ?? 0;
  return user_name;
}

void doLogout() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove("user_name");
  main();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  cekLogin().then((String result) {
    if (result == '')
      runApp(MyLogin());
    else {
      user_aktif = result;
      runApp(MyApp());
    }
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'List Makanan',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'List Makanan'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "http://ubaya.prototipe.net/emertech160418034/emerTech_uas/menulist.php"),
        body: {'cari': _txtcari});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  bacaData() {
    MenuList.clear();
    fetchData().then((value) {
      Map json = jsonDecode(value);
      for (var data in json['data']) {
        Menu menu = Menu.fromJson(data);
        MenuList.add(menu);
      }
      setState(() {
        _temp = MenuList[0].nama;
      });
    });
  }

  Future onGoBack(dynamic value) {
    setState(() {
      bacaData();
    });
  }

  Widget DaftarMenu() {
    if (MenuList.length > 0) {
      return GridView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemCount: MenuList.length,
          gridDelegate:
              new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemBuilder: (BuildContext context, int index) {
            return Card(
                elevation: 5,
                margin: EdgeInsets.all(5),
                child: Column(children: <Widget>[
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DetailMenu(menu_id: MenuList[index].id)));
                      },
                      child: Text(
                        MenuList[index].nama,
                      )),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DetailMenu(menu_id: MenuList[index].id)));
                      },
                      child: Image.network(
                        'http://ubaya.prototipe.net/emertech160418034/emerTech_uas/images/' +
                            MenuList[index].id.toString() +
                            '.jpg',
                        height: 150,
                        width: 150,
                      )),
                ]));
          });
    } else {
      return CircularProgressIndicator();
    }
  }

  @override
  void initState() {
    super.initState();
    bacaData();

    setState(() {
      generateBahan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.search),
              labelText: 'Makanan mengandung kata:',
            ),
            onFieldSubmitted: (value) {
              _txtcari = value;
              bacaData();
            },
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
                child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Wrap(
                    spacing: 20.0,
                    alignment: WrapAlignment.spaceEvenly,
                    children: [DaftarMenu()],
                  ),
                )
              ],
            )),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(user_aktif),
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/images/drawer.png'),
                ),
              ),
            ),
            ListTile(
              title: Text('Tambah Menu'),
              onTap: () {
                Navigator.push(context,
                        MaterialPageRoute(builder: (context) => TambahMenu()))
                    .then(onGoBack);
                ;
              },
            ),
            ListTile(
              title: Text('Log Out'),
              onTap: () {
                doLogout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
