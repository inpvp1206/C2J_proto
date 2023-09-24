import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/gestures.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var _markers_pannel = [];
var _markers_accidendt = [];

void main() async {
  runApp(const MyWidget());
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

final a = ["사고등록", "사고현황", "통계"];
final controller = PageController(initialPage: 0);
int i = 0;
int s = 0;

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
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
    return MaterialApp(
      home: Scaffold(
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
          onTap: (value) {},
          selectedItemColor: mc.shade400,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.edit), label: "사고등록"),
            BottomNavigationBarItem(icon: Icon(Icons.car_crash), label: "사고현황"),
            BottomNavigationBarItem(icon: Icon(Icons.attach_file), label: "통계"),
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
                  SizedBox(
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
                                } else {}
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
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.8,
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
                  Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: mc, width: 8)),
                    ),
                    height: 400,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Input',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Input',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Input',
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              color: Colors.red,
            )
          ],
        ),
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
