import 'package:flutter/material.dart';
import 'package:mu_delivery/providers/auth_provider.dart';
import 'package:mu_delivery/signin_page.dart';
import 'package:mu_delivery/coustemer_home_page.dart';
import 'package:mu_delivery/owner_dashboards/owner_dashboard.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<myProvider>(context);

    // While checking authentication (initializing Firebase)
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If not logged in
    if (authProvider.user == null) {
      return const SigninPage();
    }

    // If logged in, route by role
    if (authProvider.role == 'owner') {
      return const OwnerDashboard();
    } else {
      return const HomePage();
    }
  }
}
