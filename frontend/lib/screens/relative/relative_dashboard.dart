import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/relative_provider.dart';

class RelativeDashboard extends StatefulWidget {
  const RelativeDashboard({super.key});

  @override
  State<RelativeDashboard> createState() => _RelativeDashboardState();
}

class _RelativeDashboardState extends State<RelativeDashboard> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final relativeProvider = context.read<RelativeProvider>();
      
      if (auth.user != null && auth.user!['elderly_id'] != null) {
        relativeProvider.fetchReports(auth.user!['elderly_id']);
      }
    });
  }

  void _handleLogout() {
    context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final relativeProvider = context.watch<RelativeProvider>();
    final resident = relativeProvider.resident;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Premium lighter background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Relative Portal',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white70,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              resident != null ? resident['name'] ?? 'Your Resident' : 'Dashboard',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: relativeProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD97706)))
          : relativeProvider.error.isNotEmpty
              ? Center(child: Text(relativeProvider.error, style: const TextStyle(color: Colors.red)))
              : resident == null
                  ? const Center(child: Text("No resident assigned."))
                  : _buildDashboardContent(relativeProvider),
    );
  }

  Widget _buildDashboardContent(RelativeProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildResidentProfileCard(provider.resident!),
          const SizedBox(height: 32),
          const Text(
            'Recent Daily Reports',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E2125),
            ),
          ),
          const SizedBox(height: 16),
          if (provider.dailyReports.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No daily reports yet.', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...provider.dailyReports.map((report) => _buildReportCard(report)).toList(),
        ],
      ),
    );
  }

  Widget _buildResidentProfileCard(Map<String, dynamic> resident) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 40, color: Color(0xFFD97706)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resident['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2125),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.cake_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${resident['age'] ?? '-'} yrs', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 16),
                    const Icon(Icons.meeting_room_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Room ${resident['room'] ?? '-'}', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.medical_services_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        resident['medical_conditions'] ?? 'None',
                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    bool hasMedicine = report['medicine_given'] == 1 || report['medicine_given'] == true;
    String mood = report['mood'] ?? 'Neutral';
    String? photoUrl = report['photo_path'];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photoUrl != null && photoUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              child: Image.network(
                photoUrl,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 120,
                  color: Colors.grey.shade100,
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      report['date'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Color(0xFFD97706),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: hasMedicine ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        hasMedicine ? 'Meds Given' : 'No Meds',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: hasMedicine ? const Color(0xFF166534) : const Color(0xFF991B1B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildReportDetail(Icons.breakfast_dining, 'Breakfast', (report['breakfast'] == 1 || report['breakfast'] == true) ? 'Yes' : 'No')),
                    Expanded(child: _buildReportDetail(Icons.lunch_dining, 'Lunch', (report['lunch'] == 1 || report['lunch'] == true) ? 'Yes' : 'No')),
                    Expanded(child: _buildReportDetail(Icons.dinner_dining, 'Dinner', (report['dinner'] == 1 || report['dinner'] == true) ? 'Yes' : 'No')),
                  ],
                ),
                const SizedBox(height: 20),
                Container(height: 1, color: Colors.grey.shade100),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildReportDetail(Icons.sentiment_satisfied_alt, 'Mood', mood)),
                    Expanded(child: _buildReportDetail(Icons.directions_walk, 'Activity', report['physical_activity'] ?? 'None')),
                    Expanded(child: _buildReportDetail(Icons.clean_hands, 'Bathing', (report['bathing'] == 1 || report['bathing'] == true) ? 'Done' : 'No')),
                  ],
                ),
                if (report['issues'] != null && report['issues'].toString().trim().isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFFDC2626), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Caretaker Note', style: TextStyle(color: Color(0xFF991B1B), fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                report['issues'],
                                style: const TextStyle(color: Color(0xFF7F1D1D), fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportDetail(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey.shade400, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E2125)),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
