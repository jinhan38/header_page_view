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
      title: 'Header PageView',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
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
        child: HeaderPageView(
          useTabBar: false,
          pageController: PageController(),
          // header: _header(),
          tabWidget: List.generate(
              4,
              (index) => Center(
                  child: SizedBox(
                      height: 70, child: Center(child: Text(_test(index)))))),
          indicatorWidget: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(height: 5, color: Colors.red.shade300),
            ],
          ),
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

  String _test(int index) {
    if (index == 0) {
      return "aaaa";
    } else if (index == 1) {
      return "kfkfkfkfkfkfk";
    }
    return index.toString();
  }

  List<Widget> _header() {
    return [
      Container(
        height: 100,
        color: Colors.blue,
      ),
      Container(
        height: 100,
        color: Colors.green,
      ),
      Container(
        height: 100,
        color: Colors.purple,
      ),
    ];
  }

  Widget _pageViewItem() {
    return Column(
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
