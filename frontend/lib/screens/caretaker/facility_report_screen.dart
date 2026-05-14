import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/caretaker_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/supabase_storage_service.dart';

class FacilityReportScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  const FacilityReportScreen({
    super.key,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  State<FacilityReportScreen> createState() => _FacilityReportScreenState();
}

class _FacilityReportScreenState extends State<FacilityReportScreen> {
  File? _bathroomImage;
  File? _foodImage;
  File? _cleanlinessImage;
  
  bool _isUploading = false;

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        if (type == 'bathroom') _bathroomImage = File(pickedFile.path);
        if (type == 'food') _foodImage = File(pickedFile.path);
        if (type == 'cleanliness') _cleanlinessImage = File(pickedFile.path);
      });
    }
  }

  Widget _buildImageCard({required String title, required String emoji, required File? imageFile, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                child: Text(emoji, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.black87)),
              const Spacer(),
              if (imageFile != null)
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: imageFile == null ? const EdgeInsets.symmetric(vertical: 24) : EdgeInsets.zero,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(12),
              ),
              child: imageFile == null
                  ? Column(
                      children: [
                        Icon(Icons.camera_alt_outlined, color: Colors.grey.shade500, size: 32),
                        const SizedBox(height: 8),
                        Text('Tap to capture photo', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(imageFile, height: 180, width: double.infinity, fit: BoxFit.cover),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';
    final dbDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return Column(
      children: [
        // Premium Header
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: widget.onBack,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, color: Color(0xFF1E2125), size: 18),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Facility Overall Report', 
                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E2125), letterSpacing: -0.8)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(6)),
                    child: const Text('DAILY CHECK', style: TextStyle(color: Color(0xFF475569), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  ),
                  const SizedBox(width: 12),
                  Text(dateStr, style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                ],
              ),
            ],
          ),
        ),

        // Scrollable Body
        Expanded(
          child: Container(
            color: const Color(0xFFF6F9FF),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildImageCard(
                  title: 'Bathroom Condition (Mandatory)',
                  emoji: '🚽',
                  imageFile: _bathroomImage,
                  onTap: () => _pickImage('bathroom'),
                ),
                _buildImageCard(
                  title: 'Food Quality (Mandatory)',
                  emoji: '🥘',
                  imageFile: _foodImage,
                  onTap: () => _pickImage('food'),
                ),
                _buildImageCard(
                  title: 'Overall Cleanliness (Mandatory)',
                  emoji: '🧹',
                  imageFile: _cleanlinessImage,
                  onTap: () => _pickImage('cleanliness'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isUploading || context.watch<CaretakerProvider>().isLoading ? null : () async {
                    if (_bathroomImage == null || _foodImage == null || _cleanlinessImage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All 3 photos are mandatory to submit the report.')),
                      );
                      return;
                    }

                    setState(() => _isUploading = true);
                    
                    final auth = context.read<AuthProvider>();
                    final homeId = auth.user?['old_age_home_id'];
                    final caretakerId = auth.user?['id'];
                    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
                    
                    if (homeId == null || caretakerId == null) {
                       setState(() => _isUploading = false);
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authentication error. Cannot identify home.')));
                       return;
                    }

                    // Upload images
                    final bathroomUrl = await SupabaseStorageService.uploadReportImage(_bathroomImage!, 'facility_bath_$homeId', timestamp);
                    final foodUrl = await SupabaseStorageService.uploadReportImage(_foodImage!, 'facility_food_$homeId', timestamp);
                    final cleanUrl = await SupabaseStorageService.uploadReportImage(_cleanlinessImage!, 'facility_clean_$homeId', timestamp);

                    if (bathroomUrl == null || foodUrl == null || cleanUrl == null) {
                      setState(() => _isUploading = false);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to upload one or more photos. Please try again.')),
                      );
                      return;
                    }

                    final caretaker = context.read<CaretakerProvider>();
                    
                    final success = await caretaker.submitFacilityReport({
                      'caretaker_id': caretakerId,
                      'old_age_home_id': homeId,
                      'date': dbDate, 
                      'bathroom_image': bathroomUrl,
                      'food_image': foodUrl,
                      'cleanliness_image': cleanUrl,
                    });

                    setState(() => _isUploading = false);

                    if (success) {
                      if (!mounted) return;
                      widget.onSubmit();
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${caretaker.error}'))
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF048A39), 
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: const Color(0xFF048A39).withOpacity(0.3),
                  ),
                  child: _isUploading || context.watch<CaretakerProvider>().isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Submit Facility Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
