import 'package:flutter/material.dart';

void main() {
  runApp(const MyWidget());
}
final mc = Colors.lightGreenAccent;
final tc = Colors.black87;

final a = ["사고등록", "사고현황", "통계"];
final controller = PageController(initialPage: 0);
int i = 0;

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text(a[i], style: TextStyle(color: tc, fontWeight: FontWeight.w700),) ,backgroundColor: Colors.lightGreenAccent, centerTitle: true, leading: Icon(Icons.account_box_rounded,color: tc,)),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: i,
          selectedItemColor: mc.shade400,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.edit), label: "사고등록"),
            BottomNavigationBarItem(
                icon: Icon(Icons.car_crash), label: "사고현황"),
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
            Container(
              color: Colors.blue,
            ),
            Container(
              color: Colors.green,
            ),
            Container(
              color: Colors.red,
            )
          ],
        ),
      ),
    );
    ;
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
