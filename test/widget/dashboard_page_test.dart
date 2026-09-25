import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:z_workflow/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:z_workflow/l10n/app_localizations.dart';

void main() {
  testWidgets('DashboardPage renders welcome header and summary cards',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DashboardPage(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify presence of dashboard title and key cards with exact Italian strings
    expect(find.text('Bentornato!'), findsOneWidget);
    expect(find.text('Da approvare'), findsOneWidget);
    expect(find.text('Le mie richieste'), findsOneWidget);
    expect(find.text('Budget CAPEX totale'), findsOneWidget);
    expect(find.text('Budget OPEX totale'), findsOneWidget);
  });
}
