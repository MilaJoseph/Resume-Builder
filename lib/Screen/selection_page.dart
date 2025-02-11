import 'package:flutter/material.dart';
import 'basicdetails.dart';
import 'saved_resume.dart';

class SelectionPage extends StatelessWidget {
  const SelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resume Builder')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BasicDetailsPage()),
                );
              },
              child: const Text('Create Resume'),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SavedResumesPage()),
                );
              },
              child: const Text('Saved Resumes'),
            ),
          ],
        ),
      ),
    );
  }
}
