/* correct one without ai

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'resume_selection.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isEditing = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _technologyController = TextEditingController();
  final TextEditingController _awardController = TextEditingController();
  final TextEditingController _certificateController = TextEditingController();

  List<Map<String, dynamic>> projects = [];
  List<String> awards = [];
  List<String> certificates = [];

  void _addProject() {
    if (_isEditing &&
        _titleController.text.isNotEmpty &&
        _roleController.text.isNotEmpty &&
        _technologyController.text.isNotEmpty) {
      setState(() {
        projects.add({
          'title': _titleController.text,
          'role': _roleController.text,
          'technologies': _technologyController.text.split(','),
        });
        _titleController.clear();
        _roleController.clear();
        _technologyController.clear();
      });
      _saveProjectsData();
    }
  }

  void _addAward() {
    if (_isEditing && _awardController.text.isNotEmpty) {
      setState(() {
        awards.add(_awardController.text);
        _awardController.clear();
      });
      _saveProjectsData();
    }
  }

  void _addCertificate() {
    if (_isEditing && _certificateController.text.isNotEmpty) {
      setState(() {
        certificates.add(_certificateController.text);
        _certificateController.clear();
      });
      _saveProjectsData();
    }
  }

  void _deleteProject(int index) {
    setState(() {
      projects.removeAt(index);
    });
    _saveProjectsData();
  }

  void _deleteAward(int index) {
    setState(() {
      awards.removeAt(index);
    });
    _saveProjectsData();
  }

  void _deleteCertificate(int index) {
    setState(() {
      certificates.removeAt(index);
    });
    _saveProjectsData();
  }

  @override
  void initState() {
    super.initState();
    _fetchProjectsData();
  }

  Future<void> _fetchProjectsData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(user.uid).get();
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        projects = List<Map<String, dynamic>>.from(data['projects'] ?? []);
        awards = List<String>.from(data['awards'] ?? []);
        certificates = List<String>.from(data['certificates'] ?? []);
      });
    }
  }

  Future<void> _saveProjectsData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'projects': projects,
      'awards': awards,
      'certificates': certificates,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD6E2E3), Color(0xFFB7C4C6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderText('PROJECTS'),
                  _buildInputField('Title', _titleController),
                  _buildInputField('Role', _roleController),
                  _buildInputField('Technologies/Tools used (comma-separated)',
                      _technologyController),
                  const SizedBox(height: 10),
                  if (_isEditing) _buildAddButton('Add Project', _addProject),
                  const SizedBox(height: 20),
                  _buildProjectsList(),
                  const SizedBox(height: 20),
                  _buildHeaderText('AWARDS/ACHIEVEMENTS'),
                  _buildInputField('Award/Achievement', _awardController),
                  const SizedBox(height: 10),
                  if (_isEditing) _buildAddButton('Add Award', _addAward),
                  const SizedBox(height: 20),
                  _buildAwardsList(),
                  const SizedBox(height: 20),
                  _buildHeaderText('CERTIFICATES'),
                  _buildInputField('Certificate', _certificateController),
                  const SizedBox(height: 10),
                  if (_isEditing)
                    _buildAddButton('Add Certificate', _addCertificate),
                  const SizedBox(height: 20),
                  _buildCertificatesList(),
                  const SizedBox(height: 20),
                  _buildBottomButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButton(_isEditing ? 'Save' : 'Edit', () {
          setState(() {
            _isEditing = !_isEditing;
          });
        }),
        _buildButton('Continue', () async {
          if (!_isEditing) {
            /* User? user = _auth.currentUser;
            if (user != null) {
              DocumentSnapshot snapshot =
                  await _firestore.collection('users').doc(user.uid).get();
              if (snapshot.exists) {
                Map<String, dynamic> userData =
                    snapshot.data() as Map<String, dynamic>;*/
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResumeSelectionScreen(),
              ),
            );
          }
        }),
      ],
    );
  }

  Widget _buildHeaderText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Times New Roman',
          color: Color(0xFF184D47),
        ),
      ),
    );
  }

  Widget _buildInputField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: _isEditing ? Colors.white : Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black),
        ),
        child: TextField(
          controller: controller,
          enabled: _isEditing,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF184D47),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child:
          Text(text, style: const TextStyle(fontSize: 16, color: Colors.white)),
    );
  }

  Widget _buildProjectsList() {
    return projects.isEmpty
        ? const Text('No projects added.', style: TextStyle(fontSize: 16))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: projects.asMap().entries.map((entry) {
              int index = entry.key;
              var project = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(
                    project['title'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Role: ${project['role']}'),
                      Text(
                          'Technologies: ${project['technologies'].join(', ')}'),
                    ],
                  ),
                  trailing: _isEditing
                      ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProject(index),
                        )
                      : null,
                ),
              );
            }).toList(),
          );
  }

  Widget _buildAwardsList() {
    return awards.isEmpty
        ? const Text('No awards added.', style: TextStyle(fontSize: 16))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: awards.asMap().entries.map((entry) {
              int index = entry.key;
              var award = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(
                    award,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  trailing: _isEditing
                      ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAward(index),
                        )
                      : null,
                ),
              );
            }).toList(),
          );
  }

  Widget _buildCertificatesList() {
    return certificates.isEmpty
        ? const Text('No certificates added.', style: TextStyle(fontSize: 16))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: certificates.asMap().entries.map((entry) {
              int index = entry.key;
              var certificate = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(
                    certificate,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  trailing: _isEditing
                      ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCertificate(index),
                        )
                      : null,
                ),
              );
            }).toList(),
          );
  }

  /// Added `_buildButton` method
  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF184D47),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'summary_page.dart';
import 'resume_selection.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isEditing = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _technologyController = TextEditingController();
  final TextEditingController _awardController = TextEditingController();
  final TextEditingController _certificateController = TextEditingController();

  List<Map<String, dynamic>> projects = [];
  List<String> awards = [];
  List<String> certificates = [];

  void _addProject() {
    if (_isEditing &&
        _titleController.text.isNotEmpty &&
        _roleController.text.isNotEmpty &&
        _technologyController.text.isNotEmpty) {
      setState(() {
        projects.add({
          'title': _titleController.text,
          'role': _roleController.text,
          'technologies': _technologyController.text.split(','),
        });
        _titleController.clear();
        _roleController.clear();
        _technologyController.clear();
      });
      _saveProjectsData();
    }
  }

  void _addAward() {
    if (_isEditing && _awardController.text.isNotEmpty) {
      setState(() {
        awards.add(_awardController.text);
        _awardController.clear();
      });
      _saveProjectsData();
    }
  }

  void _addCertificate() {
    if (_isEditing && _certificateController.text.isNotEmpty) {
      setState(() {
        certificates.add(_certificateController.text);
        _certificateController.clear();
      });
      _saveProjectsData();
    }
  }

  void _deleteProject(int index) {
    setState(() {
      projects.removeAt(index);
    });
    _saveProjectsData();
  }

  void _deleteAward(int index) {
    setState(() {
      awards.removeAt(index);
    });
    _saveProjectsData();
  }

  void _deleteCertificate(int index) {
    setState(() {
      certificates.removeAt(index);
    });
    _saveProjectsData();
  }

  @override
  void initState() {
    super.initState();
    _fetchProjectsData();
  }

  Future<void> _fetchProjectsData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(user.uid).get();
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        projects = List<Map<String, dynamic>>.from(data['projects'] ?? []);
        awards = List<String>.from(data['awards'] ?? []);
        certificates = List<String>.from(data['certificates'] ?? []);
      });
    }
  }

  Future<void> _saveProjectsData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'projects': projects,
      'awards': awards,
      'certificates': certificates,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD6E2E3), Color(0xFFB7C4C6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderText('PROJECTS'),
                  _buildInputField('Title', _titleController),
                  _buildInputField('Role', _roleController),
                  _buildInputField('Technologies/Tools used (comma-separated)',
                      _technologyController),
                  const SizedBox(height: 10),
                  if (_isEditing) _buildAddButton('Add Project', _addProject),
                  const SizedBox(height: 20),
                  _buildProjectsList(),
                  const SizedBox(height: 20),
                  _buildHeaderText('AWARDS/ACHIEVEMENTS'),
                  _buildInputField('Award/Achievement', _awardController),
                  const SizedBox(height: 10),
                  if (_isEditing) _buildAddButton('Add Award', _addAward),
                  const SizedBox(height: 20),
                  _buildAwardsList(),
                  const SizedBox(height: 20),
                  _buildHeaderText('CERTIFICATES'),
                  _buildInputField('Certificate', _certificateController),
                  const SizedBox(height: 10),
                  if (_isEditing)
                    _buildAddButton('Add Certificate', _addCertificate),
                  const SizedBox(height: 20),
                  _buildCertificatesList(),
                  const SizedBox(height: 20),
                  _buildBottomButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButton(_isEditing ? 'Save' : 'Edit', () {
          setState(() {
            _isEditing = !_isEditing;
          });
        }),
        _buildButton('Continue', () async {
          if (!_isEditing) {
            /* User? user = _auth.currentUser;
            if (user != null) {
              DocumentSnapshot snapshot =
                  await _firestore.collection('users').doc(user.uid).get();
              if (snapshot.exists) {
                Map<String, dynamic> userData =
                    snapshot.data() as Map<String, dynamic>;*/
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const GenerateSummaryPage()),
            );
          }
        }),
      ],
    );
  }

  Widget _buildHeaderText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Times New Roman',
          color: Color(0xFF184D47),
        ),
      ),
    );
  }

  Widget _buildInputField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: _isEditing ? Colors.white : Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black),
        ),
        child: TextField(
          controller: controller,
          enabled: _isEditing,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF184D47),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child:
          Text(text, style: const TextStyle(fontSize: 16, color: Colors.white)),
    );
  }

  Widget _buildProjectsList() {
    return projects.isEmpty
        ? const Text('No projects added.', style: TextStyle(fontSize: 16))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: projects.asMap().entries.map((entry) {
              int index = entry.key;
              var project = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(
                    project['title'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Role: ${project['role']}'),
                      Text(
                          'Technologies: ${project['technologies'].join(', ')}'),
                    ],
                  ),
                  trailing: _isEditing
                      ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProject(index),
                        )
                      : null,
                ),
              );
            }).toList(),
          );
  }

  Widget _buildAwardsList() {
    return awards.isEmpty
        ? const Text('No awards added.', style: TextStyle(fontSize: 16))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: awards.asMap().entries.map((entry) {
              int index = entry.key;
              var award = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(
                    award,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  trailing: _isEditing
                      ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAward(index),
                        )
                      : null,
                ),
              );
            }).toList(),
          );
  }

  Widget _buildCertificatesList() {
    return certificates.isEmpty
        ? const Text('No certificates added.', style: TextStyle(fontSize: 16))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: certificates.asMap().entries.map((entry) {
              int index = entry.key;
              var certificate = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(
                    certificate,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  trailing: _isEditing
                      ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCertificate(index),
                        )
                      : null,
                ),
              );
            }).toList(),
          );
  }

  /// Added `_buildButton` method
  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF184D47),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'resume_selection.dart'; // Replace with your actual import

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isEditing = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _technologyController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _awardController = TextEditingController();
  final TextEditingController _certificateController = TextEditingController();

  List<Map<String, dynamic>> projects = [];
  List<String> awards = [];
  List<String> certificates = [];

  @override
  void initState() {
    super.initState();
    _fetchProjectsData();
  }

  Future<void> _fetchProjectsData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(user.uid).get();
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        projects = List<Map<String, dynamic>>.from(data['projects'] ?? []);
        awards = List<String>.from(data['awards'] ?? []);
        certificates = List<String>.from(data['certificates'] ?? []);
      });
    }
  }

  Future<void> _saveProjectsData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'projects': projects,
      'awards': awards,
      'certificates': certificates,
    }, SetOptions(merge: true));
  }

  Future<void> _generateAIText() async {
    try {
      // Collect project details
      final title = _titleController.text;
      final role = _roleController.text;
      final technologies = _technologyController.text;

      // Create a prompt based on project details
      final prompt =
          "Write a short and professional project description for a project titled '$title'. "
          "His/Her role was '$role', and the technologies they used were $technologies."
          "Provide a detailed, structured response and real-world applications.";

      final url = Uri.parse(
          'http://192.168.1.7:5000/generate-text'); // Replace with your Flask backend URL
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({'prompt': prompt});

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _descriptionController.text = data['generated_text'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to generate text: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _addProject() {
    if (_isEditing &&
        _titleController.text.isNotEmpty &&
        _roleController.text.isNotEmpty &&
        _technologyController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {
      setState(() {
        projects.add({
          'title': _titleController.text,
          'role': _roleController.text,
          'technologies': _technologyController.text.split(','),
          'description': _descriptionController.text,
        });
        _titleController.clear();
        _roleController.clear();
        _technologyController.clear();
        _descriptionController.clear();
      });
      _saveProjectsData();
    }
  }

  void _addAward() {
    if (_isEditing && _awardController.text.isNotEmpty) {
      setState(() {
        awards.add(_awardController.text);
        _awardController.clear();
      });
      _saveProjectsData();
    }
  }

  void _addCertificate() {
    if (_isEditing && _certificateController.text.isNotEmpty) {
      setState(() {
        certificates.add(_certificateController.text);
        _certificateController.clear();
      });
      _saveProjectsData();
    }
  }

  void _deleteProject(int index) {
    setState(() {
      projects.removeAt(index);
    });
    _saveProjectsData();
  }

  void _deleteAward(int index) {
    setState(() {
      awards.removeAt(index);
    });
    _saveProjectsData();
  }

  void _deleteCertificate(int index) {
    setState(() {
      certificates.removeAt(index);
    });
    _saveProjectsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD6E2E3), Color(0xFFB7C4C6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderText('PROJECTS'),
                  _buildInputField('Title', _titleController),
                  _buildInputField('Role', _roleController),
                  _buildInputField('Technologies/Tools used (comma-separated)',
                      _technologyController),
                  const SizedBox(height: 10),
                  if (_isEditing)
                    ElevatedButton(
                      onPressed: _generateAIText,
                      child: Text('Generate Description',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF184D47),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  const SizedBox(height: 10),
                  _buildInputField('Description', _descriptionController),
                  const SizedBox(height: 10),
                  if (_isEditing) _buildAddButton('Add Project', _addProject),
                  const SizedBox(height: 20),
                  _buildProjectsList(),
                  const SizedBox(height: 20),
                  _buildHeaderText('AWARDS/ACHIEVEMENTS'),
                  _buildInputField('Award/Achievement', _awardController),
                  const SizedBox(height: 10),
                  if (_isEditing) _buildAddButton('Add Award', _addAward),
                  const SizedBox(height: 20),
                  _buildAwardsList(),
                  const SizedBox(height: 20),
                  _buildHeaderText('CERTIFICATES'),
                  _buildInputField('Certificate', _certificateController),
                  const SizedBox(height: 10),
                  if (_isEditing)
                    _buildAddButton('Add Certificate', _addCertificate),
                  const SizedBox(height: 20),
                  _buildCertificatesList(),
                  const SizedBox(height: 20),
                  _buildBottomButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: _isEditing ? Colors.white : Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black),
        ),
        child: TextField(
          controller: controller,
          enabled: _isEditing,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Times New Roman',
          color: Color(0xFF184D47),
        ),
      ),
    );
  }

  Widget _buildAddButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF184D47),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child:
          Text(text, style: const TextStyle(fontSize: 16, color: Colors.white)),
    );
  }

  Widget _buildProjectsList() {
    return projects.isEmpty
        ? const Text('No projects added.', style: TextStyle(fontSize: 16))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: projects.asMap().entries.map((entry) {
              int index = entry.key;
              var project = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(
                    project['title'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Role: ${project['role']}'),
                      Text(
                          'Technologies: ${project['technologies'].join(', ')}'),
                      Text('Description: ${project['description']}'),
                    ],
                  ),
                  trailing: _isEditing
                      ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProject(index),
                        )
                      : null,
                ),
              );
            }).toList(),
          );
  }

  Widget _buildAwardsList() {
    return awards.isEmpty
        ? const Text('No awards added.', style: TextStyle(fontSize: 16))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: awards.asMap().entries.map((entry) {
              int index = entry.key;
              var award = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(
                    award,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  trailing: _isEditing
                      ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAward(index),
                        )
                      : null,
                ),
              );
            }).toList(),
          );
  }

  Widget _buildCertificatesList() {
    return certificates.isEmpty
        ? const Text('No certificates added.', style: TextStyle(fontSize: 16))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: certificates.asMap().entries.map((entry) {
              int index = entry.key;
              var certificate = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(
                    certificate,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  trailing: _isEditing
                      ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCertificate(index),
                        )
                      : null,
                ),
              );
            }).toList(),
          );
  }

  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButton(_isEditing ? 'Save' : 'Edit', () {
          setState(() {
            _isEditing = !_isEditing;
          });
        }),
        _buildButton('Continue', () async {
          if (!_isEditing) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResumeSelectionScreen(),
              ),
            );
          }
        }),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF184D47),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
*/


/* GEMINI AI for projects

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'resume_selection.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isEditing = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _technologyController = TextEditingController();
  final TextEditingController _awardController = TextEditingController();
  final TextEditingController _certificateController = TextEditingController();

  List<Map<String, dynamic>> projects = [];
  List<String> awards = [];
  List<String> certificates = [];

  // Function to call the Flask backend for AI descriptions
  Future<String> _getAIDescription(String input, String type) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.7:5000/generate-description'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'input': input, 'type': type}),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['description'];
    } else {
      throw Exception('Failed to generate description');
    }
  }

  // Modify the _addProject, _addAward, and _addCertificate functions to include AI descriptions
  void _addProject() async {
    if (_isEditing &&
        _titleController.text.isNotEmpty &&
        _roleController.text.isNotEmpty &&
        _technologyController.text.isNotEmpty) {
      // Generate AI description
      String description = await _getAIDescription(
        'Title: ${_titleController.text}, Role: ${_roleController.text}, Technologies: ${_technologyController.text}',
        'project',
      );

      setState(() {
        projects.add({
          'title': _titleController.text,
          'role': _roleController.text,
          'technologies': _technologyController.text.split(','),
          'description': description, // Add AI-generated description
        });
        _titleController.clear();
        _roleController.clear();
        _technologyController.clear();
      });
      _saveProjectsData();
    }
  }

  void _addAward() async {
    if (_isEditing && _awardController.text.isNotEmpty) {
      // Generate AI description
      String description =
          await _getAIDescription(_awardController.text, 'award');

      setState(() {
        awards.add(_awardController.text);
        _awardController.clear();
      });
      _saveProjectsData();
    }
  }

  void _addCertificate() async {
    if (_isEditing && _certificateController.text.isNotEmpty) {
      // Generate AI description
      String description =
          await _getAIDescription(_certificateController.text, 'certificate');

      setState(() {
        certificates.add(_certificateController.text);
        _certificateController.clear();
      });
      _saveProjectsData();
    }
  }

  // Rest of your existing code remains unchanged...
  void _deleteProject(int index) {
    setState(() {
      projects.removeAt(index);
    });
    _saveProjectsData();
  }

  void _deleteAward(int index) {
    setState(() {
      awards.removeAt(index);
    });
    _saveProjectsData();
  }

  void _deleteCertificate(int index) {
    setState(() {
      certificates.removeAt(index);
    });
    _saveProjectsData();
  }

  @override
  void initState() {
    super.initState();
    _fetchProjectsData();
  }

  Future<void> _fetchProjectsData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(user.uid).get();
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        projects = List<Map<String, dynamic>>.from(data['projects'] ?? []);
        awards = List<String>.from(data['awards'] ?? []);
        certificates = List<String>.from(data['certificates'] ?? []);
      });
    }
  }

  Future<void> _saveProjectsData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'projects': projects,
      'awards': awards,
      'certificates': certificates,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD6E2E3), Color(0xFFB7C4C6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderText('PROJECTS'),
                  _buildInputField('Title', _titleController),
                  _buildInputField('Role', _roleController),
                  _buildInputField('Technologies/Tools used (comma-separated)',
                      _technologyController),
                  const SizedBox(height: 10),
                  if (_isEditing) _buildAddButton('Add Project', _addProject),
                  const SizedBox(height: 20),
                  _buildProjectsList(),
                  const SizedBox(height: 20),
                  _buildHeaderText('AWARDS/ACHIEVEMENTS'),
                  _buildInputField('Award/Achievement', _awardController),
                  const SizedBox(height: 10),
                  if (_isEditing) _buildAddButton('Add Award', _addAward),
                  const SizedBox(height: 20),
                  _buildAwardsList(),
                  const SizedBox(height: 20),
                  _buildHeaderText('CERTIFICATES'),
                  _buildInputField('Certificate', _certificateController),
                  const SizedBox(height: 10),
                  if (_isEditing)
                    _buildAddButton('Add Certificate', _addCertificate),
                  const SizedBox(height: 20),
                  _buildCertificatesList(),
                  const SizedBox(height: 20),
                  _buildBottomButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Rest of your existing UI code remains unchanged...
  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButton(_isEditing ? 'Save' : 'Edit', () {
          setState(() {
            _isEditing = !_isEditing;
          });
        }),
        _buildButton('Continue', () async {
          if (!_isEditing) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResumeSelectionScreen(),
              ),
            );
          }
        }),
      ],
    );
  }

  Widget _buildHeaderText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Times New Roman',
          color: Color(0xFF184D47),
        ),
      ),
    );
  }

  Widget _buildInputField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: _isEditing ? Colors.white : Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black),
        ),
        child: TextField(
          controller: controller,
          enabled: _isEditing,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF184D47),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child:
          Text(text, style: const TextStyle(fontSize: 16, color: Colors.white)),
    );
  }

  Widget _buildProjectsList() {
    return projects.isEmpty
        ? const Text('No projects added.', style: TextStyle(fontSize: 16))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: projects.asMap().entries.map((entry) {
              int index = entry.key;
              var project = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(
                    project['title'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Role: ${project['role']}'),
                      Text(
                          'Technologies: ${project['technologies'].join(', ')}'),
                      if (project['description'] != null)
                        Text(
                          'Description: ${project['description']}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                    ],
                  ),
                  trailing: _isEditing
                      ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProject(index),
                        )
                      : null,
                ),
              );
            }).toList(),
          );
  }

  Widget _buildAwardsList() {
    return awards.isEmpty
        ? const Text('No awards added.', style: TextStyle(fontSize: 16))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: awards.asMap().entries.map((entry) {
              int index = entry.key;
              var award = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(
                    award,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  trailing: _isEditing
                      ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAward(index),
                        )
                      : null,
                ),
              );
            }).toList(),
          );
  }

  Widget _buildCertificatesList() {
    return certificates.isEmpty
        ? const Text('No certificates added.', style: TextStyle(fontSize: 16))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: certificates.asMap().entries.map((entry) {
              int index = entry.key;
              var certificate = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(
                    certificate,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  trailing: _isEditing
                      ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCertificate(index),
                        )
                      : null,
                ),
              );
            }).toList(),
          );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF184D47),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
*/