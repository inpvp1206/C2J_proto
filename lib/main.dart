import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

var _markers_pannel = [];
var _markers_accidendt = [];
var ac = [];

initacview(ds) async {
  ac_action = ds["action"];
  ac_cause = ds["cause"];
  ac_current = ds["current"];
  ac_time = ds["time"];
}

String ac_action = "";
String ac_cause = "";
String ac_current = "";
Timestamp ac_time = Timestamp.now();
void main() async {
  runApp(MaterialApp(
    home: MyWidget(),
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

final tc1 = TextEditingController();
final tc2 = TextEditingController();
final tc3 = TextEditingController();

LatLng ps = LatLng(34.958453, 127.687787);
Location location = new Location();

final mc = Colors.lightGreenAccent;
final tc = Colors.black87;

final a = ["사고등록", "사고현황", "신고"];
final controller = PageController(initialPage: 0);
int i = 0;
int s = 0;
double dis = 0;

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

initdistance(a, b) async {
  dis = await Geolocator.distanceBetween(
      a.latitude, a.longitude, b.latitude, b.longitude);
}

LocationData? _locationData;

class _MyWidgetState extends State<MyWidget> {
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(34.954453, 127.687787),
    zoom: 14.4746,
  );
  final _controller = Completer<GoogleMapController>();
  Map<MarkerId, Marker> acmarkers = <MarkerId, Marker>{};
  Map<MarkerId, Marker> pnmarkers = <MarkerId, Marker>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            a[i],
            style: TextStyle(color: tc, fontWeight: FontWeight.w700),
          ),
          backgroundColor: Colors.lightGreenAccent,
          centerTitle: true,
          leading: Icon(
            Icons.account_box_rounded,
            color: tc,
          )),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: i,
        onTap: (value) {
          controller.animateToPage(value,
              duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
          i = value;
        },
        selectedItemColor: mc.shade400,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: "사고등록",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.car_crash), label: "사고현황"),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: "신고"),
        ],
      ),
      body: PageView(
        onPageChanged: (int page) {
          setState(() {
            i = page.toInt();
          });
        },
        controller: controller,
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Hero(
                  tag: 1,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.width * 0.8,
                    child: GoogleMap(
                      markers: Set<Marker>.of(pnmarkers.values),
                      circles: Set.from([
                        Circle(
                            circleId: CircleId("1"),
                            center: ps,
                            radius: 800,
                            fillColor: Colors.red.withOpacity(0.3),
                            strokeWidth: 5,
                            strokeColor: Colors.red.shade700)
                      ]),
                      gestureRecognizers:
                          <Factory<OneSequenceGestureRecognizer>>[
                        new Factory<OneSequenceGestureRecognizer>(
                          () => new EagerGestureRecognizer(),
                        ),
                      ].toSet(),
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      initialCameraPosition: _kGooglePlex,
                      onMapCreated: (GoogleMapController controller) async {
                        if (s == 0) {
                          _controller.complete(controller);
                          _locationData = await location.getLocation();

                          setState(() {
                            ps = LatLng(_locationData!.latitude!.toDouble(),
                                _locationData!.longitude!.toDouble());
                            controller
                                .animateCamera(CameraUpdate.newLatLng(ps));
                          });
                        }
                        initpnMarker(pannel, pannel_id) async {
                          var pnmarkeridval = pannel_id;
                          final MarkerId pnmarkerId = MarkerId(pnmarkeridval);
                          final Marker pnmarker = Marker(
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueGreen),
                              markerId: pnmarkerId,
                              position: LatLng(pannel['loca'].latitude,
                                  pannel['loca'].longitude),
                              infoWindow: InfoWindow(
                                title: pannel['loca_t'],
                              ));
                          setState(() {
                            pnmarkers[pnmarkerId] = pnmarker;
                          });
                        }

                        FirebaseFirestore.instance
                            .collection('marker_pannel')
                            .get()
                            .then((docs) {
                          if (docs.docs.isNotEmpty) {
                            _markers_pannel = [];
                            for (int i = 0; i < docs.docs.length; ++i) {
                              _markers_pannel.add(docs.docs[i].data());
                              initpnMarker(
                                  docs.docs[i].data(), docs.docs[i].id);
                            }
                          }
                        });

                        s = 1;
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: mc, width: 8)),
                  ),
                  height: 400,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
                        child: TextField(
                          controller: tc1,
                          decoration: InputDecoration(
                            hintText: "폭우",
                            filled: true,
                            fillColor: mc.shade100,
                            focusColor: mc.shade200,
                            border: UnderlineInputBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(8))),
                            labelText: '사고 원인',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextField(
                          controller: tc2,
                          decoration: InputDecoration(
                            hintText: "전복 됨",
                            filled: true,
                            fillColor: mc.shade100,
                            focusColor: mc.shade200,
                            border: UnderlineInputBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(8))),
                            labelText: '사고 현황',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextField(
                          controller: tc3,
                          decoration: InputDecoration(
                            hintText: "차량우회",
                            filled: true,
                            fillColor: mc.shade100,
                            focusColor: mc.shade200,
                            border: UnderlineInputBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(8))),
                            labelText: '행동 사항',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                primary: mc, elevation: 10),
                            onPressed: () {
                              if (tc1.text.isNotEmpty &&
                                  tc2.text.isNotEmpty &&
                                  tc3.text.isNotEmpty) {
                                FirebaseFirestore.instance
                                    .collection('marker_accident')
                                    .add({
                                  "cause": tc1.text,
                                  "current": tc2.text,
                                  "action": tc3.text,
                                  "loca": GeoPoint(ps.latitude, ps.longitude),
                                  "time": Timestamp.now()
                                });
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        iconColor: mc,
                                        icon: Icon(Icons.check),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        title: Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                            '당신의 사고가 등록되었습니다',
                                          ),
                                        ),
                                        content: Container(
                                          height: 50,
                                          alignment: Alignment.center,
                                          child: Text(
                                              "주변사람들이 당신의 사고를\n열람할 수 있습니다."),
                                        ),
                                        actions: [
                                          InkWell(
                                            child: Center(
                                              child: TextButton(
                                                child: Text(
                                                  '확인',
                                                  style: TextStyle(
                                                      color: mc, fontSize: 20),
                                                  textAlign: TextAlign.center,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ),
                                          )
                                        ],
                                      );
                                    });
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        iconColor: mc,
                                        icon: Icon(Icons.not_interested),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        title: Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                            '당신의 사고가\n등록되지 않았습니다',
                                          ),
                                        ),
                                        content: Container(
                                          height: 20,
                                          alignment: Alignment.center,
                                          child: Text("입력박스를 한번 더 확인 해 주세요."),
                                        ),
                                        actions: [
                                          InkWell(
                                            child: Center(
                                              child: TextButton(
                                                child: Text(
                                                  '확인',
                                                  style: TextStyle(
                                                      color: mc, fontSize: 20),
                                                  textAlign: TextAlign.center,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ),
                                          )
                                        ],
                                      );
                                    });
                              }
                            },
                            icon: Icon(Icons.upload),
                            label: Text('전송')),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Hero(
                  tag: 1,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: GoogleMap(
                      markers: Set<Marker>.of(acmarkers.values),
                      circles: Set.from([
                        Circle(
                            circleId: CircleId("1"),
                            center: ps,
                            radius: 800,
                            fillColor: mc.withOpacity(0.3),
                            strokeWidth: 5,
                            strokeColor: mc.shade700)
                      ]),
                      gestureRecognizers:
                          <Factory<OneSequenceGestureRecognizer>>[
                        new Factory<OneSequenceGestureRecognizer>(
                          () => new EagerGestureRecognizer(),
                        ),
                      ].toSet(),
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      initialCameraPosition: _kGooglePlex,
                      onMapCreated: (GoogleMapController controller) async {
                        if (s == 0) {
                          _controller.complete(controller);
                          _locationData = await location.getLocation();

                          setState(() {
                            ps = LatLng(_locationData!.latitude!.toDouble(),
                                _locationData!.longitude!.toDouble());
                            controller
                                .animateCamera(CameraUpdate.newLatLng(ps));
                          });
                        }
                        initacMarker(accident, accident_id) async {
                          var markeridval = accident_id;
                          final MarkerId acmarkerId = MarkerId(markeridval);
                          final Marker acmarker = Marker(
                              onTap: () {
                                print("");
                                print("");
                                print("Marker pressed");
                                print("");
                                print("");

                                FirebaseFirestore.instance
                                    .collection("marker_accident")
                                    .doc(accident_id)
                                    .get()
                                    .then((DocumentSnapshot ds) async {
                                  await initacview(ds);
                                });
                                sleep(Duration(milliseconds: 300));

                                showModalBottomSheet(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        height: 350,
                                        child: ListView(
                                            padding: EdgeInsets.all(20),
                                            children: [
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Container(
                                                clipBehavior: Clip.antiAlias,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(blurRadius: 8)
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .horizontal(
                                                                left: Radius
                                                                    .circular(
                                                                        10)),
                                                        color: mc.shade200,
                                                      ),
                                                      width: 80,
                                                      height: 80,
                                                      child:
                                                          Icon(Icons.car_crash),
                                                    ),
                                                    Container(
                                                        height: 80,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            120,
                                                        color: Colors.white,
                                                        child: Center(
                                                          child: Text(
                                                            "사고 원인 : $ac_cause",
                                                            style: TextStyle(
                                                                fontSize: 25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Container(
                                                clipBehavior: Clip.antiAlias,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(blurRadius: 8)
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .horizontal(
                                                                left: Radius
                                                                    .circular(
                                                                        10)),
                                                        color: mc.shade200,
                                                      ),
                                                      width: 80,
                                                      height: 80,
                                                      child:
                                                          Icon(Icons.timelapse),
                                                    ),
                                                    Container(
                                                        height: 80,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            120,
                                                        color: Colors.white,
                                                        child: Center(
                                                          child: Text(
                                                            "사고 현황 : $ac_current",
                                                            style: TextStyle(
                                                                fontSize: 25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Container(
                                                clipBehavior: Clip.antiAlias,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(blurRadius: 8)
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .horizontal(
                                                                left: Radius
                                                                    .circular(
                                                                        10)),
                                                        color: mc.shade200,
                                                      ),
                                                      width: 80,
                                                      height: 80,
                                                      child: Icon(
                                                          Icons.front_hand),
                                                    ),
                                                    Container(
                                                        height: 80,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            120,
                                                        color: Colors.white,
                                                        child: Center(
                                                          child: Text(
                                                            "행동 사항 : $ac_action",
                                                            style: TextStyle(
                                                                fontSize: 25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            ]),
                                      );
                                    });
                              },
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueAzure),
                              markerId: acmarkerId,
                              position: LatLng(accident['loca'].latitude,
                                  accident['loca'].longitude),
                              infoWindow: InfoWindow(
                                title: accident['current'],
                              ));
                          setState(() {
                            acmarkers[acmarkerId] = acmarker;
                          });
                        }

                        FirebaseFirestore.instance
                            .collection('marker_accident')
                            .get()
                            .then((docs) {
                          if (docs.docs.isNotEmpty) {
                            _markers_accidendt = [];
                            for (int i = 0; i < docs.docs.length; ++i) {
                              _markers_accidendt.add(docs.docs[i].data());
                              initacMarker(
                                  docs.docs[i].data(), docs.docs[i].id);
                            }
                          }
                        });

                        s = 1;
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: mc, width: 8)),
                  ),
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    opacity: 0.7,
                    image: AssetImage('assets/limes.jpg'),
                    fit: BoxFit.cover)),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 50),
                  InkWell(
                    onTap: () => launchUrl(Uri.parse("tel:112")),
                    child: GlassmorphicContainer(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "112",
                              style: TextStyle(
                                  fontSize: 50, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text("심한 교통사고를\n신고하세요.",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w700))
                          ],
                        ),
                      ),
                      borderGradient: LinearGradient(colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.8)
                      ]),
                      blur: 10,
                      width: MediaQuery.of(context).size.width - 80,
                      height: 150,
                      borderRadius: 20,
                      border: 3,
                      linearGradient: LinearGradient(colors: [
                        Colors.blueAccent.shade200.withOpacity(0.5),
                        Colors.blueAccent.withOpacity(0.3)
                      ]),
                    ),
                  ),
                  SizedBox(height: 50),
                  InkWell(
                    onTap: () => launchUrl(Uri.parse("tel:119")),
                    child: GlassmorphicContainer(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "119",
                              style: TextStyle(
                                  fontSize: 50, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text("교통사고와 동반된\n화재가 있다면 신고하세요.",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700))
                          ],
                        ),
                      ),
                      borderGradient: LinearGradient(colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.8)
                      ]),
                      blur: 10,
                      width: MediaQuery.of(context).size.width - 80,
                      height: 150,
                      borderRadius: 20,
                      border: 3,
                      linearGradient: LinearGradient(colors: [
                        Colors.redAccent.shade200.withOpacity(0.5),
                        Colors.redAccent.withOpacity(0.3)
                      ]),
                    ),
                  ),
                  SizedBox(height: 50),
                  InkWell(
                    onTap: () => launchUrl(Uri.parse("tel:110")),
                    child: GlassmorphicContainer(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "110",
                              style: TextStyle(
                                  fontSize: 50, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text("교통사고 유발과 관련한\n민원사항을 신고하세요.",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700))
                          ],
                        ),
                      ),
                      borderGradient: LinearGradient(colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.8)
                      ]),
                      blur: 10,
                      width: MediaQuery.of(context).size.width - 80,
                      height: 150,
                      borderRadius: 20,
                      border: 3,
                      linearGradient: LinearGradient(colors: [
                        Colors.greenAccent.shade200.withOpacity(0.5),
                        Colors.greenAccent.withOpacity(0.3)
                      ]),
                    ),
                  ),
                  SizedBox(height: 70)
                ]),
          )
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

int b = controller.page!.toInt();
