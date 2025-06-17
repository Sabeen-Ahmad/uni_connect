import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uni_connect/request_screen/auth/welcome_screen.dart';
import 'dart:convert';

import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cellNoController = TextEditingController();
  final _shiftController = TextEditingController();
  final _degreeController = TextEditingController();

  bool _isLoading = false;

  Future<void> signup() async {
    setState(() => _isLoading = true);

    final url = Uri.parse('https://devtechtop.com/store/public/insert_user');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'cell_no': _cellNoController.text,
        'shift': _shiftController.text,
        'degree': _degreeController.text,
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup successful')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: ${response.body}')),
      );
    }
  }

  Widget buildTextField(
      {required String label,
        required IconData icon,
        required TextEditingController controller,
        bool isPassword = false,
        TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>WelcomeScreen()));}, icon: Icon(Icons.arrow_back,
    ),)),

      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const SizedBox(height: 24),
            buildTextField(
              label: 'Full Name',
              icon: Icons.person,
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            buildTextField(
              label: 'Email',
              icon: Icons.email,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            buildTextField(
              label: 'Password',
              icon: Icons.lock,
              controller: _passwordController,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            buildTextField(
              label: 'Cell No',
              icon: Icons.phone,
              controller: _cellNoController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            buildTextField(
              label: 'Shift (Morning/Evening)',
              icon: Icons.access_time,
              controller: _shiftController,
            ),
            const SizedBox(height: 16),
            buildTextField(
              label: 'Degree',
              icon: Icons.school,
              controller: _degreeController,
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: signup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Signup', style: TextStyle(fontSize: 18,color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
