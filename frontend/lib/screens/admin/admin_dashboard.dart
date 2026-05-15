import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import 'admin_resident_profile_screen.dart';
import 'admin_alerts_screen.dart';
import 'admin_profile_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final admin = context.read<AdminProvider>();
      admin.fetchSystemOverview();
      if (auth.user != null && auth.user!['old_age_home_id'] != null) {
        admin.fetchResidents(auth.user!['old_age_home_id']);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(int index, dynamic r) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Coming Soon', style: TextStyle(fontWeight: FontWeight.bold)),
              content: const Text('Resident deletion is currently being implemented.',
                  style: TextStyle(color: Colors.black87)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                )
              ],
            ));
  }

  void _showAddResidentModal(BuildContext context) {
    final TextEditingController nameCtl = TextEditingController();
    final TextEditingController ageCtl = TextEditingController();
    final TextEditingController roomCtl = TextEditingController();
    String gender = 'Male';
    final TextEditingController medicalCtl = TextEditingController();
    final TextEditingController emergencyCtl = TextEditingController();
    DateTime selectedDate = DateTime.now();

    final TextEditingController relativeNameCtl = TextEditingController();
    final TextEditingController relativeEmailCtl = TextEditingController();

    String errorMsg = '';

    showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(builder: (context, setModalState) {
            String formattedDate = "${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}";

            return Dialog(
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Add Resident', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E2125), letterSpacing: -1)),
                            SizedBox(height: 4),
                            Text('FACILITY ENROLLMENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF16A34A), letterSpacing: 1.5)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
                          child: GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: const Icon(Icons.close, size: 20, color: Colors.grey),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    _buildModalLabel('FULL NAME'),
                    _buildModalInput(nameCtl, 'e.g., John Doe', icon: Icons.person_outline_rounded),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildModalLabel('AGE'),
                              _buildModalInput(ageCtl, 'Years', icon: Icons.cake_outlined, keyboardType: TextInputType.number),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildModalLabel('ROOM'),
                              _buildModalInput(roomCtl, 'Number', icon: Icons.meeting_room_outlined),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildModalLabel('GENDER'),
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: gender,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF16A34A)),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E2125)),
                          items: ['Male', 'Female', 'Other']
                              .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => gender = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildModalLabel('MEDICAL CONDITIONS'),
                    _buildModalInput(medicalCtl, 'e.g., Hypertension', icon: Icons.medical_services_outlined),
                    const SizedBox(height: 20),

                    _buildModalLabel('EMERGENCY CONTACT'),
                    _buildModalInput(emergencyCtl, '+91 XXXXXXXXXX', icon: Icons.phone_outlined),
                    const SizedBox(height: 20),

                    _buildModalLabel('ADMISSION DATE'),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF16A34A),
                                  onPrimary: Colors.white,
                                  onSurface: Color(0xFF1E2125),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != selectedDate) {
                          setModalState(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(formattedDate, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E2125))),
                            const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF16A34A)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Text('RELATIVE / GUARDIAN (OPTIONAL)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF1E2125), letterSpacing: 1.0)),
                    const SizedBox(height: 16),
                    
                    _buildModalLabel('RELATIVE NAME'),
                    _buildModalInput(relativeNameCtl, 'e.g., Jane Doe', icon: Icons.family_restroom_rounded),
                    const SizedBox(height: 20),

                    _buildModalLabel('RELATIVE EMAIL'),
                    _buildModalInput(relativeEmailCtl, 'e.g., jane@example.com', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),

                    if (errorMsg.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(errorMsg, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: () async {
                        if (nameCtl.text.isEmpty || ageCtl.text.isEmpty || roomCtl.text.isEmpty) {
                          setModalState(() => errorMsg = 'Required fields missing');
                          return;
                        }

                        final auth = context.read<AuthProvider>();
                        final admin = context.read<AdminProvider>();

                        if (auth.user == null || auth.user!['old_age_home_id'] == null) {
                          setModalState(() => errorMsg = 'Authentication error');
                          return;
                        }

                        final result = await admin.addResident({
                          'name': nameCtl.text,
                          'age': int.tryParse(ageCtl.text) ?? 60,
                          'gender': gender,
                          'room': roomCtl.text,
                          'medical_conditions': medicalCtl.text,
                          'emergency_contact': emergencyCtl.text,
                          'admission_date': formattedDate,
                          'old_age_home_id': auth.user!['old_age_home_id'],
                          if (relativeNameCtl.text.isNotEmpty && relativeEmailCtl.text.isNotEmpty) 'relative_name': relativeNameCtl.text,
                          if (relativeNameCtl.text.isNotEmpty && relativeEmailCtl.text.isNotEmpty) 'relative_email': relativeEmailCtl.text,
                        });

                        if (result['success'] == true) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resident Boarded Successfully!')));
                          
                          if (result['relative_password'] != null) {
                            showDialog(
                              context: context,
                              builder: (ctx2) => AlertDialog(
                                title: const Text('Relative Account Created', style: TextStyle(fontWeight: FontWeight.bold)),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Please share these credentials with the relative/guardian:', style: TextStyle(fontSize: 14)),
                                    const SizedBox(height: 16),
                                    Text('Email: ${result['relative_email']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text('Password: ${result['relative_password']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx2),
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
                                    child: const Text('Done'),
                                  )
                                ],
                              )
                            );
                          }
                        } else {
                          setModalState(() => errorMsg = admin.error);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: const Text('Confirm Enrollment', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  Widget _buildModalLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.2)),
    );
  }

  Widget _buildModalInput(TextEditingController controller, String hint, {IconData? icon, TextInputType? keyboardType}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E2125)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.w500),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF16A34A), size: 20) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = context.watch<AdminProvider>();
    final residents = adminState.residents;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            if (_selectedIndex == 0 || _selectedIndex == 1) _buildTopAppBar(),
            Expanded(
              child: _selectedIndex == 0
                  ? _buildOverviewContent(adminState)
                  : _selectedIndex == 1
                      ? _buildDashboardContent(residents)
                      : _selectedIndex == 2
                          ? AdminAlertsScreen(onBack: () => setState(() => _selectedIndex = 0))
                          : AdminProfileScreen(onBack: () => setState(() => _selectedIndex = 0)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex > 3 ? 0 : _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: const Color(0xFF048A39),
          unselectedItemColor: const Color(0xFF94A3B8),
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.2),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 0.2),
          items: [
            _buildNavItem(Icons.grid_view_rounded, Icons.grid_view_outlined, 'OVERVIEW', 0),
            _buildNavItem(Icons.people_alt_rounded, Icons.people_outline_rounded, 'RESIDENTS', 1),
            _buildNavItem(Icons.notifications_rounded, Icons.notifications_none_rounded, 'ALERTS', 2),
            _buildNavItem(Icons.person_rounded, Icons.person_outline_rounded, 'PROFILE', 3),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData activeIcon, IconData inactiveIcon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF048A39).withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(isSelected ? activeIcon : inactiveIcon, size: 22),
      ),
      label: label,
    );
  }

  Widget _buildTopAppBar() {
    final user = context.watch<AuthProvider>().user;
    final String homeName = user?['old_age_home_name'] ?? 'Facility Admin Panel';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF1E293B),
            radius: 18,
            child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Admin Panel • $homeName',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Daily Overview',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1E2125)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => setState(() => _selectedIndex = 2),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.notifications_rounded, color: Colors.blueGrey.shade700, size: 22),
                ),
                if (context.watch<AdminProvider>().systemAlerts.isNotEmpty)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewContent(AdminProvider adminState) {
    if (adminState.isLoading && adminState.residents.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF16A34A)));
    }

    final recentAlerts = adminState.systemAlerts.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Real Stat Boxes
          _buildStatBox(
            'TOTAL RESIDENTS',
            '${adminState.residents.length}',
            'Active in Facility',
            const Color(0xFF16A34A), // Green
            Icons.directions_walk,
            const Color(0xFFDCFCE7),
            const Color(0xFF16A34A),
          ),
          _buildStatBox(
            'ACTIVE CARETAKERS',
            '${adminState.caretakerCount}',
            'Staff On Duty',
            const Color(0xFF2563EB), // Blue
            Icons.business_center_outlined,
            const Color(0xFFDBEAFE),
            const Color(0xFF2563EB),
          ),
          _buildStatBox(
            'PENDING ALERTS',
            '${adminState.systemAlerts.length}',
            'Action Required',
            const Color(0xFFDC2626), // Red
            Icons.warning_amber_rounded,
            const Color(0xFFFEE2E2),
            const Color(0xFFDC2626),
          ),

          const SizedBox(height: 32),
          
          // Data-driven real metrics charts
          _buildAgeDemographics(adminState.residents),
          const SizedBox(height: 24),
          _buildHealthScore(adminState),
          
          const SizedBox(height: 32),

          // Real Recent Alerts populated from the database
          if (recentAlerts.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Alerts',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E2125))),
                GestureDetector(
                  onTap: () => setState(() => _selectedIndex = 2),
                  child: const Text('View All',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recentAlerts.map((a) => _buildAlert(
                  '${a['home_name'] ?? 'Home'} Alert',
                  '${a['issues']}',
                  a['date'] ?? 'Recent',
                  'ALERT',
                  const Color(0xFFD97706),
                  Icons.medication_liquid_rounded,
                )),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String value, String subtext, Color subColor, IconData iconData, Color iconBg, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.8)),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E2125))),
              const SizedBox(height: 6),
              Text(subtext, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subColor)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(iconData, color: iconColor, size: 28),
          )
        ],
      ),
    );
  }

  Widget _buildAgeDemographics(List<dynamic> residents) {
    if (residents.isEmpty) return const SizedBox.shrink();
    
    int group60 = 0, group70 = 0, group80 = 0, group90 = 0;
    for (var r in residents) {
      int age = r['age'] ?? 0;
      if (age >= 90) group90++;
      else if (age >= 80) group80++;
      else if (age >= 70) group70++;
      else group60++;
    }

    int maxGroup = [group60, group70, group80, group90].reduce((a, b) => a > b ? a : b);
    if (maxGroup == 0) maxGroup = 1;

    double getDarkHeight(int count) => (count / maxGroup) * 100.0;
    double getLightHeight(int count) => 100.0 - getDarkHeight(count);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Age Demographics',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E2125), height: 1.2)),
                    const SizedBox(height: 4),
                    Text('Resident distribution by age group',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500, height: 1.4)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF86EFAC).withOpacity(0.8), borderRadius: BorderRadius.circular(20)),
                child: const Text('Real-Time', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
              )
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(getDarkHeight(group60), getLightHeight(group60), '60-69'),
              _buildBar(getDarkHeight(group70), getLightHeight(group70), '70-79'),
              _buildBar(getDarkHeight(group80), getLightHeight(group80), '80-89'),
              _buildBar(getDarkHeight(group90), getLightHeight(group90), '90+'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBar(double darkHeight, double lightHeight, String label) {
    if (darkHeight < 5) darkHeight = 5; // Minimum visible bar to signify non-zero visually but safely
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 36,
          height: darkHeight + lightHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFDCFCE7),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 36,
            height: darkHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF4ADE80).withOpacity(0.9),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildHealthScore(AdminProvider adminState) {
    int total = adminState.residents.length;
    int alerts = adminState.systemAlerts.length;
    double healthRatio = total == 0 ? 1.0 : ((total - alerts) / total).clamp(0.0, 1.0);
    int healthScore = (healthRatio * 100).toInt();

    String statusText = 'EXCELLENT';
    Color statusColor = const Color(0xFF16A34A);
    if (healthScore < 70) {
      statusText = 'NEEDS ATTENTION';
      statusColor = const Color(0xFFD97706);
    }
    if (healthScore < 40) {
      statusText = 'CRITICAL';
      statusColor = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Overall Safety Score',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E2125))),
          const SizedBox(height: 32),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: healthRatio,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$healthScore',
                      style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFF1E2125))),
                  Text(statusText,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey.shade600, letterSpacing: 1.0)),
                ],
              )
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Score is dynamically generated based on active\nalerts vs total facility residents.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildAlert(String title, String subtitle, String time, String pillLabel, Color color, IconData iconData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E2125))),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(pillLabel,
                          style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w800)),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(time.length > 10 ? time.substring(0, 10) : time, 
               style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(List<dynamic> residents) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or room number...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () => _showAddResidentModal(context),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Add New Resident',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('All Residents',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                child: Text('${residents.length} Residents',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Builder(builder: (context) {
            String query = _searchController.text.toLowerCase();
            List<dynamic> filteredList = residents.where((r) {
              return r['name'].toString().toLowerCase().contains(query) ||
                  r['room'].toString().toLowerCase().contains(query);
            }).toList();

            if (filteredList.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                    child: Text("No residents found.",
                        style: TextStyle(color: Colors.grey.shade500))),
              );
            }

            return Column(
              children: filteredList.asMap().entries.map((entry) {
                return _buildResidentCard(entry.value, entry.key);
              }).toList(),
            );
          })
        ],
      ),
    );
  }

  Widget _buildResidentCard(dynamic r, int index) {
    String initial = r['name'].toString().substring(0, 1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF16A34A),
                child: Text(initial,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                    const SizedBox(height: 2),
                    Text('${r['age']} years  •  ${r['gender']}  •  ${r['room']}',
                        style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Medical:', r['medical_conditions'] ?? 'None'),
          const SizedBox(height: 8),
          _buildInfoRow('Emergency:', r['emergency_contact'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildInfoRow('Admitted:', r['admission_date'] ?? 'N/A'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AdminResidentProfileScreen(resident: r)));
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('View Profile',
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => _confirmDelete(index, r),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.shade100),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  backgroundColor: Colors.red.shade50,
                ),
                child: Icon(Icons.delete_outline, color: Colors.red.shade600, size: 20),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13))),
        Expanded(child: Text(value, style: TextStyle(color: Colors.blueGrey.shade700, fontSize: 13))),
      ],
    );
  }
}
