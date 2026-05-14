import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  // TODO: Replace these with your actual Supabase project URL and anon key from the Supabase dashboard
  static const String supabaseUrl = 'https://xfwptolmupkpygscugke.supabase.co';
  static const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhmd3B0b2xtdXBrcHlnc2N1Z2tlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYxNzA2MjUsImV4cCI6MjA5MTc0NjYyNX0.uspjVyOlt2jgJo1V90iLxzI9yrk4ZJK58oGyXtCTHjo';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
  }

  static Future<String?> uploadAvatar(File imageFile, String timestampStr) async {
    try {
      final supabase = Supabase.instance.client;
      
      // To ensure unique filenames while keeping it simple without full auth on frontend
      final fileName = 'avatar_$timestampStr.png';

      // Read file to bytes to avoid Android scoped storage issues
      final bytes = await imageFile.readAsBytes();

      // Upload to 'avatars' bucket using binary upload
      await supabase.storage
          .from('avatars')
          .uploadBinary(
             fileName, 
             bytes,
             fileOptions: const FileOptions(contentType: 'image/png', upsert: true),
          );
          
      // Get the public URL for the uploaded file
      final publicUrl = supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);
          
      return publicUrl;
    } catch (e) {
      print('Error uploading to Supabase Storage: $e');
      return null;
    }
  }

  static Future<String?> uploadFacilityImage(File imageFile, String facilityId) async {
    try {
      final supabase = Supabase.instance.client;
      final fileName = 'facility_$facilityId.png';
      final bytes = await imageFile.readAsBytes();

      await supabase.storage
          .from('facility_images')
          .uploadBinary(
             fileName, 
             bytes,
             fileOptions: const FileOptions(contentType: 'image/png', upsert: true),
          );
          
      final publicUrl = supabase.storage
          .from('facility_images')
          .getPublicUrl(fileName);
          
      return publicUrl;
    } catch (e) {
      print('Error uploading facility image: $e');
      return null;
    }
  }
  static Future<String?> uploadReportImage(File imageFile, String reportType, String timestampStr) async {
    try {
      final supabase = Supabase.instance.client;
      final fileName = '${reportType}_$timestampStr.png';
      final bytes = await imageFile.readAsBytes();

      await supabase.storage
          .from('reports')
          .uploadBinary(
             fileName, 
             bytes,
             fileOptions: const FileOptions(contentType: 'image/png', upsert: true),
          );
          
      final publicUrl = supabase.storage
          .from('reports')
          .getPublicUrl(fileName);
          
      return publicUrl;
    } catch (e) {
      print('Error uploading report image: $e');
      return null;
    }
  }
}

