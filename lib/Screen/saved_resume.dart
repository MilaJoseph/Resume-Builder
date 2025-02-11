import 'package:flutter/material.dart';

class SavedResumesPage extends StatelessWidget {
  const SavedResumesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Resumes')),
      body: const Center(
        child: Text('List of saved resumes will appear here'),
      ),
    );
  }
}
