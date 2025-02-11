import 'package:flutter/material.dart';

class BasicDetailsPage extends StatefulWidget {
  const BasicDetailsPage({super.key});

  @override
  _BasicDetailsPageState createState() => _BasicDetailsPageState();
}

class _BasicDetailsPageState extends State<BasicDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _languagesController = TextEditingController();

  bool _isEditing = false; // Flag to toggle between edit and preview modes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Resume')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Contact Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Name field
              TextFormField(
                controller: _nameController,
                enabled: _isEditing, // Toggle edit mode
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 15),

              // Address field
              TextFormField(
                controller: _addressController,
                enabled: _isEditing, // Toggle edit mode
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Enter your address' : null,
              ),
              const SizedBox(height: 15),

              // Email field
              TextFormField(
                controller: _emailController,
                enabled: _isEditing, // Toggle edit mode
                decoration: const InputDecoration(
                  labelText: 'Email ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter your email ID';
                  } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Enter a valid email ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // LinkedIn Profile field (optional)
              TextFormField(
                controller: _linkedinController,
                enabled: _isEditing, // Toggle edit mode
                decoration: const InputDecoration(
                  labelText: 'LinkedIn Profile (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              // GitHub Profile field (optional)
              TextFormField(
                controller: _githubController,
                enabled: _isEditing, // Toggle edit mode
                decoration: const InputDecoration(
                  labelText: 'GitHub Profile (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              // Languages field
              TextFormField(
                controller: _languagesController,
                enabled: _isEditing, // Toggle edit mode
                decoration: const InputDecoration(
                  labelText: 'Languages',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Enter languages you know' : null,
              ),
              const SizedBox(height: 20),

              // Edit or Continue buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Edit Button
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = !_isEditing; // Toggle editing mode
                      });
                    },
                    child: Text(_isEditing ? 'Save' : 'Edit'),
                  ),
                  // Continue Button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Continue to the next page (navigate to next screen)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NextPage(), // Replace with the next page
                          ),
                        );
                      }
                    },
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Next Page')),
      body: const Center(
        child: Text('You have successfully created your resume!'),
      ),
    );
  }
}
