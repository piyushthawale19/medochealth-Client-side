import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:claim_management/providers/claims_provider.dart';
import 'package:claim_management/models/claim.dart';
import 'package:intl/intl.dart';

class ClaimDetailsScreen extends StatelessWidget {
  final String claimId;

  const ClaimDetailsScreen({super.key, required this.claimId});

  void _showAddBillDialog(BuildContext context, ClaimsProvider provider, [Bill? existingBill]) {
    String description = existingBill?.description ?? '';
    String amount = existingBill?.amount.toString() ?? '';
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existingBill == null ? 'Add Medical Bill' : 'Edit Medical Bill', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Description (e.g. MRI Scan)'),
              controller: TextEditingController(text: description),
              onChanged: (v) => description = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Amount (\$'),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: amount),
              onChanged: (v) => amount = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (description.isNotEmpty && amount.isNotEmpty) {
                final double? parsedAmount = double.tryParse(amount);
                if (parsedAmount == null) return;

                if (existingBill != null) {
                  // Edit existing bill
                  final updatedBill = Bill(
                    id: existingBill.id, // Keep same ID
                    description: description,
                    amount: parsedAmount,
                    date: existingBill.date, // Keep original date
                  );
                  provider.updateBill(claimId, updatedBill);
                } else {
                  // Create new bill
                  final bill = Bill.create(description, parsedAmount);
                  provider.addBill(claimId, bill);
                }
                Navigator.pop(ctx);
              }
            },
            child: Text(existingBill == null ? 'Add Bill' : 'Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showUpdateAmountDialog(BuildContext context, ClaimsProvider provider, String field, double currentValue) {
    String value = currentValue.toString();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update $field', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: TextField(
          decoration: const InputDecoration(labelText: 'Amount (\$)'),
          keyboardType: TextInputType.number,
          controller: TextEditingController(text: value),
          onChanged: (v) => value = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(value) ?? 0.0;
              if (field == 'Advance') {
                  provider.updateAdvance(claimId, val);
              } else if (field == 'Settled') {
                  provider.updateSettled(claimId, val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(BuildContext context, ClaimsProvider provider, Claim claim) {
     // Determine next possible statuses
     List<ClaimStatus> options = [];
     if (claim.status == ClaimStatus.draft) {
       options = [ClaimStatus.submitted];
     } else if (claim.status == ClaimStatus.submitted) {
       options = [ClaimStatus.approved, ClaimStatus.rejected, ClaimStatus.partiallySettled];
     } else if (claim.status == ClaimStatus.partiallySettled) {
        options = [ClaimStatus.fullySettled];
     } else if (claim.status == ClaimStatus.approved) {
        options = [ClaimStatus.fullySettled];
     }

     if (options.isEmpty) return;

     showDialog(
       context: context,
       builder: (ctx) => AlertDialog(
         title: Text('Update Status', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             ...options.map((s) => ListTile(
               title: Text(s.name),
               onTap: () {
                 provider.updateStatus(claimId, s);
                 Navigator.pop(ctx);
               },
             )),
           ],
         ),
       )
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClaimsProvider>(context);
    final claim = provider.claims.firstWhere((c) => c.id == claimId, orElse: () => Claim.empty());

    if (claim.id.isEmpty) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text("Claim not found")));
    }

    final canEdit = claim.status == ClaimStatus.draft || claim.status == ClaimStatus.submitted;

    return Scaffold(
      appBar: AppBar(
        title: Text('Claim Details', style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
               showDialog(
                 context: context,
                 builder: (_) => AlertDialog(
                   title: const Text("History"),
                   content: SizedBox(
                     width: double.maxFinite,
                     child: ListView(
                        shrinkWrap: true,
                        children: claim.history.map((h) => ListTile(title: Text(h), dense: true)).toList(),
                     ),
                   ),
                 ),
               );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(claim.status).withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStatusColor(claim.status).withAlpha(76)),
              ),
              child: Row(
                children: [
                  Icon(_getStatusIcon(claim.status), color: _getStatusColor(claim.status)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status', style: GoogleFonts.sourceSans3(color: Colors.grey[800], fontSize: 12)),
                      Text(claim.status.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: _getStatusColor(claim.status))),
                    ],
                  ),
                  const Spacer(),
                  if (canEdit || claim.status != ClaimStatus.fullySettled)
                  OutlinedButton.icon(
                    onPressed: () => _showStatusDialog(context, provider, claim),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text("Update"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _getStatusColor(claim.status),
                      side: BorderSide(color: _getStatusColor(claim.status).withAlpha(128)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Patient Info
            Text('Patient Information', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: Colors.grey[50], // Light grey background
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _DetailRow(icon: Icons.person, label: 'Name', value: claim.patientName),
                    const Divider(),
                    _DetailRow(icon: Icons.phone, label: 'Phone', value: claim.patientPhone),
                    const Divider(),
                    _DetailRow(icon: Icons.calendar_today, label: 'Date', value: DateFormat.yMMMd().format(claim.createdAt)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bills Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Medical Bills', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                if (canEdit)
                  TextButton.icon(
                    onPressed: () => _showAddBillDialog(context, provider),
                    icon: const Icon(Icons.add),
                    label: const Text("Add Bill"),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (claim.bills.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), borderRadius: BorderRadius.circular(12)),
                child: Text("No bills added yet.", style: TextStyle(color: Colors.grey[500])),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: claim.bills.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final bill = claim.bills[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(bill.description, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(DateFormat.yMMMd().format(bill.date), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(NumberFormat.currency(symbol: '\$').format(bill.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (canEdit) ...[
                           IconButton(
                             icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                             onPressed: () => _showAddBillDialog(context, provider, bill),
                           ),
                           IconButton(
                             icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                             onPressed: () => provider.removeBill(claimId, bill.id),
                           ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              
            const SizedBox(height: 16),
            const Divider(thickness: 1),
            const SizedBox(height: 16),
            
            // Totals
            _TotalRow(label: 'Total Bill Amount', value: claim.totalBillAmount, isBold: true),
            const SizedBox(height: 8),
            GestureDetector(
                onTap: canEdit ? () => _showUpdateAmountDialog(context, provider, 'Advance', claim.advanceAmount) : null,
                child: _TotalRow(label: 'Advance Paid', value: claim.advanceAmount, color: Colors.green, showEdit: canEdit), 
            ),
             const SizedBox(height: 8),
             GestureDetector(
                onTap: claim.status == ClaimStatus.partiallySettled || claim.status == ClaimStatus.approved ? () => _showUpdateAmountDialog(context, provider, 'Settled', claim.settledAmount) : null,
                child: _TotalRow(label: 'Settled Amount', value: claim.settledAmount, color: Colors.blue, showEdit: claim.status == ClaimStatus.partiallySettled || claim.status == ClaimStatus.approved),
             ),
             const SizedBox(height: 16),
            _TotalRow(label: 'Pending Amount', value: claim.pendingAmount, isBold: true, color: Colors.red),
          ],
        ),
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text('$label:', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;
  final Color? color;
  final bool showEdit;

  const _TotalRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
    this.showEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: Colors.grey[800])),
            if (showEdit) ...[
              const SizedBox(width: 8),
              Icon(Icons.edit, size: 14, color: Colors.grey[400]),
            ],
          ],
        ),
        Text(
          NumberFormat.currency(symbol: '\$').format(value),
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
