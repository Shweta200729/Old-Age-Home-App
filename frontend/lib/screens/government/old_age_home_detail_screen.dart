import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/government_provider.dart';
import 'report_detail_screen.dart';
import '../../core/widgets/facility_image.dart';
import '../../providers/auth_provider.dart';
import 'government_feedback_dialog.dart';
class OldAgeHomeDetailScreen extends StatefulWidget {
  final int homeId;
  final String homeName;
  final String homeLocation;
  final int residents;
  final int complianceScore;
  final String? imageUrl;
  final VoidCallback? onBack;

  const OldAgeHomeDetailScreen({
    super.key,
    required this.homeId,
    required this.homeName,
    required this.homeLocation,
    required this.residents,
    required this.complianceScore,
    this.imageUrl,
    this.onBack,
  });

  @override
  State<OldAgeHomeDetailScreen> createState() => _OldAgeHomeDetailScreenState();
}

class _OldAgeHomeDetailScreenState extends State<OldAgeHomeDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.homeId != 0) {
        context.read<GovernmentProvider>().fetchHomeData(widget.homeId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            height: 280,
            child: _buildCoverImage(),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopHeader(context),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 130, bottom: 48),
                    children: [
                      _buildFacilitySummary(),
                      const SizedBox(height: 20),
                      _buildTabSection(),
                      const SizedBox(height: 20),
                      _buildTabContent(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    return Stack(
      children: [
        SizedBox(
          height: 280,
          width: double.infinity,
          child: FacilityImage(
            imageUrl: widget.imageUrl,
            name: widget.homeName,
            height: 280,
            width: double.infinity,
          ),
        ),
        Container(
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.5),
                Colors.transparent,
                const Color(0xFFF7F8FA),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildGlassIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: widget.onBack ?? () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.homeId == 0 ? 'Facility Network' : 'Overview',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black87),
                ),
                Text(
                  'MONITORING ACTIVE',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF048A39), letterSpacing: 0.5),
                )
              ],
            ),
          ),
          const Spacer(),
          _buildGlassIconButton(
            icon: Icons.more_vert_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildGlassIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }

  Widget _buildFacilitySummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.homeName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87, height: 1.2),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF048A39).withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.verified_rounded, color: Color(0xFF048A39), size: 20),
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.location_on_rounded, size: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.homeLocation,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildSmallStat('RESIDENTS', '${widget.residents}', Icons.people_alt_rounded, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildSmallStat('COMPLIANCE', '${widget.complianceScore}%', Icons.analytics_rounded, widget.complianceScore >= 75 ? const Color(0xFF048A39) : Colors.red.shade700)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color.withOpacity(0.9), fontSize: 22, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ],
          ),
          labelColor: const Color(0xFF1E2125),
          unselectedLabelColor: Colors.grey.shade500,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(text: 'Residents'),
            Tab(text: 'Facility'),
            Tab(text: 'Feedback'),
            Tab(text: 'Alerts'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return [
      _buildReportsList(),
      _buildFacilityReportsList(),
      _buildFeedbackList(),
      _buildPlaceholder('Alerts coming soon'),
    ][_tabController.index];
  }

  Widget _buildPlaceholder(String text) {
    return Center(child: Padding(padding: const EdgeInsets.all(48), child: Text(text, style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold))));
  }

  Widget _buildFeedbackList() {
    final provider = context.watch<GovernmentProvider>();
    final feedbacks = provider.feedbacks;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Government Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => GovernmentFeedbackDialog(homeId: widget.homeId, homeName: widget.homeName),
                  );
                },
                icon: const Icon(Icons.add_comment_rounded, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (feedbacks.isEmpty)
            _buildPlaceholder('No feedback submitted yet.')
          else
            ...feedbacks.map((f) => _buildFeedbackCard(f)).toList(),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(dynamic f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.blue.shade50,
                child: const Icon(Icons.account_balance_rounded, size: 14, color: Colors.blue),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f['government_name'] ?? 'Government Official', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(f['created_at']?.toString().split(' ')[0] ?? '', style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < (f['rating'] ?? 0) ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 14,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            f['comment'] ?? '',
            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    final provider = context.watch<GovernmentProvider>();
    final reports = provider.reports;

    if (provider.isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
    }

    if (reports.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(48.0), child: Text('No entries found.', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold))));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: reports.map((r) {
          final bool isAttention = r['issues'] != null && r['issues'].toString().trim().isNotEmpty;
          return _buildReportCard(
            report: r,
            name: r['elderly_name'] ?? 'Unknown',
            status: isAttention ? 'ATTENTION' : 'STABLE',
            room: 'Room ${r['room'] ?? 'N/A'}',
            date: r['date'] ?? '',
            caretaker: r['caretaker_name'] ?? 'Staff',
            isAttention: isAttention,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFacilityReportsList() {
    final provider = context.watch<GovernmentProvider>();
    final facilityReports = provider.facilityReports;

    if (provider.isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
    }

    if (facilityReports.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(48.0), child: Text('No facility reports found.', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold))));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: facilityReports.map((r) => _buildFacilityReportCard(r)).toList(),
      ),
    );
  }

  Widget _buildFacilityReportCard(dynamic report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Facility Daily Report', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.black87)),
              Text(report['date'] ?? '', style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(radius: 10, backgroundColor: Colors.grey.shade200, child: const Icon(Icons.person, size: 12, color: Colors.black45)),
              const SizedBox(width: 8),
              Text('Submitted by: ${report['caretaker_name'] ?? 'Staff'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _buildFacilityReportImageSection('Bathroom Condition', report['bathroom_image']),
          const SizedBox(height: 12),
          _buildFacilityReportImageSection('Food Quality', report['food_image']),
          const SizedBox(height: 12),
          _buildFacilityReportImageSection('Overall Cleanliness', report['cleanliness_image']),
        ],
      ),
    );
  }

  Widget _buildFacilityReportImageSection(String title, String? imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 8),
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: imageUrl != null && imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_rounded, color: Colors.grey.shade400, size: 32),
                          const SizedBox(height: 8),
                          Text('Image unavailable', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      );
                    },
                  ),
                )
              : Center(
                  child: Text('No image provided', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ),
        ),
      ],
    );
  }

  Widget _buildReportCard({
    required dynamic report,
    required String name,
    required String status,
    required String room,
    required String date,
    required String caretaker,
    bool isAttention = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ReportDetailScreen(report: report)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))
          ],
          border: Border.all(color: isAttention ? Colors.red.shade100 : Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.black87)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAttention ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: isAttention ? Colors.red : Colors.green, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.meeting_room_outlined, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text('$room • $date', style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 10, backgroundColor: Colors.grey.shade200, child: const Icon(Icons.person, size: 12, color: Colors.black45)),
                    const SizedBox(width: 8),
                    Text(caretaker, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
                  ],
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade300),
              ],
            )
          ],
        ),
      ),
    );
  }
}

