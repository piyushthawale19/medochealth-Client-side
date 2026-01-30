import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:claim_management/providers/claims_provider.dart';
import 'package:claim_management/models/claim.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final claimsProvider = Provider.of<ClaimsProvider>(context);
    final claims = claimsProvider.claims;

    // Calculations
    final totalClaims = claims.length;
    final totalAmount = claims.fold(0.0, (sum, c) => sum + c.totalBillAmount);
    final pendingAmount = claims.fold(0.0, (sum, c) => sum + c.pendingAmount);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              children: [
                _SummaryCard(
                  title: 'Total Claims',
                  value: '$totalClaims',
                  icon: Icons.assignment,
                  color: Colors.blueAccent,
                ),
                const SizedBox(width: 16),
                _SummaryCard(
                  title: 'Pending',
                  value: NumberFormat.currency(symbol: '\$').format(pendingAmount),
                  icon: Icons.pending_actions,
                  color: Colors.orangeAccent,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SummaryCard(
              title: 'Total Amount',
              value: NumberFormat.currency(symbol: '\$').format(totalAmount),
              icon: Icons.attach_money,
              color: Colors.green,
              width: double.infinity,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Claims', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 16),
            if (claims.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: Text("No claims yet.")))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: claims.length,
                itemBuilder: (context, index) {
                  final claim = claims[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(claim.status).withAlpha(25),
                        child: Icon(_getStatusIcon(claim.status), color: _getStatusColor(claim.status)),
                      ),
                      title: Text(claim.patientName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${claim.status.name} • ${DateFormat.MMMd().format(claim.createdAt)}',
                        style: GoogleFonts.sourceSans3(color: Colors.grey[600]),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            NumberFormat.currency(symbol: '\$').format(claim.totalBillAmount),
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      onTap: () {
                         Navigator.pushNamed(context, '/claim_details', arguments: claim.id);
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/create_claim');
        },
        label: const Text('New Claim'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.draft: return Colors.grey;
      case ClaimStatus.submitted: return Colors.blue;
      case ClaimStatus.approved: return Colors.green;
      case ClaimStatus.rejected: return Colors.red;
      case ClaimStatus.partiallySettled: return Colors.orange;
      case ClaimStatus.fullySettled: return Colors.teal;
    }
  }

  IconData _getStatusIcon(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.draft: return Icons.edit_note;
      case ClaimStatus.submitted: return Icons.send;
      case ClaimStatus.approved: return Icons.check_circle;
      case ClaimStatus.rejected: return Icons.cancel;
      case ClaimStatus.partiallySettled: return Icons.timelapse;
      case ClaimStatus.fullySettled: return Icons.done_all;
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double? width;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: width == null ? 1 : 0,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                // could add trend icon here
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: GoogleFonts.sourceSans3(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
