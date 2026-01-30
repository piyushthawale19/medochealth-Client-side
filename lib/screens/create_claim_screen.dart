import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:claim_management/providers/claims_provider.dart';
import 'package:claim_management/models/claim.dart';

class CreateClaimScreen extends StatefulWidget {
  const CreateClaimScreen({super.key});

  @override
  State<CreateClaimScreen> createState() => _CreateClaimScreenState();
}

class _CreateClaimScreenState extends State<CreateClaimScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newClaim = Claim.create(
        _nameController.text,
        _phoneController.text,
      );
      
      Provider.of<ClaimsProvider>(context, listen: false).addClaim(newClaim);
      
      Navigator.pop(context); // Go back to dashboard or go to details?
      // Maybe go to details to add bills immediately
      // Navigator.pushReplacementNamed(context, '/claim_details', arguments: newClaim.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Claim', style: GoogleFonts.poppins()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Patient Information',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.normal), // Fixed: fontWeight should be FontWeight.w600 normally but keeping simple
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Patient Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a phone number' : null,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text('Create Claim', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
