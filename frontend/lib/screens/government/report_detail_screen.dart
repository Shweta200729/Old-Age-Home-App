import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/government_provider.dart';
import '../../providers/auth_provider.dart';

class ReportDetailScreen extends StatefulWidget {
  final dynamic report;

  const ReportDetailScreen({
    super.key,
    required this.report,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late bool _isAcknowledged;
  final TextEditingController _warningController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isAcknowledged = widget.report['is_acknowledged'] == true;
  }

  @override
  void dispose() {
    _warningController.dispose();
    super.dispose();
  }

  bool get isAttention => widget.report['issues'] != null && widget.report['issues'].toString().trim().isNotEmpty;
  String get name => widget.report['elderly_name'] ?? 'Unknown';
  String get status => isAttention ? 'Attention Needed' : 'Normal';
  String get room => 'Room ${widget.report['room'] ?? 'N/A'}';
  String get date => widget.report['date'] ?? '';
  String get caretaker => widget.report['caretaker_name'] ?? 'Assigned Staff';
  String? get photoPath => widget.report['photo_path'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Stack(
        children: [
          // If there is an image, show it as a premium header background
          if (photoPath != null && photoPath!.isNotEmpty)
            Positioned(
              top: 0, left: 0, right: 0,
              height: 350,
              child: Stack(
                children: [
                  SizedBox(
                    height: 350,
                    width: double.infinity,
                    child: Image.network(
                      photoPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade300),
                    ),
                  ),
                  Container(
                    height: 350,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                          const Color(0xFFF7F8FA),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            // Fallback premium green header if no photo
            Positioned(
              top: 0, left: 0, right: 0,
              height: 250,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF048A39), Color(0xFF026A2A)],
                  ),
                ),
              ),
            ),
          
          SafeArea(
            child: Column(
              children: [
                _buildTopHeader(context),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(top: (photoPath != null && photoPath!.isNotEmpty) ? 140 : 20, bottom: 48),
                    children: [
                      _buildProfileSummary(),
                      const SizedBox(height: 20),
                      if (photoPath != null && photoPath!.isNotEmpty)
                        _buildPhotoEvidenceCard(),
                      const SizedBox(height: 16),
                      _buildMealsCard(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildMedicineCard()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildActivityCard()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildHygieneCard(),
                      const SizedBox(height: 16),
                      _buildMoodCard(),
                      if (isAttention) ...[
                        const SizedBox(height: 16),
                        _buildIssuesCard(),
                      ],
                      const SizedBox(height: 32),
                      _buildActionButtons(),
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

  Widget _buildTopHeader(BuildContext context) {
    bool hasPhoto = photoPath != null && photoPath!.isNotEmpty;
    Color iconColor = hasPhoto ? Colors.black87 : Colors.black87;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: iconColor),
            ),
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
                const Text(
                  'Resident Report',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black87),
                ),
                Text(
                  date,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF048A39), letterSpacing: 0.5),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSummary() {
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
                    name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87, height: 1.2),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isAttention ? Colors.red.shade50 : const Color(0xFF048A39).withOpacity(0.1), 
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: isAttention ? Colors.red.shade700 : const Color(0xFF048A39), 
                      fontSize: 10, 
                      fontWeight: FontWeight.w900, 
                      letterSpacing: 0.5
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.meeting_room_rounded, size: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    room,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.blue.shade50,
                  child: const Icon(Icons.person, size: 14, color: Colors.blue),
                ),
                const SizedBox(width: 8),
                Text('Assigned Caretaker: $caretaker', style: TextStyle(color: Colors.blueGrey.shade700, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoEvidenceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.camera_alt, color: Colors.blue, size: 14),
                ),
                const SizedBox(width: 8),
                const Text('Photo Evidence', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                photoPath!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180, 
                  color: Colors.grey.shade100, 
                  child: Center(child: Text('Image unavailable', style: TextStyle(color: Colors.grey.shade400)))
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _buildDetailSection(
        icon: Icons.restaurant,
        iconColor: Colors.orange,
        title: 'Dietary Intake',
        child: Row(
          children: [
            Expanded(child: _buildPillItem('Breakfast', widget.report['breakfast'] == 1)),
            const SizedBox(width: 8),
            Expanded(child: _buildPillItem('Lunch', widget.report['lunch'] == 1)),
            const SizedBox(width: 8),
            Expanded(child: _buildPillItem('Dinner', widget.report['dinner'] == 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineCard() {
    bool medicineGiven = widget.report['medicine_given'] == 1;
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: _buildDetailSection(
        icon: Icons.medical_services_outlined,
        iconColor: Colors.red,
        title: 'Medication',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(medicineGiven ? Icons.check_circle_rounded : Icons.cancel_rounded, color: medicineGiven ? Colors.green : Colors.red, size: 18),
                const SizedBox(width: 6),
                Text(medicineGiven ? 'Administered' : 'Not Given', style: TextStyle(color: medicineGiven ? Colors.green : Colors.red, fontWeight: FontWeight.w800, fontSize: 13)),
              ],
            ),
            if (medicineGiven && widget.report['medicine_time'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                child: Text('Time: ${widget.report['medicine_time']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black54)),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard() {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: _buildDetailSection(
        icon: Icons.directions_walk,
        iconColor: Colors.blue,
        title: 'Mobility & Activity',
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Text(
              widget.report['physical_activity'] ?? 'None', 
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.blue.shade700),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHygieneCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _buildDetailSection(
        icon: Icons.cleaning_services_outlined,
        iconColor: Colors.teal,
        title: 'Personal Care & Hygiene',
        child: Column(
          children: [
            _buildRowItem('Sponge/Full Bath', widget.report['bathing'] == 1),
            const SizedBox(height: 12),
            _buildRowItem('Grooming & Changing', widget.report['clothes_changed'] == 1),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCard() {
    String mood = widget.report['mood'] ?? 'Normal';
    bool isPositive = mood == 'Happy' || mood == 'Normal' || mood == 'Calm/Responsive';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _buildDetailSection(
        icon: Icons.mood,
        iconColor: Colors.amber.shade600,
        title: 'Cognitive & Emotional State',
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isPositive ? Colors.green.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isPositive ? Icons.sentiment_very_satisfied : Icons.sentiment_neutral, color: isPositive ? Colors.green : Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(mood, style: TextStyle(color: isPositive ? Colors.green.shade700 : Colors.orange.shade700, fontWeight: FontWeight.w800, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIssuesCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 14),
                ),
                const SizedBox(width: 8),
                Text('Issues Reported', style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.w900, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 16),
            Text(widget.report['issues'] ?? 'No specific issues described.', style: TextStyle(color: Colors.red.shade900, fontSize: 14, fontWeight: FontWeight.w500, height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAcknowledged ? Colors.grey.shade400 : const Color(0xFF048A39),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _isAcknowledged ? null : () async {
                    final provider = context.read<GovernmentProvider>();
                    bool success = await provider.acknowledgeReport(widget.report['id'], 'daily');
                    if (success && mounted) {
                      setState(() {
                        _isAcknowledged = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report acknowledged successfully.')));
                    }
                  },
                  icon: Icon(_isAcknowledged ? Icons.check_circle : Icons.check_circle_outline, color: Colors.white, size: 18),
                  label: Text(_isAcknowledged ? 'Acknowledged' : 'Acknowledge', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: BorderSide(color: Colors.grey.shade300, width: 2),
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    _showWarningDialog(context);
                  },
                  child: const Text('Send Warning', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: BorderSide(color: Colors.blue.shade600, width: 2),
                backgroundColor: Colors.blue.shade50,
              ),
              onPressed: () {
                _showInspectionDialog(context);
              },
              child: Text('Schedule Immediate Inspection', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w800)),
            ),
          )
        ],
      ),
    );
  }

  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send Warning', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _warningController,
          decoration: const InputDecoration(
            hintText: 'Enter warning message to the facility...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (_warningController.text.trim().isEmpty) return;
              final provider = context.read<GovernmentProvider>();
              final auth = context.read<AuthProvider>();
              final homeId = widget.report['home_id']; 
              final govtId = auth.user?['id'];
              
              if (homeId != null && govtId != null) {
                bool success = await provider.submitHomeFeedback(homeId, govtId, 1, 'OFFICIAL WARNING: ${_warningController.text}');
                if (success && mounted) {
                  Navigator.pop(ctx);
                  _warningController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Warning sent to facility.')));
                }
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Missing Home ID or Govt ID.')));
              }
            },
            child: const Text('Send Warning', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showInspectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Schedule Inspection', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: const Text('Are you sure you want to schedule an immediate inspection? This will severely flag the facility in the system.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final provider = context.read<GovernmentProvider>();
              final homeId = widget.report['home_id'];
              if (homeId != null) {
                bool success = await provider.scheduleInspection(homeId);
                if (success && mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inspection scheduled successfully.')));
                }
              }
            },
            child: const Text('Schedule', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({required IconData icon, required Color iconColor, required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title, 
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildPillItem(String label, bool isYes) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isYes ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isYes ? Colors.green.shade200 : Colors.red.shade200),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: isYes ? Colors.green.shade700 : Colors.red.shade700, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Icon(isYes ? Icons.check_circle_rounded : Icons.cancel_rounded, color: isYes ? Colors.green : Colors.red, size: 16),
        ],
      ),
    );
  }

  Widget _buildRowItem(String label, bool isYes) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isYes ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(isYes ? Icons.check_circle_rounded : Icons.cancel_rounded, color: isYes ? Colors.green : Colors.red, size: 14),
              const SizedBox(width: 4),
              Text(isYes ? 'Completed' : 'Missed', style: TextStyle(color: isYes ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.w800, fontSize: 11)),
            ],
          ),
        )
      ],
    );
  }
}
