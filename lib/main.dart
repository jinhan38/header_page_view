import 'package:flutter/material.dart';
import 'package:header_page_view/header_page_view_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: HeaderPageViewScreen(
          pageController: PageController(),
          header: [
            Container(
              height: 100,
              width: double.infinity,
              color: Colors.blue,
            ),
            Container(
              height: 100,
              width: double.infinity,
              color: Colors.green,
            ),
            Container(
              height: 100,
              width: double.infinity,
              color: Colors.purple,
            ),
            Container(
              height: 100,
              width: double.infinity,
              color: Colors.blue,
            ),
            Container(
              height: 100,
              width: double.infinity,
              color: Colors.green,
            ),
            Container(
              height: 100,
              width: double.infinity,
              color: Colors.purple,
            ),
          ],
          // tabHeight: 50,
          tabWidget:
              List.generate(4, (index) => Center(child: SizedBox(
                  height: 50,
                  child: Center(child: Text("$index 아이템"))))),
          indicatorWidget: Container(color: Colors.red.shade300),
          pageViewLists: [
            _pageViewItem(),
            _pageViewItem(),
            _pageViewItem(),
            _pageViewItem(),
          ],
          // headerHeight: 600,
        ),
      ),
    );
  }

  Widget _pageViewItem() {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: List.generate(
        30,
        (index) => SizedBox(
          width: double.infinity,
          height: 50,
          child: Text(index.toString()),
        ),
      ),
    );
  }
}
