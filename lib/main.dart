import 'package:flutter/material.dart';

void main() {
  runApp(const MyWidget());
}

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
        appBar: AppBar(title: Text(a[i])),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: i,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.abc), label: "사고등록"),
            BottomNavigationBarItem(
                icon: Icon(Icons.baby_changing_station), label: "사고현황"),
            BottomNavigationBarItem(icon: Icon(Icons.cabin), label: "통계"),
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
