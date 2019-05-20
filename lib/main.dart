// Flutter code sample for material.AppBar.actions.1

// This sample shows adding an action to an [AppBar] that opens a shopping cart.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: MyStatelessWidget(),
    );
  }
}

/// This is the stateless widget that the main application instantiates.
class MyStatelessWidget extends StatefulWidget {
  MyStatelessWidget({Key key}) : super(key: key);
  @override
  _Map createState() => _Map();
}

class _Map extends State<MyStatelessWidget>{
  LatLng _center ;
  var location = new Location();
  static Map<String, double> userLocation;

  @override
  void initState() {
    super.initState();
    location.onLocationChanged().listen((value) {
      setState(() {
        userLocation = value;
        print(userLocation["latitude"]);
        print(userLocation["longitude"]);
      });
    });
  }

    static final List<Markers> _markers = <Markers>[
      Markers(userLocation["latitude"], userLocation["longitude"], "Você", ""),
      Markers(-30.057999, -51.175179, "FAMECOS",  'assets/famecos.jpg' ),
      Markers(-30.103138, -51.235952, "Restaurante", 'assets/divino.png')
    ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.orangeAccent,
    appBar: AppBar(
      backgroundColor:Colors.orangeAccent ,
    title: Text("POA+Historia"),

    ),
    body: new FlutterMap(
      options: new MapOptions(
        center: new LatLng(userLocation["latitude"], userLocation["longitude"]),
        zoom: 16.0,
      ),

      layers: [
        new TileLayerOptions(
          urlTemplate: "https://api.tiles.mapbox.com/v4/"
              "{id}/{z}/{x}/{y}@2x.png?access_token=pk.eyJ1IjoidmluaXNicmFuY28iLCJhIjoiY2p2dmdmOW5wMGJhMjQ0b2JodDlqZHV4OCJ9.m1H-2o2OuthukXDLkxaewg",
          additionalOptions: {
            'accessToken': 'pk.eyJ1IjoidmluaXNicmFuY28iLCJhIjoiY2p2dmdmOW5wMGJhMjQ0b2JodDlqZHV4OCJ9.m1H-2o2OuthukXDLkxaewg',
            'id': 'mapbox.streets',
          },
        ),

        new MarkerLayerOptions(
          markers:
          _markers.map((markers) =>
          new Marker(
            width: 80.0,
            height: 80.0,
            point: new LatLng(markers.latitude, markers.longitude),
            builder: (ctx) =>
            new Container(
              child: markers._nome == "Você" ?
                 Icon(Icons.person_pin_circle,size: 40,color: Colors.indigo)
                    :
              IconButton(
                  icon: Icon(Icons.location_on,size: 40, color: Colors.deepOrange),
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MarkerOpen(marker: markers)),
                    );
                  },
              ),
            ),
          ),
          ).toList()
        ),
      ],
    ),
    );
  }
}

class MarkerOpen extends StatefulWidget {
  MarkerOpen({Key key, this.marker}) : super(key: key);

  Markers marker;

  @override
  _MarkerOpenState createState() => _MarkerOpenState(marker: marker);
}

class _MarkerOpenState extends State<MarkerOpen> {
  _MarkerOpenState({Key key, this.marker});

  Markers marker;
  String barcode = "";

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException{
      setState(() => this.barcode = '');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){Navigator.pop(context);}),
        title: Text(marker.nome),
        
      ),
      body:SafeArea(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 00),
                children: <Widget>[
                  Padding(
                   padding: EdgeInsets.only(top: 10),
                    child: new Image.asset(marker._pathFoto, height: 200),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 60),
                    child: MaterialButton(
                        minWidth: 275,
                        color: Color(0xFFfa9015),
                        height: 50,
                        elevation: 4,
                        child: Text(
                          "Ler QRCode",
                          style:
                          TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                        onPressed: () {
                          scan();
                        }),
                  ),
                  new Text(barcode),

                ],
              )),

    );

  }

}

class Markers {
  double _latitude;
  double _longitude;
  String _nome;
  String _pathFoto;

  Markers(this._latitude,this._longitude, this._nome, this._pathFoto);

  double get latitude => _latitude;
  double get longitude => _longitude;
  String get nome => _nome;
  String get pathFoto => _pathFoto;
}
