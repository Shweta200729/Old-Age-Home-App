import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../theme/app_colors.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Saanj',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E2125),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Welcome back. Please select your portal to\nbegin your session.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              _buildRoleCard(
                context,
                title: 'Admin',
                subtitle:
                    'Oversee facility operations, manage staff schedules, and ensure regulatory compliance across all wings.',
                imageUrl:
                    'https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=800&q=80',
                buttonText: 'Enter Dashboard',
                buttonColor: const Color(0xFF4ADE80),
                buttonTextColor: Colors.white,
                iconData: Icons.shield_outlined,
                iconColor: const Color(0xFF166534),
                role: 'admin',
              ),
              _buildRoleCard(
                context,
                title: 'Caretaker',
                subtitle:
                    'Access resident health vitals, daily medication logs, and personalized wellness plans for your assigned residents.',
                imageUrl:
                    'https://images.unsplash.com/photo-1576765608535-5f04d1e3f289?auto=format&fit=crop&w=800&q=80',
                buttonText: 'Access Care Suite',
                buttonColor: const Color(0xFFF3F4F6),
                buttonTextColor: const Color(0xFF166534),
                iconData: Icons.water_drop,
                iconColor: const Color(0xFF1E3A8A),
                role: 'caretaker',
              ),
              _buildRoleCard(
                context,
                title: 'Official',
                subtitle:
                    'Review safety audits, transparency reports, and ensure all elderly care standards are met at a national level.',
                imageUrl:
                    'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=800&q=80',
                buttonText: 'Review Compliance',
                buttonColor: const Color(0xFFF3F4F6),
                buttonTextColor: const Color(0xFF991B1B),
                iconData: Icons.admin_panel_settings,
                iconColor: const Color(0xFF991B1B),
                role: 'government',
              ),
              _buildRoleCard(
                context,
                title: 'Relative / Guardian',
                subtitle:
                    'Stay connected with your loved ones. View daily health reports, activities, and meals in real-time.',
                imageUrl:
                    'https://images.unsplash.com/photo-1511895426328-dc8714191300?auto=format&fit=crop&w=800&q=80',
                buttonText: 'View Resident Updates',
                buttonColor: const Color(0xFFF3F4F6),
                buttonTextColor: const Color(0xFFD97706),
                iconData: Icons.family_restroom,
                iconColor: const Color(0xFFD97706),
                role: 'relative',
              ),
              const SizedBox(height: 40),
              RichText(
                text: TextSpan(
                  text: 'Having trouble logging in? ',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                  children: [
                    TextSpan(
                      text: 'Contact IT Support',
                      style: const TextStyle(
                        color: Color(0xFF166534),
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // TODO: Handle contact support
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'PRIVACY POLICY',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(width: 24),
                  Text(
                    'TERMS OF SERVICE',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'St John College of Engineering and Management',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black26,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imageUrl,
    required String buttonText,
    required Color buttonColor,
    required Color buttonTextColor,
    required IconData iconData,
    required Color iconColor,
    required String role,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 160,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, color: Colors.grey),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: iconColor, size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E2125),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => Navigator.pushNamed(context, '/login', arguments: {'role': role}),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Text(
                buttonText,
                style: TextStyle(
                  color: buttonTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
