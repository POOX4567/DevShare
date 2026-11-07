import 'package:flutter/material.dart';

import '../sections/mockup_pages.dart';
import 'home_feed.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) => _index == 0
      ? HomeFeed(onNavigate: (index) => setState(() => _index = index))
      : MockupPage(
          index: _index,
          onNavigate: (index) => setState(() => _index = index),
        );
}
