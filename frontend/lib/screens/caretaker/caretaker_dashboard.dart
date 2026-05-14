import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/caretaker_provider.dart';
import '../../providers/language_provider.dart';
import 'daily_report_screen.dart';
import 'facility_report_screen.dart';
import 'alerts_screen.dart';
import 'profile_screen.dart';

class CaretakerDashboard extends StatefulWidget {
  const CaretakerDashboard({super.key});

  @override
  State<CaretakerDashboard> createState() => _CaretakerDashboardState();
}

class _CaretakerDashboardState extends State<CaretakerDashboard> {
  int _selectedIndex = 0;
  dynamic _selectedResident;
  bool _showFacilityReport = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null && user['id'] != null) {
        context.read<CaretakerProvider>().fetchElderly(user['id']);
      }
    });
  }

  void _triggerEmergency() {
    context.read<CaretakerProvider>().triggerEmergency();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final String name = user?['name']?.split(' ')[0] ?? 'Caretaker';
    final String? userAvatarUrl = user?['avatar_url'];
    final String homeName = user?['old_age_home_name'] ?? 'Facility';
    final provider = context.watch<CaretakerProvider>();
    final lang = context.watch<LanguageProvider>();

    // Dynamic Wellness Logic
    final total = provider.elderly.length;
    final goodCount = provider.elderly.where((e) => e != null && (e['health_status'] ?? 'good').toString().toLowerCase() == 'good').length;
    final attentionCount = total - goodCount;
    final wellnessPercentage = total == 0 ? 100 : ((goodCount / total) * 100).toInt();

    Widget body;
    switch (_selectedIndex) {
      case 0: // OVERVIEW
        body = _buildDashboardHome(name, userAvatarUrl, homeName, wellnessPercentage, attentionCount, provider, lang);
        break;
      case 1: // RESIDENTS
        body = _buildResidentsOnlyView(provider, lang);
        break;
      case 2: // ALERTS
        body = AlertsScreen(onBack: () => setState(() => _selectedIndex = 0));
        break;
      case 3: // PROFILE
        body = ProfileScreen(onBack: () => setState(() => _selectedIndex = 0));
        break;
      default:
        body = _buildDashboardHome(name, userAvatarUrl, homeName, wellnessPercentage, attentionCount, provider, lang);
    }

    // Special case: If we are in "Report Mode" (triggered from card)
    if (_selectedResident != null && _selectedIndex == 1) {
       body = DailyReportScreen(
        resident: _selectedResident,
        onBack: () {
          setState(() {
            _selectedResident = null;
            // Stay in Residents tab
          });
        },
        onSubmit: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted securely!')));
          setState(() {
            _selectedResident = null;
            // Stay in Residents tab
          });
        },
      );
    }

    if (_showFacilityReport && _selectedIndex == 0) {
      body = FacilityReportScreen(
        onBack: () {
          setState(() {
            _showFacilityReport = false;
          });
        },
        onSubmit: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Facility Report submitted securely!')));
          setState(() {
            _showFacilityReport = false;
          });
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(child: body),
      bottomNavigationBar: _buildBottomNav(lang),
    );
  }

  Widget _buildResidentsOnlyView(CaretakerProvider provider, LanguageProvider lang) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 8),
      children: [
        _buildSectionHeader('All Residents'),
        _buildResidentsSection(provider, lang),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -0.5)),
    );
  }

  Widget _buildDashboardHome(String name, String? userAvatarUrl, String homeName, int wellness, int attentionCount, CaretakerProvider provider, LanguageProvider lang) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _buildTopHeader(name, userAvatarUrl, homeName),
        _buildWellnessCard(wellness, attentionCount),
        _buildHealthDistributionChart(provider.elderly),
        _buildQuickActions(lang),
        _buildActivityDistribution(provider.elderly),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHealthDistributionChart(List<dynamic> elderly) {
    int good = elderly.where((e) => (e['health_status'] ?? 'good').toString().toLowerCase() == 'good').length;
    int attention = elderly.where((e) => (e['health_status'] ?? 'good').toString().toLowerCase() == 'attention').length;
    int critical = elderly.length - good - attention;
    int total = elderly.isEmpty ? 1 : elderly.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('HEALTH DISTRIBUTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                if (good > 0) Expanded(flex: good, child: Container(height: 12, color: const Color(0xFF22C55E))),
                if (attention > 0) Expanded(flex: attention, child: Container(height: 12, color: const Color(0xFFF59E0B))),
                if (critical > 0) Expanded(flex: critical, child: Container(height: 12, color: const Color(0xFFEF4444))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildChartLegend('Good', const Color(0xFF22C55E), good, total),
              _buildChartLegend('Alert', const Color(0xFFF59E0B), attention, total),
              _buildChartLegend('Critical', const Color(0xFFEF4444), critical, total),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color, int count, int total) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$label (${((count/total)*100).toInt()}%)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54)),
      ],
    );
  }

  Widget _buildActivityDistribution(List<dynamic> elderly) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2125),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('STAFF ENGAGEMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white54, letterSpacing: 1)),
          const SizedBox(height: 20),
          _buildActivityBar('Medication Compliance', 0.95, Colors.blueAccent),
          const SizedBox(height: 16),
          _buildActivityBar('Daily Report Completion', 0.78, Colors.greenAccent),
          const SizedBox(height: 16),
          _buildActivityBar('Physical Therapy', 0.64, Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _buildActivityBar(String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            Text('${(progress*100).toInt()}%', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildTopHeader(String name, String? userAvatarUrl, String homeName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: userAvatarUrl != null && userAvatarUrl.isNotEmpty
                ? NetworkImage(userAvatarUrl)
                : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(homeName, 
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500), 
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
                Text(name, 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87), 
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
                child: const Icon(Icons.notifications_none_rounded, size: 24, color: Colors.black87),
              ),
              Positioned(right: 8, top: 8, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWellnessCard(int wellness, int attentionCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20, bottom: -20,
            child: Icon(Icons.favorite, size: 140, color: Colors.green.withOpacity(0.05)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('FACILITY PULSE', style: TextStyle(color: Color(0xFF048A39), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
              const SizedBox(height: 8),
              Text('$wellness% Overall\nWellness', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1, color: Colors.black87)),
              const SizedBox(height: 16),
              Text(
                attentionCount == 0 
                  ? 'All residents are stable today. All morning check-ups completed.' 
                  : '$attentionCount residents require observation. Check the status feed below.',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildQuickActions(LanguageProvider lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          _buildActionButton('Submit Daily Report', Icons.description_rounded, const Color(0xFF048A39), Colors.white, () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang.t('Select a resident below to add a report', 'रिपोर्ट जोड़ने के लिए नीचे एक निवासी चुनें'))));
          }),
          const SizedBox(height: 12),
          _buildActionButton('Submit Facility Report', Icons.domain_verification_rounded, Colors.white, const Color(0xFF048A39), () {
            setState(() {
              _showFacilityReport = true;
            });
          }, isOutlined: true),
          const SizedBox(height: 12),
          _buildActionButton('Raise Facility Alert', Icons.warning_rounded, Colors.white, Colors.red, _triggerEmergency, isOutlined: true),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color bg, Color text, VoidCallback onTap, {bool isOutlined = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(40),
          border: isOutlined ? Border.all(color: Colors.red.withOpacity(0.1)) : null,
          boxShadow: bg != Colors.white ? [BoxShadow(color: bg.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: text, size: 20),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(color: text, fontWeight: FontWeight.w900, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildResidentsSection(CaretakerProvider provider, LanguageProvider lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Today\'s Residents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text('View All Schedule', style: TextStyle(color: const Color(0xFF048A39), fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          if (provider.isLoading && provider.elderly.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (provider.elderly.isEmpty)
             const Padding(padding: EdgeInsets.all(16.0), child: Text("No residents assigned."))
          else
            ...provider.elderly.where((e) => e != null).toList().asMap().entries.map((entry) => _buildResidentCard(entry.value, entry.key, lang)),
        ],
      ),
    );
  }

  Widget _buildResidentCard(dynamic e, int index, LanguageProvider lang) {
    final status = (e['health_status'] ?? 'good').toString().toLowerCase();
    final bool isStable = status == 'good';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: const AssetImage('assets/images/default_avatar.png'),
              ),
              Positioned(
                right: 2, bottom: 2,
                child: Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: isStable ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e['name'] ?? 'Resident', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
                          child: Text(e['room'] != null ? 'ROOM ${e['room']}' : 'R-${100 + index}', style: const TextStyle(color: Colors.blue, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Icon(isStable ? Icons.check_circle_outline_rounded : Icons.pending_actions_rounded, size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isStable ? 'Check-up done' : 'Priority Attention',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    )
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isStable ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isStable ? 'STABLE' : 'OBSERVATION',
                  style: TextStyle(color: isStable ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(() {
                  _selectedResident = e;
                  _selectedIndex = 1;
                }),
                child: Icon(Icons.add_circle, color: isStable ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3), size: 28),
              )
            ],
          )
        ],
      ),
    );
  }


  Widget _buildBottomNav(LanguageProvider lang) {
    return Container(
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
}

