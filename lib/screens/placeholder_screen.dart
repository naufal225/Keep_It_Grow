// screens/placeholder_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final UserModel user;

  const PlaceholderScreen({
    Key? key,
    required this.title,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Color(0xFF3B82F6),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Color(0xFF6B7280),
            ),
            SizedBox(height: 16),
            Text(
              '$title Screen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Under Development',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('User Info:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Name: ${user.name}'),
                    Text('Role: ${user.role}'),
                    Text('Level: ${user.level}'),
                    Text('XP: ${user.xp}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}