import 'package:flutter/material.dart';
import 'community_page.dart';
import 'courses_page.dart';
import 'messages_page.dart';
import 'profile_page.dart';

class MockupPage extends StatelessWidget {
  const MockupPage({super.key, required this.index, required this.onNavigate});
  final int index;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) => switch (index) {
        1 => CommunityPage(onNavigate: onNavigate),
        2 => CoursesPage(onNavigate: onNavigate),
        3 => MessagesPage(onNavigate: onNavigate),
        4 => ProfilePage(onNavigate: onNavigate),
        _ => const SizedBox.shrink(),
      };
}
