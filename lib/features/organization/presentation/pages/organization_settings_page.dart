import 'package:flutter/material.dart';
import '../../../../core/services/database_seeder.dart';
import 'package:z_workflow/l10n/app_localizations.dart';

/// Admin page for managing the organizational structure:
/// departments, employees, categories, and cost centers.
class OrganizationSettingsPage extends StatelessWidget {
  /// Creates an [OrganizationSettingsPage].
  const OrganizationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsSection(
            icon: Icons.business_outlined,
            title: l10n.departments,
            subtitle: 'Manage departments and hierarchy',
            onTap: () {},
          ),
          _SettingsSection(
            icon: Icons.people_outline,
            title: l10n.employees,
            subtitle: 'Manage employees and roles',
            onTap: () {},
          ),
          _SettingsSection(
            icon: Icons.category_outlined,
            title: l10n.categories,
            subtitle: 'Manage purchase categories',
            onTap: () {},
          ),
          _SettingsSection(
            icon: Icons.account_tree_outlined,
            title: l10n.costCenters,
            subtitle: 'Manage cost centers',
            onTap: () {},
          ),
          _SettingsSection(
            icon: Icons.rule_outlined,
            title: l10n.approvalRules,
            subtitle: 'Configure approval thresholds',
            onTap: () {},
          ),
          const Divider(height: 32),
          _SettingsSection(
            icon: Icons.cloud_upload_outlined,
            title: 'Inizializza Dati Demo',
            subtitle: 'Popola reparti, gerarchia e budget su Firestore',
            onTap: () => _confirmAndSeed(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndSeed(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Inizializzazione Dati Demo'),
        content: const Text(
          'Vuoi popolare il tenant Firestore con i dati aziendali di esempio (reparti, gerarchia responsabili, budget e regole)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Inizializza'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seeding in corso su Firestore...')),
      );
      final seeder = DatabaseSeeder();
      await seeder.seedTenant();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dati demo inizializzati con successo!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore durante il seeding: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
