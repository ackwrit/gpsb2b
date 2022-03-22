import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Variables
  CameraPosition position = CameraPosition(target: LatLng(48.858278,2.29425),zoom: 14);
  Completer<GoogleMapController> controller = Completer();
  Position? maPosition;
  CameraPosition? positionActuelle;


  //Fonction
  Future <Position> verification() async{
    bool service;
    LocationPermission permission;
    service = await Geolocator.isLocationServiceEnabled();
    if(!service){
      return Future.error("La localisation n'a pas été trouvé");
    }
    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        return Future.error("L'utilisateur ne souhaite donnée la permission à l'application");
      }
    }
    if(permission == LocationPermission.deniedForever){
      return Future.error("'utilisateur ne souhaite absolument pas donnée sa permission");
    }
    return Geolocator.getCurrentPosition();

  }





  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: bodyPage()

    );
  }

  Widget bodyPage(){
    verification().then((Position gps) {
      setState(() {
        maPosition = gps;
        positionActuelle =
            CameraPosition(
                target: LatLng(maPosition!.latitude,maPosition!.longitude),
                zoom: 14);
      });
    });
    return GoogleMap(
        initialCameraPosition: positionActuelle!,
      onMapCreated: (GoogleMapController control) async{
          String map = await DefaultAssetBundle
              .of(context)
              .loadString("lib/style/mapStyle.json");
          control.setMapStyle(map);
          controller.complete(control);
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
}
