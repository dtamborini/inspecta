import 'package:flutter/material.dart';
import 'package:omdk_inspecta/elements/alerts/alerts.dart';

/// Example splash screen page
class SplashPage extends StatelessWidget {
  /// Create [SplashPage] instance
  const SplashPage({
    super.key,
    this.alert,
  });

  final OMDKAlert? alert;

  @override
  Widget build(BuildContext context) {
    if (alert != null) {
      OMDKAlert.show(
        context,
        alert!,
      );
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: alert != null ? const CircularProgressIndicator() : null,
      ),
    );
  }
}
