import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

enum ClaimStatus {
  draft,
  submitted,
  approved,
  rejected,
  partiallySettled,
  fullySettled,
}

extension ClaimStatusExtension on ClaimStatus {
  String get name {
    switch (this) {
      case ClaimStatus.draft:
        return 'Draft';
      case ClaimStatus.submitted:
        return 'Submitted';
      case ClaimStatus.approved:
        return 'Approved';
      case ClaimStatus.rejected:
        return 'Rejected';
      case ClaimStatus.partiallySettled:
        return 'Partially Settled';
      case ClaimStatus.fullySettled:
        return 'Fully Settled';
    }
  }
}

class Bill {
  final String id;
  final String description;
  final double amount;
  final DateTime date;

  Bill({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
  });

  factory Bill.create(String desc, double amt) {
    return Bill(
      id: const Uuid().v4(),
      description: desc,
      amount: amt,
      date: DateTime.now(),
    );
  }
}

class Claim {
  final String id;
  final String patientName;
  final String patientPhone;
  final DateTime createdAt;
  ClaimStatus status;
  List<Bill> bills;
  double advanceAmount;
  double settledAmount;
  List<String> history;

  Claim({
    required this.id,
    required this.patientName,
    required this.patientPhone,
    required this.createdAt,
    this.status = ClaimStatus.draft,
    this.bills = const [],
    this.advanceAmount = 0.0,
    this.settledAmount = 0.0,
    this.history = const [],
  });

  factory Claim.create(String name, String phone) {
    return Claim(
      id: const Uuid().v4(),
      patientName: name,
      patientPhone: phone,
      createdAt: DateTime.now(),
      history: ['Claim created on ${DateFormat.yMd().add_jm().format(DateTime.now())}'],
    );
  }

  factory Claim.empty() {
    return Claim(
      id: '',
      patientName: '',
      patientPhone: '',
      createdAt: DateTime.now(),
    );
  }

  double get totalBillAmount {
    return bills.fold(0.0, (sum, bill) => sum + bill.amount);
  }

  double get pendingAmount {
    return totalBillAmount - advanceAmount - settledAmount;
  }
  
  bool get canAddBill {
    return status == ClaimStatus.draft || status == ClaimStatus.submitted;
  }

  void addBill(Bill bill) {
    if (!canAddBill) return;
    bills = [...bills, bill];
    history.add('Added bill: ${bill.description} (\$${bill.amount})');
  }

  void removeBill(String billId) {
    if (!canAddBill) return;
    final bill = bills.firstWhere((b) => b.id == billId, orElse: () => Bill(id: '', description: '', amount: 0, date: DateTime.now()));
    if (bill.id.isEmpty) return;
    bills = bills.where((b) => b.id != billId).toList();
    history.add('Removed bill: ${bill.description}');
  }

  void updateBill(Bill updatedBill) {
    if (!canAddBill) return;
    final index = bills.indexWhere((b) => b.id == updatedBill.id);
    if (index == -1) return;
    
    bills[index] = updatedBill;
    history.add('Updated bill: ${updatedBill.description} (\$${updatedBill.amount})');
  }

  void transitionStatus(ClaimStatus newStatus) {
    if (status == newStatus) return;
    status = newStatus;
    history.add('Status changed to ${newStatus.name} on ${DateFormat.yMd().add_jm().format(DateTime.now())}');
    
    // Auto settle if total pending is 0? Maybe not automatically, let user do it explicitly.
  }
}
