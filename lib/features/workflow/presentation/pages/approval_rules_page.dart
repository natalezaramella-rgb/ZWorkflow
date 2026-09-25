import 'package:flutter/material.dart';
import 'package:z_workflow/l10n/app_localizations.dart';

/// Admin page for configuring approval rules per department and type.
class ApprovalRulesPage extends StatelessWidget {
  /// Creates an [ApprovalRulesPage].
  const ApprovalRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.approvalRules)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rule_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.noResults,
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new rule
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
