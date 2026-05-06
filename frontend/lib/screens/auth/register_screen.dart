import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/api_service.dart';
import 'package:flutter/gestures.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../core/supabase_storage_service.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  List<dynamic> _homes = [];
  int? _selectedHomeId;
  File? _avatarImage;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _fetchHomes();
  }

  void _fetchHomes() async {
    print('DEBUG: Fetching homes for dropdown...');
    final homes = await ApiService.getAllHomes();
    print('DEBUG: Received ${homes.length} homes from API');
    if (mounted) {
      setState(() {
        _homes = homes;
        if (_homes.isNotEmpty) {
          _selectedHomeId = _homes[0]['id'];
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _avatarImage = File(image.path);
      });
    }
  }

  void _register(String role) async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if ((role == 'caretaker' || role == 'admin') && _selectedHomeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an old age home')));
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    setState(() {
      _isUploadingAvatar = true;
    });

    String? avatarUrl;
    if (_avatarImage != null) {
      avatarUrl = await SupabaseStorageService.uploadAvatar(
        _avatarImage!, 
        DateTime.now().millisecondsSinceEpoch.toString()
      );
    }
    
    final success = await authProvider.register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
      role,
      oldAgeHomeId: (role == 'caretaker' || role == 'admin') ? _selectedHomeId : null,
      avatarUrl: avatarUrl,
    );
    
    setState(() {
      _isUploadingAvatar = false;
    });
    
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration Successful')));
      Navigator.pushReplacementNamed(context, '/login', arguments: {'role': role});
    } else {
      if (authProvider.error.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authProvider.error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String role = args?['role'] ?? 'caretaker';
    
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Register', style: TextStyle(color: Color(0xFF1E2125), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E2125)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create Your Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2125),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get started with Saanj',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Avatar Picker
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFF3F4F6),
                        backgroundImage: _avatarImage != null 
                            ? FileImage(_avatarImage!)
                            : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF065F26),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                _buildTextField('Full Name', Icons.person_outline, _nameController),
                const SizedBox(height: 16),
                _buildTextField('Email Address', Icons.email_outlined, _emailController),
                const SizedBox(height: 16),
                _buildTextField('Password', Icons.lock_outline, _passwordController, obscure: true),
                
                if (role == 'caretaker' || role == 'admin') ...[
                  const SizedBox(height: 16),
                  _homes.isEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.home_work_outlined, color: Colors.grey.shade500),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Loading homes...', 
                                style: TextStyle(color: Colors.black54),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedHomeId,
                            isExpanded: true,
                            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                            hint: Row(
                              children: [
                                Icon(Icons.home_work_outlined, color: Colors.grey.shade500),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Select Home', 
                                    style: TextStyle(color: Colors.grey.shade500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            items: _homes.map((h) => DropdownMenuItem<int>(
                              value: h['id'],
                              child: Row(
                                children: [
                                  Icon(Icons.home_work_outlined, color: Colors.grey.shade500),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      h['name'].toString(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                            onChanged: (val) => setState(() => _selectedHomeId = val),
                          ),
                        ),
                      ),
                ],
                const SizedBox(height: 32),
                
                isLoading || _isUploadingAvatar
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () => _register(role),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF065F26),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                        ),
                        child: const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                const SizedBox(height: 32),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: 'Log In',
                          style: const TextStyle(
                            color: Color(0xFF065F26),
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacementNamed(context, '/login', arguments: {'role': role});
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 20, right: 12),
          child: Icon(icon, color: Colors.grey.shade500),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
