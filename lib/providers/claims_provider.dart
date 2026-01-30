import 'package:flutter/foundation.dart';
import 'package:claim_management/models/claim.dart';

class ClaimsProvider with ChangeNotifier {
  final List<Claim> _claims = [];

  List<Claim> get claims => _claims;

  void addClaim(Claim claim) {
    _claims.add(claim);
    notifyListeners();
  }

  void updateStatus(String claimId, ClaimStatus status) {
    final index = _claims.indexWhere((c) => c.id == claimId);
    if (index != -1) {
      _claims[index].transitionStatus(status);
      notifyListeners();
    }
  }

  void addBill(String claimId, Bill bill) {
    final index = _claims.indexWhere((c) => c.id == claimId);
    if (index != -1) {
      _claims[index].addBill(bill);
      notifyListeners();
    }
  }

  void removeBill(String claimId, String billId) {
    final index = _claims.indexWhere((c) => c.id == claimId);
    if (index != -1) {
      _claims[index].removeBill(billId);
      notifyListeners();
    }
  }

  void updateBill(String claimId, Bill bill) {
    final index = _claims.indexWhere((c) => c.id == claimId);
    if (index != -1) {
      _claims[index].updateBill(bill);
      notifyListeners();
    }
  }

  void updateAdvance(String claimId, double amount) {
    final index = _claims.indexWhere((c) => c.id == claimId);
    if (index != -1) {
      _claims[index].advanceAmount = amount;
      _claims[index].history.add('Updated advance amount to \$$amount');
      notifyListeners();
    }
  }

  void updateSettled(String claimId, double amount) {
    final index = _claims.indexWhere((c) => c.id == claimId);
    if (index != -1) {
      _claims[index].settledAmount = amount;
      _claims[index].history.add('Updated settled amount to \$$amount');
      notifyListeners();
    }
  }
}
