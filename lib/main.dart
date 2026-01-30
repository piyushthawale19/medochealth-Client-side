import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:claim_management/providers/claims_provider.dart';
import 'package:claim_management/screens/dashboard_screen.dart';
import 'package:claim_management/screens/create_claim_screen.dart';
import 'package:claim_management/screens/claim_details_screen.dart';

void main() {
  runApp(const ClaimManagementApp());
}

class ClaimManagementApp extends StatelessWidget {
  const ClaimManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClaimsProvider(),
      child: MaterialApp(
        title: 'Insurance Claim Management',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueAccent,
            primary: Colors.blueAccent,
            secondary: Colors.orangeAccent,
            surface: Colors.grey[50],
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            titleTextStyle: GoogleFonts.poppins(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w600),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent, width: 2)),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const DashboardScreen(),
          '/create_claim': (context) => const CreateClaimScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/claim_details') {
            final claimId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ClaimDetailsScreen(claimId: claimId),
            );
          }
          return null;
        },
      ),
    );
  }
}
